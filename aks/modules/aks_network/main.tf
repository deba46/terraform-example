resource "azurerm_network_security_group" "example" {
  name                = "test-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  address_space       = [var.address_space]
  resource_group_name = var.resource_group_name
  location            = var.location

  subnet {
    name           = var.subnet_name
    address_prefix = var.subnet_cidr
    security_group = azurerm_network_security_group.example.id
  }






}
#resource "azurerm_subnet" "aks_subnet" {
#  name                 = var.subnet_name
#  resource_group_name  = var.resource_group_name
# virtual_network_name = azurerm_virtual_network.aks_vnet.name
#  address_prefixes       = [var.subnet_cidr]
#  service_endpoints    = ["Microsoft.Storage", "Microsoft.AzureCosmosDB","Microsoft.ServiceBus"]
#  enforce_private_link_endpoint_network_policies = true
#}

# Network policy in new env- Deny-subnets-without-NSG
# https://github.com/terraform-providers/terraform-provider-azurerm/issues/6839

