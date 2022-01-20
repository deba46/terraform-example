#########################################################
# Change local variables to use an existing resource
# group and location OR
# Uses default values
#########################################################
locals {
  resource_group = var.resource_group_name
  location = var.location
  k8s_namespace = var.k8s_namespace
  cluster_name = var.cluster_name
  subnet_id = var.subnet_id
}


########################################################
# AKS Cluster Network
#########################################################
module "aks_network" {
  source              = "../modules/aks_network"
  subnet_name         = var.subnet_name
  vnet_name           = var.vnet_name
  resource_group_name = local.resource_group
  subnet_cidr         = var.subnet_cidr
  location            = local.location
  address_space       = var.address_space
  #depends_on = [azurerm_resource_group.aks]

}
############################################################
# AKS IDs - module can be used to create service principal
############################################################

# module "aks_identities" {
#  source       = "../modules/aks_identities"
#  cluster_name = var.cluster_name
#}
######################################################
# AKS Log Analytics
######################################################
#module "log_analytics" {
#  source                           = "../modules/log_analytics"
#  resource_group_name              = azurerm_resource_group.aks.name
#  log_analytics_workspace_location = var.log_analytics_workspace_location
#  log_analytics_workspace_name     = var.log_analytics_workspace_name
#  log_analytics_workspace_sku      = var.log_analytics_workspace_sku
  #depends_on = [azurerm_resource_group.aks]
# }

#####################################################
# CREATE AKS CLUSTER
# Cluster Authentication -
# 1. Managed Identity
# 2. Use service principal , set as env variable
# export TF_VAR_client_id = ..
# export TF_VAR_client_secret = ..
#####################################################

locals {
    # make var_nodepool to empty array if false
  var_nodepool = var.createnodepool ? var.new_nodepool : {}
  }

module "aks_cluster" {
  source                   = "../modules/aks-cluster"
  cluster_name             = local.cluster_name
  location                 = local.location
  dns_prefix               = var.dns_prefix
  resource_group_name      = local.resource_group
  kubernetes_version       = var.kubernetes_version
  node_count               = var.node_count
  min_count                = var.min_count
  max_count                = var.max_count
  os_disk_size_gb          = "128"
  max_pods                 = "110"
  vm_size                  = var.vm_size
  vnet_subnet_id           = module.aks_network.subnet_id
  # client_id              = module.aks_identities.cluster_client_id
  # client_secret          = module.aks_identities.cluster_sp_secret

  # ADD one or more node pool
  #
  additional_pool = local.var_nodepool

}

###########sleep#################
resource "time_sleep" "wait_60_seconds" {
  depends_on = [module.aks_cluster]

  create_duration = "60s"
}
#################################################################
# SET kubectl context
##################################################################
resource "null_resource" "set_kubectl_context" {
  triggers = {
    cluster_id = module.aks_cluster.azurerm_kubernetes_cluster_id
  }
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${local.resource_group} --name ${module.aks_cluster.azurerm_kubernetes_cluster_name} --overwrite"
  }
  depends_on = [module.aks_cluster]

}

#################################################
# DATA to be used to create kubernetes provider
#################################################

data "azurerm_kubernetes_cluster" "cluster" {
  name                = module.aks_cluster.azurerm_kubernetes_cluster_name
  resource_group_name = local.resource_group
  depends_on = [module.aks_cluster,time_sleep.wait_60_seconds]
}

################################################################
# CREATE NAMESPACE - damage-prediction
################################################################
resource "kubernetes_namespace" "k8s-namespace" {
  metadata {
    name = "damage-prediction"
  }
  #depends_on = [data.azurerm_kubernetes_cluster.cluster]
}
####################################################################
# INSTALL ISTIO OPERATOR
# make to_provision flag true to install istio in the cluster
####################################################################

module "istio_operator" {
  source                   = "../modules/istio_operator"
  cluster_name             = var.cluster_name
  resource_group_name      = local.resource_group
  content                  = module.aks_cluster.kube_config
  depends_on = [module.aks_cluster]

  to_provision = "true"
}

##################################################################
# 1. Install promethus and grafana using HELM charts
#    https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
#    Prerequisite!!
#    Add helm repo to local repo list
#    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# 2. Install using manifest files from kube-prometheus repo
#    a. Build and compile to create yml files - one time activity
#       NOTE! make build_and_compile = true -> to create manifest files )
#    b. Run kubectl
##################################################################

