data "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

locals {
  # Role assignment is scoped to one container, not the storage account and not
  # the resource group. Narrowing the scope is the entire point of this module.
  container_scope = "${data.azurerm_storage_account.this.id}/blobServices/default/containers/${var.container_name}"
}

resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_definition" "blob_read_only" {
  name = var.role_name
  # Azure custom roles can be assignable at management-group, subscription,
  # or resource-group scope—not at an individual blob container. The actual
  # grant remains container-scoped in azurerm_role_assignment below.
  scope       = data.azurerm_resource_group.this.id
  description = "Least-privilege read-only access to blobs in container ${var.container_name}"

  permissions {
    # Control-plane read of the container itself.
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read"
    ]

    # Data-plane read of blobs. Blob contents are only reachable through
    # data_actions, so omitting this would grant metadata access alone.
    data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"
    ]

    not_actions      = []
    not_data_actions = []
  }

  assignable_scopes = [
    data.azurerm_resource_group.this.id
  ]
}

resource "azurerm_role_assignment" "blob_read_only" {
  scope              = local.container_scope
  role_definition_id = azurerm_role_definition.blob_read_only.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.this.principal_id
}
