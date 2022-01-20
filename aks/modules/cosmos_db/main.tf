resource "azurerm_cosmosdb_account" "account" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"

  # Imp flags
  enable_automatic_failover = false
  enable_multiple_write_locations = false
  # Networking
  is_virtual_network_filter_enabled = true
  #public_network_access_enabled = false   # default is true
  ip_range_filter           = join(",", var.ip_range_filter)
  virtual_network_rule {
            id = var.vnet_subnet_id
            ignore_missing_vnet_service_endpoint = false
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}
################################################################
# Create databases and collections
################################################################
locals {

  databases = flatten(
    [
      for db_key, val in var.databases : {
          database_name = db_key
        }
    ]
  )

  collections = flatten(
    [
      for db_key, val in var.databases : [
        for coll_key, info in val.collections : {
          database_name = db_key
          coll_name     = coll_key
          coll_info     = info
        }
      ]
    ]
  )
}

output "collec_op" {
  value = local.databases
}


resource "azurerm_cosmosdb_mongo_database" "create-db" {
  for_each = {
    for db in local.databases : "${db.database_name}" => db
  }

  # topic in local.topics : "${topic.namespace_key}.${topic.topic_key}" => topic
  name                = each.value.database_name
  resource_group_name = azurerm_cosmosdb_account.account.resource_group_name
  account_name        = azurerm_cosmosdb_account.account.name
  #throughput          =
}


resource "azurerm_cosmosdb_mongo_collection" "create-coll" {

  for_each = {
    for coll in local.collections : "${coll.database_name}.${coll.coll_name}" => coll
  }

  name                = each.value.coll_name
  database_name       = each.value.database_name
  shard_key           = lookup(each.value.coll_info, "shard_key", null) != null ? each.value.coll_info.shard_key : null
  throughput          = lookup(each.value.coll_info, "throughput", null) != null ? each.value.coll_info.throughput : null

  resource_group_name = azurerm_cosmosdb_account.account.resource_group_name
  account_name        = azurerm_cosmosdb_account.account.name

  lifecycle {
    ignore_changes = [index]
  }

  depends_on = [azurerm_cosmosdb_mongo_database.create-db]   def __init__(capacity):
        self._capacity = capacity
        #self._documents = []

}
#
# Create cosmos secret in aks
# NOTE ! mongo api connection string is not available as data source yet
#
data "azurerm_cosmosdb_account" "d1" {
  name                = azurerm_cosmosdb_account.account.name
  resource_group_name = azurerm_cosmosdb_account.account.resource_group_name
  #sensitive = true
}

#output "cosmosdb_connectionstrings" {
#   value = "mongodb://${azurerm_cosmosdb_account.account.name}:${data.azurerm_cosmosdb_account.d1.primary_master_key}@${azurerm_cosmosdb_account.account.name}.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@${azurerm_cosmosdb_account.account.name}@"
#}

/*
resource "kubernetes_secret" "cosmos-secret" {

  metadata {
    name          = "azurecosmosdb-secret"
    namespace     = "damage-prediction"
  }
  data = {
    DbConnectionStr = "mongodb://${azurerm_cosmosdb_account.account.name}:${data.azurerm_cosmosdb_account.d1.primary_master_key}@${azurerm_cosmosdb_account.account.name}.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@${azurerm_cosmosdb_account.account.name}@"
    type = "Opaque"
  }
}

*/








