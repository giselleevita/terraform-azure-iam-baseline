variable "identity_name" {
  description = "Name of the user-assigned managed identity to create"
  type        = string

  validation {
    condition     = length(trim(var.identity_name, " ")) > 0
    error_message = "identity_name must not be empty."
  }
}

variable "resource_group_name" {
  description = "Name of the existing resource group that holds the managed identity and the storage account"
  type        = string

  validation {
    condition     = length(trim(var.resource_group_name, " ")) > 0
    error_message = "resource_group_name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the managed identity"
  type        = string

  validation {
    condition     = length(trim(var.location, " ")) > 0
    error_message = "location must not be empty."
  }
}

variable "storage_account_name" {
  description = "Name of the existing storage account that holds the target container"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 lowercase letters or digits."
  }
}

variable "container_name" {
  description = "Name of the single blob container to grant read-only access to"
  type        = string

  validation {
    condition     = length(var.container_name) >= 3 && length(var.container_name) <= 63 && can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.container_name)) && !strcontains(var.container_name, "--")
    error_message = "container_name must meet Azure's 3-63 character lowercase DNS naming rules."
  }
}

variable "role_name" {
  description = "Name of the custom RBAC role definition to create"
  type        = string

  validation {
    condition     = length(trim(var.role_name, " ")) > 0
    error_message = "role_name must not be empty."
  }
}

variable "tags" {
  description = "Tags applied to the managed identity"
  type        = map(string)
  default     = {}
}
