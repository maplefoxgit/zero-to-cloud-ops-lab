variable "prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "subscription_scope" {
  type = string
}

variable "allowed_locations" {
  type = list(string)
}

variable "policy_effect" {
  type = string
}

variable "alert_email_address" {
  type = string
}

variable "budget_contact_email" {
  type = string
}

variable "budget_amount" {
  type = number
}

variable "timezone" {
  type = string
}

variable "enable_ops_extension" {
  type = bool
}

variable "default_tags" {
  type = map(string)
}
