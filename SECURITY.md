# Security Policy

## Reporting Security Issues

If you discover a security vulnerability in this module, please email security concerns to the maintainer rather than opening a public GitHub issue.

**Do not** publicly disclose security vulnerabilities until they have been addressed.

---

## Security Scope

This module demonstrates **least-privilege Azure RBAC patterns** for blob storage access. It is designed to show:

- Specific action grants (not wildcards)
- Scoped resource access (one container)
- Workload identity instead of shared keys
- Principle of least privilege in practice

### What This Module Does
- Creates a user-assigned managed identity with no stored credential
- Creates a custom role definition with explicit blob read-only actions
- Assigns that role at the scope of a single blob container
- Provides clear documentation of security design decisions

### What This Module Does NOT Do
- Provide complete Azure subscription security hardening
- Configure storage account network rules, firewalls, or private endpoints
- Manage Key Vault, customer-managed keys, or encryption settings
- Configure Conditional Access, PIM, or Azure Policy
- Manage Entra ID user or group lifecycle
- Configure diagnostic settings or Defender for Cloud

---

## Assumptions & Limitations

1. **Storage account pre-exists**: the target storage account and container are assumed to be created and managed separately
2. **Assignment authority**: applying this module requires permission to create role definitions and assignments, which is itself privileged; review who holds it
3. **Scope is fixed**: designed for read-only access to a single container; broader access requires code changes
4. **Shared-key auth is not disabled here**: this module never grants key access, but disabling `allow_shared_key_access` on the storage account is a separate control owned by the account's own configuration
5. **Eventual consistency**: role assignments take time to propagate; a workload may see authorization failures briefly after apply

---

## Dependency Security

This module uses only:

- **Terraform AzureRM Provider** (v3.0+): regularly updated by HashiCorp
- **Azure Resource Manager and Entra ID APIs**: native Azure services with no external dependencies

Monitor the AzureRM provider changelog for security updates: https://github.com/hashicorp/terraform-provider-azurerm/releases

---

## Testing & Validation

All changes to this module are validated with:

- `terraform fmt` — formatting consistency
- `terraform validate` — syntax and schema validation
- `tflint` — best practices linting

Before using in production:

1. Review the generated role definition in the Azure portal under Access control (IAM)
2. Confirm the assignment scope resolves to the container, not the storage account
3. Test with a non-production subscription first
4. Use `terraform plan` to audit all changes before applying

---

## Known Limitations

- Single-container scope (by design)
- No cross-tenant access support
- Does not enforce network restrictions on the storage account
- Does not disable shared-key access at the account level
- No Conditional Access requirement enforcement (must be configured separately)

---

## Security Best Practices When Using This Module

1. **Principle of Least Privilege**: only grant the actions needed for your use case
2. **Resource Scoping**: assign at container scope, not subscription or resource group
3. **Disable shared keys**: set `allow_shared_key_access = false` on the storage account so RBAC is the only path
4. **Regular Audits**: review role assignments and use Entra ID access reviews
5. **Monitoring**: enable storage diagnostic settings and Entra ID sign-in logs to monitor identity usage
6. **Documentation**: document why each identity needs access for compliance audits

---

## Version Support

- **Terraform**: 1.5.0 or later
- **AzureRM Provider**: 3.0 or later
- **Azure**: any region supporting user-assigned managed identities and storage RBAC

Older versions may work but are not tested or supported.
