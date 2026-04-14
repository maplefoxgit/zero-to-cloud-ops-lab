locals {
  automation_start_time = timeadd(timestamp(), "1h")
}

resource "azurerm_automation_account" "ops" {
  name                = "aa-${var.prefix}-${var.environment}-ops"
  location            = var.location
  resource_group_name = var.ops_resource_group_name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = var.default_tags
}

resource "azurerm_role_assignment" "automation_reader" {
  scope                = var.subscription_scope
  role_definition_name = "Reader"
  principal_id         = azurerm_automation_account.ops.identity[0].principal_id
}

resource "azurerm_role_assignment" "automation_contributor" {
  scope                = var.subscription_scope
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.ops.identity[0].principal_id
}

resource "azurerm_automation_runbook" "tag_heal" {
  name                    = "TagHeal"
  location                = var.location
  resource_group_name     = var.ops_resource_group_name
  automation_account_name = azurerm_automation_account.ops.name
  runbook_type            = "PowerShell"
  log_verbose             = true
  log_progress            = true
  description             = "Heals missing tags by inheriting values from the resource group."
  content                 = file("${path.root}/../../runbooks/TagHeal.ps1")
}

resource "azurerm_automation_runbook" "find_orphans" {
  name                    = "FindOrphanedResources"
  location                = var.location
  resource_group_name     = var.ops_resource_group_name
  automation_account_name = azurerm_automation_account.ops.name
  runbook_type            = "PowerShell"
  log_verbose             = true
  log_progress            = true
  description             = "Finds orphaned resources and optionally deletes eligible resources."
  content                 = file("${path.root}/../../runbooks/FindOrphanedResources.ps1")
}

resource "azurerm_automation_schedule" "tag_heal_daily" {
  name                    = "tag-heal-daily"
  resource_group_name     = var.ops_resource_group_name
  automation_account_name = azurerm_automation_account.ops.name
  frequency               = "Day"
  interval                = 1
  timezone                = var.timezone
  start_time              = local.automation_start_time
  description             = "Runs tag healing once per day."
}

resource "azurerm_automation_job_schedule" "tag_heal_daily" {
  resource_group_name     = var.ops_resource_group_name
  automation_account_name = azurerm_automation_account.ops.name
  schedule_name           = azurerm_automation_schedule.tag_heal_daily.name
  runbook_name            = azurerm_automation_runbook.tag_heal.name

  parameters = {
    SubscriptionId = var.subscription_id
    RequiredTags   = "owner,environment,costCentre"
    WhatIfMode     = "False"
  }
}

resource "azurerm_automation_schedule" "orphan_report_daily" {
  name                    = "orphan-report-daily"
  resource_group_name     = var.ops_resource_group_name
  automation_account_name = azurerm_automation_account.ops.name
  frequency               = "Day"
  interval                = 1
  timezone                = var.timezone
  start_time              = local.automation_start_time
  description             = "Runs orphan detection once per day."
}

resource "azurerm_automation_job_schedule" "orphan_report_daily" {
  resource_group_name     = var.ops_resource_group_name
  automation_account_name = azurerm_automation_account.ops.name
  schedule_name           = azurerm_automation_schedule.orphan_report_daily.name
  runbook_name            = azurerm_automation_runbook.find_orphans.name

  parameters = {
    SubscriptionId = var.subscription_id
    SnapshotAgeDays = "30"
    DeleteEligible = "False"
  }
}
