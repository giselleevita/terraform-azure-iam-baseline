# Case Study: Terraform Azure Least-Privilege Blob Read Identity

## Problem

Small Azure workloads often need one service to read evidence, logs, exports, or reports from a specific blob container. Two shortcuts are common, and both grant far more than the workload needs.

The first is a connection string or storage account key. A key is a bearer credential for the whole account: every container, read and write, with no per-identity audit trail and no expiry. It then has to be stored somewhere, which creates a second problem.

The second is the built-in `Storage Blob Data Reader` role assigned at storage-account or resource-group scope. It is the Azure analogue of attaching `AmazonS3ReadOnlyAccess` on AWS: correct in verb, far too wide in scope.

This module demonstrates the narrower pattern: one workload identity, one custom role, one container.

## Solution

The Terraform module creates:

- a user-assigned managed identity, so the workload has no stored credential
- a custom role definition granting only container read and blob read
- a role assignment scoped to a single container resource ID
- an `assignable_scopes` list restricted to that same container

## Architecture

- `data.azurerm_storage_account.this` resolves the existing account so the container scope can be built from its resource ID.
- `local.container_scope` composes the container scope explicitly, which is the value a reviewer should check first.
- `azurerm_user_assigned_identity.this` creates the workload identity.
- `azurerm_role_definition.blob_read_only` defines the least-privilege role.
- `azurerm_role_assignment.blob_read_only` binds identity to role at container scope.

## Engineering Choices

- The assignment is container-scoped rather than account-scoped or resource-group-scoped.
- A custom role is used instead of a built-in role, so the granted actions are visible in this repository rather than in Azure's role catalogue.
- Blob contents are only reachable through `data_actions`. Granting `actions` alone would give container metadata and read as a control-plane operation, but not blob content. Both are stated explicitly rather than left implicit.
- `listKeys` is deliberately absent. If it were granted, the identity could retrieve the storage account key and bypass RBAC entirely, which would make the rest of the scoping decorative.
- `assignable_scopes` is narrowed to the same container, so the role cannot later be attached somewhere broader without an obvious code change.
- Inputs are validated so empty names fail at plan time.
- Provider configuration is kept minimal for simple local review, but production consumers should pass provider configuration from the root module.

## Security And Reliability Controls

- Least-privilege blob read access.
- No wildcard actions.
- No write, delete, or add data actions.
- No shared-key fallback path.
- No credential stored in Terraform state or application configuration.
- CI checks for Terraform formatting, validation, and linting.

## Current Limitations

This is not a full Azure subscription baseline. It does not enforce Conditional Access, PIM, Azure Policy, management-group governance, storage network isolation, private endpoints, diagnostic settings, or human-user lifecycle controls. It also assumes the storage account and container already exist.

Role definitions and assignments are eventually consistent in Azure Entra ID. A workload may see an authorization failure for a short period after `terraform apply` before the assignment propagates.

## What This Shows

This repo demonstrates a concrete Azure RBAC least-privilege pattern that a reviewer can verify quickly, and it makes the same argument as its AWS sibling on a different cloud's identity model. It is strongest when presented as a focused module, not as a full subscription security baseline.

## Next Improvements

- Add Terraform tests that assert exact actions and data actions.
- Add an example workload consuming the identity through `DefaultAzureCredential`.
- Add an optional Key Vault secret-read role scoped to a single secret.
- Document the propagation delay with a retry example.
- Remove provider configuration from the module and document root-module provider usage.
- Build a separate subscription-baseline module if Conditional Access, PIM, and Azure Policy are required.
