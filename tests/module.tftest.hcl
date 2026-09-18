mock_provider "azurerm" {
  mock_data "azurerm_storage_account" {
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-audit/providers/Microsoft.Storage/storageAccounts/staudit"
      location = "westeurope"
    }
  }

  mock_data "azurerm_resource_group" {
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-audit"
      location = "westeurope"
    }
  }
}

variables {
  identity_name        = "audit-reader"
  resource_group_name  = "rg-audit"
  location             = "westeurope"
  storage_account_name = "staudit"
  container_name       = "evidence"
  role_name            = "Audit Evidence Reader"
}

run "container_scoped_assignment" {
  command = plan

  assert {
    condition     = azurerm_role_assignment.blob_read_only.scope == local.container_scope
    error_message = "The role assignment must remain scoped to one blob container."
  }

  assert {
    condition     = azurerm_role_definition.blob_read_only.scope == data.azurerm_resource_group.this.id
    error_message = "The custom role definition must use a supported resource-group scope."
  }

  assert {
    condition     = toset(azurerm_role_definition.blob_read_only.permissions[0].data_actions) == toset(["Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read"])
    error_message = "The custom role must grant blob read and no write or delete data actions."
  }
}