module "kube-prometheus" {
  source                   = "../modules/kube-prometheus"
  cluster_name             = var.cluster_name
  depends_on = [null_resource.set_kubectl_context]

  build_and_compile = "false"
}

############################################################
# NODE POOL VERSION UPGRADE
# Cluster upgrade doesnt upgrade nodepool version
############################################################

resource "null_resource" "pool-version-update" {
  triggers = {
    aks_kubernetes_version = var.kubernetes_version
  }
  provisioner "local-exec" {
    command     = "./nodepool_ver_upgrade.sh ${var.cluster_name} ${local.resource_group}"
    working_dir = path.module
  }
  depends_on = [module.aks_cluster]
}

#######################################################
# UPDATE or CREATE NETWORK SECURITY RULES
#
#######################################################
#locals {
#  enable_rules = var.enable_security_update ? var.security_rules : {}
#  }

module "network_rules" {
  source                   = "../modules/security_rule"
  node_resource_group      = module.aks_cluster.azurerm_kubernetes_cluster_node_resource_group
  depends_on = [module.aks_cluster]

  #rules = local.enable_rules
}

#########################################################
# Install KEDA
# https://github.com/kedacore/keda/releases
# kubectl apply -f ./keda-2.2.0.yaml --kubeconfig="./.kube/terra-ddts"
# TODO ! filemd5() for yml file changes
#########################################################

resource "null_resource" "install_keda" {
  triggers = {
     cluster_id = module.aks_cluster.azurerm_kubernetes_cluster_id
     hash = filemd5("./k8s_yml/keda-2.2.0.yaml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ./k8s_yml/keda-2.2.0.yaml"
  }

  depends_on = [null_resource.set_kubectl_context]
}

#########################################################
# Install NGINX-INGRESS
# https://kubernetes.github.io/ingress-nginx/deploy/#azure
# TODO ! Use templatefile() for null resoucres /triggers ?
# TODO ! filemd5() for yml file changes
#########################################################
resource "null_resource" "install_ingress" {
  triggers = {
    cluster_id = module.aks_cluster.azurerm_kubernetes_cluster_id
    hash = filemd5("./k8s_yml/nginx-ingress-v0.44.0.yml")
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ./k8s_yml/nginx-ingress-v0.44.0.yml"
  }
  depends_on = [null_resource.set_kubectl_context]

}

###################################################################################
# CREATE STORAGE ACCOUNT
# This module creates namespace - damage-prediction , storage accounts and
# associated kubernetes secrets in the namespace
###################################################################################
module "storage_account" {
  source                    = "../modules/storage_account"
  #vnet_subnet_id            = module.aks_network.subnet_id
  vnet_subnet_id              = local.subnet_id
  resource_group_name       = local.resource_group
  location                  = local.location
  k8s_namespace             = local.k8s_namespace

  storageaccounts           = var.storageaccounts

  #depends_on = [kubernetes_namespace.k8s-namespace]

}

###################################################################################
# CREATE SERVICE BUS , TOPICS AND SUBSCRIPTIONS
# https://github.com/innovationnorway/terraform-azurerm-service-bus/blob/master/main.tf
# Update topic and subscriptions here modules/service_bus/topics.tf
#
###################################################################################

module "service_bus" {
  source                    = "../modules/service_bus"
  resource_group_name       = local.resource_group
  location                  = local.location
  cluster_name              = local.cluster_name
  #k8s_namespace             = kubernetes_namespace.k8s-namespace.metadata[0].name
  k8s_namespace             = var.k8s_namespace
  namespaces                = var.servicebus
  #depends_on = [kubernetes_namespace.k8s-namespace]

}


###################################################################################
# CREATE COSMOSDB ACCOUNT , DATABASES , COLLECTIONS and
# create kube secret file
# https://github.com/avinor/terraform-azurerm-cosmosdb-mongodb
# Add info about databases and collection here modules/cosmos_db/databases.tf
###################################################################################

module "cosmos_db" {
  source                    = "../modules/cosmos_db"
  resource_group_name       = local.resource_group
  location                  = local.location
  name                      = local.cluster_name
  vnet_subnet_id            = local.subnet_id

  databases = var.cosmosdb

  #depends_on = [kubernetes_namespace.k8s-namespace]

}


###################################################################################
# DEPLOY Elastic cloud on Kubernetes (ECK)
# https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html
#
###################################################################################
module "deploy_elk" {
  source                    = "../modules/deploy_elk"

  depends_on = [module.aks_cluster,kubernetes_namespace.k8s-namespace]

}


