resource "azurerm_policy_definition" "allowed_locations" {
  name         = "${var.prefix}-${var.environment}-allowed-locations"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Allowed locations"
  description  = "Audits or denies resources outside approved locations."
  metadata     = jsonencode({ category = "General" })
  policy_rule  = file("${path.module}/rules/allowed_locations.json")
  parameters   = file("${path.module}/rules/allowed_locations.parameters.json")
}

resource "azurerm_policy_definition" "require_tag" {
  name         = "${var.prefix}-${var.environment}-require-tag"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require a tag"
  description  = "Audits or denies resources missing a required tag."
  metadata     = jsonencode({ category = "Tags" })
  policy_rule  = file("${path.module}/rules/require_tag.json")
  parameters   = file("${path.module}/rules/require_tag.parameters.json")
}

resource "azurerm_policy_set_definition" "baseline" {
  name         = "${var.prefix}-${var.environment}-baseline"
  policy_type  = "Custom"
  display_name = "Secure Cloud Baseline"
  description  = "Baseline initiative for locations and required tags."
  metadata     = jsonencode({ category = "General" })

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
    reference_id         = "allowed-locations"
    parameter_values = jsonencode({
      listOfAllowedLocations = { value = var.allowed_locations }
      effect                 = { value = var.effect }
    })
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tag.id
    reference_id         = "require-owner"
    parameter_values = jsonencode({
      tagName = { value = "owner" }
      effect  = { value = var.effect }
    })
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tag.id
    reference_id         = "require-environment"
    parameter_values = jsonencode({
      tagName = { value = "environment" }
      effect  = { value = var.effect }
    })
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tag.id
    reference_id         = "require-costcentre"
    parameter_values = jsonencode({
      tagName = { value = "costCentre" }
      effect  = { value = var.effect }
    })
  }
}

resource "azurerm_policy_assignment" "baseline" {
  name                 = "${var.prefix}-${var.environment}-baseline-assignment"
  display_name         = "Secure Cloud Baseline - ${var.environment}"
  description          = "Applies location and tagging guardrails at the subscription scope."
  scope                = var.subscription_scope
  policy_definition_id = azurerm_policy_set_definition.baseline.id
}
