variable resource_group_name {
    description = "res grp name"
}
variable location {
    description = "azure location"
}
variable cluster_name {
    description = "cluster ane"
}

variable k8s_namespace {
    description = "k8s namespace - damage-prediction"
}

variable "namespaces" {
  type        = map(any)
  description = "(required) Servicebus namespaces"
}