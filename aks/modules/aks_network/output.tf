#output "aks_subnet_id" {
#  value = azurerm_subnet.aks_subnet.id
#}
output "aks_vnet_id" {
  value = azurerm_virtual_network.aks_vnet.id
}

output "nsg_id" {
  value = azurerm_network_security_group.example.id
}

output "subnet_id" {
  value = tolist(azurerm_virtual_network.aks_vnet.subnet)[0].id

}



