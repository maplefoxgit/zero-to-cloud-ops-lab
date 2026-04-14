variable "prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "subscription_scope" {
  type = string
}

variable "allowed_locations" {
  type = list(string)
}

variable "effect" {
  type = string
}
