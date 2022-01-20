variable "name" {
  default = "we-dev-dvs-as-cosmos"
  description = "Name of the CosmosDB Account."
}

variable "resource_group_name" {
  description = "Name of resource group to deploy resources in."
}

variable "location" {
  description = "The Azure Region in which to create resource."
}

variable "ip_range_filter" {
  description = "CosmosDB Firewall Support: This value specifies the set of IP addresses or IP address ranges in CIDR form to be included as the allowed list of client IP's for a given database account."
  type        = list(string)
  default     = []
}

variable vnet_subnet_id {
    description = "aks vnet subnet id"
}

/*variable "databases" {
  description = "List of cosmos databases"
  type = map(object({
    throughput = number
    collections = list(object({
      name       = string
      shard_key  = string
      throughput = number
    }))
  }))
} */

variable "databases" {
  type        = map(any)
  description = "cosmosdb db names"
}