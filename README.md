Update note: A better approach is to use GitHub Actions with federated credentials.

---

# Automation Account GitHub Source Control Setup

Script for creation of Automation Account Source Control (GitHub). Helpful in tenants with a high number of Automation Accounts. The script sets up source control for Automation Accounts located in a specified subscription.

Most variables to modify are in the `#region variables` block. For additional modifications, search for the `#Modify:` keyword in the script.

---

## Main Content

### `aa-gh-source-control-setup.ps1`

1. Add UAMI to all Automation Accounts in the subscription
2. Add Contributor role for MI in Automation Accounts and MI to AA variables
3. Create GitHub repo structure: `/<env>/<Subscription Name>/<Automation Account Name>`
4. Add source control to AA

## Bonus Content

### `aa-gh-source-control-PAT-update.ps1`

1. Update Source Control with a re-generated PAT

---

## Prerequisites

- User Assigned Managed Identity (UAMI)
- Generated Personal Access Token (GitHub PAT)
- PowerShell modules:
  - `Az.Automation`
  - `Az.Accounts`
  - `Az.Resources`

---

## Considerations

**1. Manual edits and conflict resolution**

Even if Source Control is active in an Automation Account, you can still make runbook changes in the Cloud. Be cautious when making manual edits — if there is a conflict between the repository version and a manually edited version, the latter will overwrite the former during synchronization.

Auto Sync occurs every 15 minutes, so there may be a delay. For urgent runbook changes, manual sync can be triggered. During small Lab tests, GitHub changes were reflected instantly in the Cloud.

**2. Auto Sync permissions**

To enable Auto Sync when configuring source control integration with Azure DevOps, you must be the Project Administrator or the GitHub repo owner. Collaborators can only configure Source Control without Auto Sync.

---

## References

- [Azure Automation Source Control Integration](https://learn.microsoft.com/en-us/azure/automation/source-control-integration)
- [Add User Assigned Identity to Automation Account](https://learn.microsoft.com/en-us/azure/automation/add-user-assigned-identity)
- [Export-AzAutomationRunbook](https://learn.microsoft.com/en-us/powershell/module/az.automation/export-azautomationrunbook?view=azps-11.5.0)
- [Managing GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#using-a-personal-access-token-on-the-command-line)
