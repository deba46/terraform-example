variable resource_group_name {
  description = "name of the resource group to deploy AKS cluster in"
  #default     = "we-dev-as-dvs-rg"
  default = "dig-daa-nath-test"
}

variable location {
  description = "azure location to deploy resources"
  default     = "westeurope"
}

variable "subnet_id" {
  default = "/subscriptions/b3bf985d-e095-4581-b7d9-8bef19e4ad1a/resourceGroups/dig-daa-nath-test/providers/Microsoft.Network/virtualNetworks/dig-daa-nath-test-vnet/subnets/default"
}
variable cluster_name {
  description = "AKS cluster name"
  default     = "terra-ddts"
}

variable k8s_namespace {
  description = "AKS cluster name"
  default     = "damage-prediction"
}

variable "node_count" {
  description = "number of nodes to deploy"
  default     = 1
}

variable "dns_prefix" {
  description = "DNS Suffix"
  default     = "terra-ddts"
}

variable log_analytics_workspace_name {
  default = "terra-ddts-loganalytics-ws"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
  default = "westeurope"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
variable log_analytics_workspace_sku {
  default = "PerGB2018"
}

variable subnet_name {
  description = "subnet id where the nodes will be deployed"
  default     = "terra-ddts-subnet"
}

variable vnet_name {
  description = "vnet id where the nodes will be deployed"
  default     = "terra-ddts-vnet"
}

variable subnet_cidr {
  description = "the subnet cidr range"
  default     = "10.2.32.0/21"
}

variable kubernetes_version {
  description = "version of the kubernetes cluster"
  default = "1.20.9"
}

variable "vm_size" {
  description = "size/type of VM to use for nodes"
  default     = "Standard_D2_v2"
}

variable "os_disk_size_gb" {
  description = "size of the OS disk to attach to the nodes"
  default     = 512
}

variable "max_pods" {
  description = "maximum number of pods that can run on a single node"
  default     = "100"
}

variable "address_space" {
  description = "The address space that is used thenetwork_policy virtual network"
  default     = "10.2.0.0/16"
}
# Autoscale min and max

variable "min_count" {
  default     = 1
  description = "Minimum Node Count"
}
variable "max_count" {
  default     = 2
  description = "Maximum Node Count"
}


###################################################
# To create new node pool or not ?
# Set true to create one 
# Create or update map for appropriate node pool
####################################################
variable "createnodepool" {
  type            = bool
  default         = false
}

variable "new_nodepool" {
  description = "The map object to configure one or several additional node pools with number of worker nodes, worker node VM size and Availability Zones."
  type = map(object({
    node_count                     = number
    vm_size                        = string
    zones                          = list(string)
    taints                         = list(string)
    node_os                        = string
    cluster_auto_scaling           = bool
    cluster_auto_scaling_min_count = number
    cluster_auto_scaling_max_count = number
  }))

  default = {
    pool2 = {
      node_count = 1
      vm_size    = "Standard_D4_v3"
      zones      = ["1", "2"]
      node_os    = "Linux"
      taints     = null
      cluster_auto_scaling           = false
      cluster_auto_scaling_min_count = null
      cluster_auto_scaling_max_count = null
    }
  }
}

########################################################
# To update or create network security rules ?
# set to true to create or update
########################################################
variable "enable_security_update" {
  description = "If set to to true, security rules module will run"
  type        = bool
  default     = false
}

variable "servicebus" {
  description = "definition of servicebus namespaces - read from tfvars file"
}

variable "cosmosdb" {
  description = "cosmosdb db names - read from tfvars file"
}

variable "storageaccounts" {
  description = "stages- dev, qa and wf or prod"
}













