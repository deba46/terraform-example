#output "cosmosdb_connectionstrings" {
#  value = module.cosmos_db.cosmosdb_connectionstrings

  #sensitive   = true
#}
#output "node_res-grp" {
#  value = module.aks_cluster.azurerm_kubernetes_cluster_node_resource_group
#}

#output "cluster_id" {
#  value = module.aks_cluster.azurerm_kubernetes_cluster_id
#}

#output "cluster_name" {
#  value = module.aks_cluster.azurerm_kubernetes_cluster_name
#}

#output "aks-nsg-name" {
#  value = module.network_rules.value
#}

#output "kibana-rendered" {
#  value = module.deploy_elk.kibana-yaml-rendered
#}

#output "kibana-template" {
#  value = module.deploy_elk.kibana-yaml-template
#}


#output "elastic_info_result" {
#  value = module.deploy_elk.elastic_info_result
#}

#output "fluentdfile-content" {
#  value = module.deploy_elk.fluentdfile

#}

#output "aks_vnet_id" {
#  value = module.aks_network.aks_vnet_id
#}

#output "nsg_id" {
#  value = module.aks_network.nsg_id
#}

##output "subnet_id" {
#  value = module.aks_network.subnet_id
#}

#output "topics_list" {
#  value = module.service_bus.topics_list
#}

output "subs_list" {
  value = module.service_bus.subs_list
}

output "info_list" {
   value = module.service_bus.info_list
}

#output "collec_op" {
#  value = module.cosmos_db.collec_op
#}

#output "stor_list" {
#  value = module.storage_account.storage_list
#}