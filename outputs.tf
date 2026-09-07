output "identity_principal_id" {
  description = "Principal (object) ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "identity_client_id" {
  description = "Client ID of the user-assigned managed identity, used when requesting a token"
  value       = azurerm_user_assigned_identity.this.client_id
}

output "role_definition_id" {
  description = "Resource ID of the custom least-privilege blob read-only role definition"
  value       = azurerm_role_definition.blob_read_only.role_definition_resource_id
}

output "assignment_scope" {
  description = "Container scope the role assignment is bound to"
  value       = local.container_scope
}
