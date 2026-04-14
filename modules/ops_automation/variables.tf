variable "prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "ops_resource_group_name" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "subscription_scope" {
  type = string
}

variable "timezone" {
  type = string
}

variable "default_tags" {
  type = map(string)
}
