variable "prefix" {
  description = "Short prefix used for naming."
  type        = string
}

variable "environment" {
  description = "Environment name such as sandbox or prod."
  type        = string
}

variable "location" {
  description = "Primary Azure region."
  type        = string
  default     = "australiaeast"
}

variable "allowed_locations" {
  description = "Regions permitted by policy. Include global if needed by Microsoft-managed resources."
  type        = list(string)
}

variable "policy_effect" {
  description = "Policy effect. Usually Audit for sandbox and Deny for prod-style testing."
  type        = string
  default     = "Audit"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.policy_effect)
    error_message = "policy_effect must be Audit, Deny, or Disabled."
  }
}

variable "alert_email_address" {
  description = "Email address for alert notifications."
  type        = string
}

variable "budget_contact_email" {
  description = "Email address for budget notifications."
  type        = string
}

variable "budget_amount" {
  description = "Monthly subscription budget amount."
  type        = number
  default     = 50
}

variable "timezone" {
  description = "Timezone used for automation schedules."
  type        = string
  default     = "AUS Eastern Standard Time"
}

variable "enable_ops_extension" {
  description = "When true, deploys the Automation Account and runbooks."
  type        = bool
  default     = false
}

variable "default_tags" {
  description = "Base tags applied to deployed resources."
  type        = map(string)
}
