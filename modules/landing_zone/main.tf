resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  common_tags = merge(
    var.default_tags,
    {
      environment = var.environment
      managedBy   = "terraform"
      project     = "secure-cloud-baseline-lab"
    }
  )
}

resource "azurerm_resource_group" "platform" {
  name     = "rg-${var.prefix}-${var.environment}-platform"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_resource_group" "workload" {
  name     = "rg-${var.prefix}-${var.environment}-workload"
  location = var.location

  tags = merge(
    local.common_tags,
    {
      owner      = lookup(local.common_tags, "owner", "platform-team")
      costCentre = lookup(local.common_tags, "costCentre", "cloudops-lab")
    }
  )
}

resource "azurerm_log_analytics_workspace" "platform" {
  name                = "law-${var.prefix}-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_monitor_action_group" "platform" {
  name                = "ag-${var.prefix}-${var.environment}-ops"
  resource_group_name = azurerm_resource_group.platform.name
  short_name          = "cloudops"

  email_receiver {
    name                    = "primary"
    email_address           = var.alert_email_address
    use_common_alert_schema = true
  }
}

module "policy_pack" {
  source             = "../policy_pack"
  prefix             = var.prefix
  environment        = var.environment
  subscription_scope = var.subscription_scope
  allowed_locations  = var.allowed_locations
  effect             = var.policy_effect
}

resource "azurerm_monitor_activity_log_alert" "deployment_failures" {
  name                = "${var.prefix}-${var.environment}-deployment-failures"
  resource_group_name = azurerm_resource_group.platform.name
  scopes              = [var.subscription_scope]
  description         = "Alerts on failed administrative operations in the subscription."

  criteria {
    category = "Administrative"
    status   = "Failed"
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_activity_log_alert" "policy_events" {
  name                = "${var.prefix}-${var.environment}-policy-events"
  resource_group_name = azurerm_resource_group.platform.name
  scopes              = [var.subscription_scope]
  description         = "Alerts on policy activity in the subscription."

  criteria {
    category = "Policy"
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_consumption_budget_subscription" "platform" {
  name            = "${var.prefix}-${var.environment}-monthly-budget"
  subscription_id = var.subscription_scope
  amount          = var.budget_amount
  time_grain      = "Monthly"

  time_period {
    start_date = format("%sT00:00:00Z", formatdate("YYYY-MM-01", timestamp()))
  }

  notification {
    enabled        = true
    threshold      = 50
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = [var.budget_contact_email]
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = [var.budget_contact_email]
  }
}

module "ops_automation" {
  count = var.enable_ops_extension ? 1 : 0

  source                    = "../ops_automation"
  prefix                    = var.prefix
  environment               = var.environment
  location                  = azurerm_resource_group.platform.location
  ops_resource_group_name   = azurerm_resource_group.platform.name
  subscription_id           = var.subscription_id
  subscription_scope        = var.subscription_scope
  timezone                  = var.timezone
  default_tags              = local.common_tags
}
