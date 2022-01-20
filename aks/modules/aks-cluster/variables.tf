variable "dns_prefix" {
  description = "DNS prefix"
}

variable "location" {
  description = "azure location to deploy resources"
}

variable "cluster_name" {
  description = "AKS cluster name"
}

variable "resource_group_name" {
  description = "name of the resource group to deploy AKS cluster in"
}

variable "kubernetes_version" {
  description = "version of the kubernetes cluster"
}

variable "api_server_authorized_ip_ranges" {
  description = "ip ranges to lock down access to kubernetes api server"
  default     = "0.0.0.0/0"
}

# Node Pool config
variable "agent_pool_name" {
  description = "name for the agent pool profile"
  default     = "agentpool"
}

variable "agent_pool_type" {
  description = "type of the agent pool (AvailabilitySet and VirtualMachineScaleSets)"
  default     = "VirtualMachineScaleSets"
}

variable "node_count" {
  description = "number of nodes to deploy"
}

variable "vm_size" {
  description = "size/type of VM to use for nodes"
}


variable "os_disk_size_gb" {
  description = "size of the OS disk to attach to the nodes"
}

variable "vnet_subnet_id" {
  description = "vnet id where the nodes will be deployed"
}

variable "max_pods" {
  description = "maximum number of pods that can run on a single node"
}

#Network Profile config

variable "network_plugin" {
  description = "network plugin for kubenretes network overlay (azure or kubenet)"
  default     = "kubenet"
}

variable "network_policy" {
  description = "network policy - calico ?"
  default     = null
}

variable "service_cidr" {
  description = "kubernetes internal service cidr range"
  default     = "10.0.0.0/16"
}
# Uncomment if using service principal
#variable "client_id" {}
#variable "client_secret" {}

variable "min_count" {
  description = "Minimum Node Count"
}
variable "max_count" {
  description = "Maximum Node Count"
}
variable "default_pool_name" {
  description = "name for the agent pool profile"
  default     = "agentpool"
}
variable "default_pool_type" {
  description = "type of the agent pool (AvailabilitySet and VirtualMachineScaleSets)"
  default     = "VirtualMachineScaleSets"
}

variable "additional_pool" {
  description = "The map object to configure one or several additional node pools with number of worker nodes, worker node VM size and Availability Zones."
  #type = map(object({
  #  node_count                     = number
  #  vm_size                        = string
  #  zones                          = list(string)
  #  taints                         = list(string)
  #  node_os                        = string
  #  cluster_auto_scaling           = bool
  #  cluster_auto_scaling_min_count = number
  #  cluster_auto_scaling_max_count = number
  #}))
}






