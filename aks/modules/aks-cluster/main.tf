resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = var.default_pool_name
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb
    vnet_subnet_id  = var.vnet_subnet_id
    max_pods        = var.max_pods
    type            = var.default_pool_type
    enable_auto_scaling = true
    min_count           = var.min_count
    max_count           = var.max_count

    tags = merge(
    {
       "dvs" = "cloud-migration"
    },
    {
      "MainResourceGroup" = "dig-daa-mobility-ddts-dev"
    },
  )
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    service_cidr       = var.service_cidr
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }
  # For authentication use Managed identity or service principal
  #
  identity {
    type = "SystemAssigned"
  }
  #service_principal {
  #  client_id     = var.client_id
  #  client_secret = var.client_secret
  #}

 role_based_access_control {
    enabled = true
 }
#https://github.com/terraform-providers/terraform-provider-azurerm/issues/4911
  private_cluster_enabled = true

 tags = {
        "dvs" = "cloud-migration"
    }

  #lifecycle {
  #  prevent_destroy = true
  #}
}

# ADD NEW NODE POOLS

resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  for_each = var.additional_pool

  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id
  name                  = each.value.node_os == "Windows" ? substr(each.key, 0, 6) : substr(each.key, 0, 12)
  orchestrator_version  = var.kubernetes_version
  node_count            = each.value.node_count
  vm_size               = each.value.vm_size
  availability_zones    = each.value.zones
  max_pods              = 110
  os_disk_size_gb       = 128
  os_type               = each.value.node_os
  vnet_subnet_id        = var.vnet_subnet_id
  node_taints           = each.value.taints
  enable_auto_scaling   = each.value.cluster_auto_scaling
  min_count             = each.value.cluster_auto_scaling_min_count
  max_count             = each.value.cluster_auto_scaling_max_count
  enable_node_public_ip = false
}




