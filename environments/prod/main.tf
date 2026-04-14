data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

module "landing_zone" {
  source               = "../../modules/landing_zone"
  prefix               = var.prefix
  environment          = var.environment
  location             = var.location
  subscription_id      = data.azurerm_client_config.current.subscription_id
  subscription_scope   = data.azurerm_subscription.current.id
  allowed_locations    = var.allowed_locations
  policy_effect        = var.policy_effect
  alert_email_address  = var.alert_email_address
  budget_contact_email = var.budget_contact_email
  budget_amount        = var.budget_amount
  timezone             = var.timezone
  enable_ops_extension = var.enable_ops_extension
  default_tags         = var.default_tags
}

output "platform_resource_group_name" {
  value = module.landing_zone.platform_resource_group_name
}

output "workload_resource_group_name" {
  value = module.landing_zone.workload_resource_group_name
}

output "policy_assignment_id" {
  value = module.landing_zone.policy_assignment_id
}

output "automation_account_name" {
  value = module.landing_zone.automation_account_name
}
