resource "azurerm_servicebus_namespace" "asb" {
  for_each            = var.namespaces
  name                = each.key
  sku                 = each.value.sku
  location            = var.location
  resource_group_name =  var.resource_group_name

  lifecycle {
    ignore_changes = [
      # do not change
      tags,
    ]
  }

}

#### SEND LISTEN KEY #######################################################
resource "azurerm_servicebus_namespace_authorization_rule" "auth_send_listen" {
  for_each            = var.namespaces
  name                = "send_listen_auth_${each.key}"
  namespace_name      = azurerm_servicebus_namespace.asb[each.key].name
  resource_group_name =  var.resource_group_name

  listen = true
  send   = true
  manage = false
}

data "azurerm_servicebus_namespace_authorization_rule" "rule-data" {
  for_each            = var.namespaces
  name                = azurerm_servicebus_namespace_authorization_rule.auth_send_listen[each.key].name
  namespace_name      = azurerm_servicebus_namespace_authorization_rule.auth_send_listen[each.key].namespace_name
  resource_group_name = var.resource_group_name
}

#
# CREATE azureservicebus-secret in kubernetes namespace
#
resource "kubernetes_secret" "servicebus-secret" {
  for_each            = var.namespaces
  metadata {
    name          = "secret-${each.key}"
    namespace     =  var.k8s_namespace
  }
  data = {
    SendListenConnectionStr = data.azurerm_servicebus_namespace_authorization_rule.rule-data[each.key].primary_connection_string
    type = "Opaque"
  }
}

#---------------------------------------------------------------------------------------------------------------
locals {
  topics = flatten(
    [
      for namespace_key, namespace in var.namespaces : [
        for topic_key, topic in namespace.topics : {
          namespace_key = namespace_key
          topic_key     = topic_key
        }
      ]
    ]
  )


  subscriptions = flatten(
    [
      for namespace_key, namespace in var.namespaces : [
        for topic_key, topic in namespace.topics : [
          for subscription_key, subscription in topic : {

            namespace_key    = namespace_key
            topic_key        = topic_key
            subscription_key = subscription_key
            subscription     = subscription

          }
        ]
      ]
    ]
  )


 rules = flatten(
    [
      for namespace_key, namespace in var.namespaces : [
        for topic_key, topic in namespace.topics : [
          for subscription_key, values in topic : [
             for key , val in values : {
                  namespace_key    = namespace_key
                  topic_key        = topic_key
                  subscription_key = subscription_key
                  info = val
                  rule_key = key

             }
          ]
        ]
      ]
    ]
 )


}

output "topics_list" {
  value = local.topics
}
output "subs_list" {
   value = local.subscriptions
}
output "info_list" {
   value = local.rules
}

############################################################################
# CREATE ALL THE TOPICS
############################################################################
resource "azurerm_servicebus_topic" "create-topics" {
  for_each = {
    for topic in local.topics : "${topic.namespace_key}.${topic.topic_key}" => topic
  }
  name                = each.value.topic_key
  resource_group_name = var.resource_group_name
  namespace_name      = each.value.namespace_key
  enable_batched_operations = true

  depends_on = [azurerm_servicebus_namespace.asb]
}

resource "azurerm_servicebus_subscription" "subscription" {
  for_each = {
    for subscription in local.subscriptions : "${subscription.namespace_key}.${subscription.topic_key}.${subscription.subscription_key}" => subscription
  }

  name                = each.value.subscription_key
  resource_group_name = var.resource_group_name
  namespace_name      = each.value.namespace_key
  topic_name          = each.value.topic_key
  forward_to          = lookup(each.value.subscription, "forward_to", null) != null ? each.value.subscription.forward_to : null


  max_delivery_count  		= 10
  lock_duration       		= "PT1M"
  enable_batched_operations = true
  dead_lettering_on_message_expiration = true
  dead_lettering_on_filter_evaluation_error = true

  depends_on = [azurerm_servicebus_topic.create-topics]
}


resource "azurerm_servicebus_subscription_rule" "subscription_rule" {
  for_each = {
    for info in local.rules : "${info.namespace_key}.${info.topic_key}.${info.subscription_key}" => info
          if info.rule_key == "rule"

  }

  name = lookup(each.value.info, "rule_name", null) != null ? each.value.info.rule_name : null
  resource_group_name = var.resource_group_name
  namespace_name = each.value.namespace_key
  topic_name = each.value.topic_key
  subscription_name = each.value.subscription_key
  filter_type = lookup(each.value.info, "filter_type", null) != null ? each.value.info.filter_type : null
  sql_filter = lookup(each.value.info, "sql_filter", null) != null ? each.value.info.sql_filter : null
  depends_on = [azurerm_servicebus_subscription.subscription]
}


resource "azurerm_servicebus_subscription_rule" "subscription_rule_corr-1" {
  for_each = {
    for info in local.rules : "${info.namespace_key}.${info.topic_key}.${info.subscription_key}" => info
          if info.rule_key == "rule-corr-1"

  }

  name = lookup(each.value.info, "rule_name", null) != null ? each.value.info.rule_name : null
  resource_group_name = var.resource_group_name
  namespace_name = each.value.namespace_key
  topic_name = each.value.topic_key
  subscription_name = each.value.subscription_key
  filter_type = lookup(each.value.info, "filter_type", null) != null ? each.value.info.filter_type : null
  dynamic "correlation_filter" {
    for_each = {
      for info in local.rules : "${info.namespace_key}.${info.topic_key}.${info.subscription_key}" => info
            if info.rule_key == "rule-corr-1"}
    content {
      properties = tomap({(each.value.info.col_prop_key) = (each.value.info.col_prop_value)})

    }
  }

  depends_on = [azurerm_servicebus_subscription.subscription]
}

resource "azurerm_servicebus_subscription_rule" "subscription_rule_corr-2" {
  for_each = {
    for info in local.rules : "${info.namespace_key}.${info.topic_key}.${info.subscription_key}" => info
          if info.rule_key == "rule-corr-2"

  }

  name = lookup(each.value.info, "rule_name", null) != null ? each.value.info.rule_name : null
  resource_group_name = var.resource_group_name
  namespace_name = each.value.namespace_key
  topic_name = each.value.topic_key
  subscription_name = each.value.subscription_key
  filter_type = lookup(each.value.info, "filter_type", null) != null ? each.value.info.filter_type : null
  dynamic "correlation_filter" {
    for_each = {
      for info in local.rules : "${info.namespace_key}.${info.topic_key}.${info.subscription_key}" => info
            if info.rule_key == "rule-corr-2"}
    content {
      properties = tomap({(each.value.info.col_prop_key) = (each.value.info.col_prop_value)})

    }
  }

  depends_on = [azurerm_servicebus_subscription.subscription]
}



