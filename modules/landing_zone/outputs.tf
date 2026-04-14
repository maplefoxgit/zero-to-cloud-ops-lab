output "platform_resource_group_name" {
  value = azurerm_resource_group.platform.name
}

output "workload_resource_group_name" {
  value = azurerm_resource_group.workload.name
}

output "policy_assignment_id" {
  value = module.policy_pack.policy_assignment_id
}

output "automation_account_name" {
  value = var.enable_ops_extension ? module.ops_automation[0].automation_account_name : null
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.platform.name
}
