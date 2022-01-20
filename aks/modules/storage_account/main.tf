locals {
  storages_accounts = flatten(
    [
      for stage_key, stage in var.storageaccounts : [
        for storage_key, storage in stage : {
          storage_key = storage_key
          storage     = storage
        }
      ]
    ]
  )
}


output "storage_list" {
  value = local.storages_accounts
}


resource "azurerm_storage_account" "storage" {

  for_each = {
    for sa in local.storages_accounts : "${sa.storage_key}" => sa
  }

  name                        = each.value.storage_key
  account_tier                = lookup(each.value.storage, "account_tier", null) != null ? each.value.storage.account_tier : null
  account_replication_type    = lookup(each.value.storage, "account_replication_type", null) != null ? each.value.storage.account_replication_type : null
  resource_group_name       = var.resource_group_name
  location                  = var.location


  network_rules {
    default_action             = "Deny"
    #ip_rules                   = ["100.0.0.1"]
    virtual_network_subnet_ids = [var.vnet_subnet_id]
  }

}

/*
###########sleep#################
resource "time_sleep" "wait_60_seconds" {
  depends_on = [azurerm_storage_account.storage]

  create_duration = "60s"

}


data "azurerm_storage_account" "data-info" {

  for_each = {for sa in local.storages_accounts : "${sa.storage_key}" => sa}
  name                        = each.value.storage_key
  resource_group_name       = var.resource_group_name
  depends_on = [time_sleep.wait_60_seconds]
}

resource "kubernetes_secret" "blob-secret" {
  for_each = {for sa in local.storages_accounts : "${sa.storage_key}" => sa}

  metadata {
    name          = "${each.value.storage_key}-secret"
    namespace     = var.k8s_namespace
  }
  data = {
    blobconnstring = data.azurerm_storage_account.data-info[each.value.storage_key].primary_blob_connection_string
    type = "Opaque"
  }
}

*/
