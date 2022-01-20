terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.51.0"
    }
  }
  #backend "local" {
  #}
  ###########################################################
  # TO use REMOTE BACKEND
  # tstate9904 -> dev subscription
  ###########################################################
  backend "azurerm" {
    resource_group_name   = ""
    storage_account_name  = ""
    container_name        = ""
    key                   = ""
  }
}

############################################################
# Login to az cli , tf uses default subscription
############################################################
provider "azurerm" {
  #version = "~> 2.0"
  skip_provider_registration = true
  features {}
}


#provider "kubernetes" {
#  # config_path    = "./.kube/${var.cluster_name}"
#  host                   = data.azurerm_kubernetes_cluster.cluster.kube_config.0.host
#  username               = data.azurerm_kubernetes_cluster.cluster.kube_config.0.username
#  password               = data.azurerm_kubernetes_cluster.cluster.kube_config.0.password
#  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate)
#  client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.client_key)
#  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate)
#}

