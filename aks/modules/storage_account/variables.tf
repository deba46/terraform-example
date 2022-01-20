variable resource_group_name {
    description = "res grp name"
}
variable location {
    description = "azure location"
}
variable vnet_subnet_id {
    description = "aks vnet subnet id"
}

variable k8s_namespace {
  description = "namespace ( to create storage account secrets )"

}

variable "storageaccounts" {
  type        = map(any)
  description = "dev , qa or prod/wf"
}