output "azurerm_kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.cluster.id
}

output "azurerm_kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.cluster.name
}


output "azurerm_kubernetes_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.cluster.fqdn
}

output "azurerm_kubernetes_cluster_node_resource_group" {
  value = azurerm_kubernetes_cluster.cluster.node_resource_group
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.cluster.kube_config_raw
}
