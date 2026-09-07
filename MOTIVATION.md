# Why This Module Exists

## The Problem

Most Azure subscriptions accumulate two kinds of overpermission.

The first is the storage account key. It is easy, it works immediately, and it is a bearer credential for the entire account: every container, read and write, no expiry, no per-identity attribution in the audit log. Once it exists it gets pasted into app settings, CI variables, and eventually somebody's terminal history.

The second is scope creep on RBAC. A workload needs to read one container, so it gets `Storage Blob Data Reader` at the resource group. It works, nobody revisits it, and the blast radius quietly covers every storage account in that group.

Both create the same two risks:

1. Blast radius: if the identity or key is compromised, the attacker reaches far more than intended
2. Compliance: auditors see overpermission and flag it as a control failure

## The Solution

This module demonstrates what **least privilege actually looks like** on Azure:

- One managed identity, so there is no credential to leak in the first place
- One custom role, so the granted permissions are readable in this repository
- One container scope, not the account and not the resource group
- Read-only data actions, explicitly listed, never wildcards

## Key Design Decisions

### Why a user-assigned managed identity?
It has no secret. Azure issues short-lived tokens to the workload at runtime, so there is nothing to store in Terraform state, nothing to rotate on a schedule, and nothing to accidentally commit.

### Why a custom role instead of a built-in one?
`Storage Blob Data Reader` is close to right, but its definition lives in Azure's catalogue rather than in this repository. A custom role puts the exact granted actions in code, where a reviewer reads them in the pull request instead of looking them up.

### Why does the container scope matter so much?
Azure RBAC inherits downward. A role assigned at subscription, resource group, or storage account scope applies to everything beneath it. Assigning at the container resource ID is what makes "read-only access to one container" literally true rather than approximately true.

### Why is listKeys deliberately absent?
`Microsoft.Storage/storageAccounts/listKeys/action` lets a principal retrieve the account key and then act as the account, bypassing RBAC entirely. Granting it alongside a carefully scoped data role would make the scoping cosmetic. Its absence is a deliberate control, which is why it is called out rather than simply omitted.

## Real-World Usage

This pattern scales to larger infrastructures:

- Analytics workload: read-only access to one curated data container
- CI/CD pipeline: write-only access to a single artifact container
- Audit function: read access scoped per evidence container, one assignment each

Each identity gets exactly the permissions it needs. No exceptions.

## Learning Outcome

If you understand this module, you understand:

- How Azure RBAC scope inheritance decides real blast radius
- Why `actions` and `data_actions` are separate, and what each one reaches
- Why a key-retrieval permission can silently undo careful scoping
- How workload identity removes a class of credential-handling problems entirely

That knowledge transfers to every Azure subscription you'll ever touch.
