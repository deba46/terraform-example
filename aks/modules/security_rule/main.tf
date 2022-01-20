/*data "azurerm_resources" "azure-resources" {
  resource_group_name = var.node_resource_group
  type = "Microsoft.Network/networkSecurityGroups"
}
*/
# https://stackoverflow.com/questions/57562597/how-do-i-combine-terraform-with-azure-cli-and-rest-api
# https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/data_source
# Changes to Outputs:
#  + sec-val = {
#      + "name" = "aks-agentpool-30237116-nsg"
#    }
#  Changes to Outputs:
#  + sec-val = "aks-agentpool-30237116-nsg"
#

data "external" "get-nsg-name" {
  program = ["/bin/bash", "../modules/security_rule/get_nsg_name.sh", var.node_resource_group]
}

output "value" {
  value = data.external.get-nsg-name.result.name
}

resource "azurerm_network_security_rule" "testrules" {


 
  for_each                    = local.nsgrules 
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.node_resource_group
  network_security_group_name = data.external.get-nsg-name.result.name
}
