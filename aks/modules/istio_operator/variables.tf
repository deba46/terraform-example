variable "cluster_name" {
  description = "AKS cluster name"
}

variable "resource_group_name" {
  description = "name of the resource group to deploy AKS cluster in"
}

variable "content" {
  description = "kubeconfig raw content for kubectl"
}

variable "to_provision" {
  type = string
  default = "false"
}
