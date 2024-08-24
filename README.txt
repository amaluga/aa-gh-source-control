Script for creation of Automation Account Source Control (GitHub). Helpful in tenants with high number of Automation Accounts. Script setups the source control for Automation Accounts located in specified subscription. Most of the variables you need to modify are in variables region, for additional modifications search '#Modify:' keyword in the script.

Main content:
- aa-gh-source-control-setup.ps1
#1. adding UAMI to all Automation Accounts in the subscription
#2. adding contributor role for MI in Automation Accounts and MI to AA variables
#3 Creation of GH repo structure /<env>/<Subscription Name>/<Automation Account Name>
#4. Add source control to AA

Bonus content:
- aa-gh-source-control-PAT-update.ps1
#1. update Source Control with re-generated PAT

PREREQUISITES to run the script:
 - User Assigned Managed Identity
 - Generated PAT (GitHub)
 - Modules:
  #Az.Automation
  #Az.Accounts
  #Az.Resources

All actions are followed steps from doc: https://learn.microsoft.com/en-us/azure/automation/source-control-integration

------------------------------------------------------------------------------------------------------------------------------------------
##Modules required:
#Az.Automation
#Az.Accounts
#Az.Resources

##Considerations
#1. Even if Source Control is active in AA, you can still make runbook changes in Cloud. Conflict Resolution: Be cautious when making manual edits. 
#If there’s a conflict between the repository version and the manually edited version, the latter will overwrite the former during synchronization.
#as per Copilot feedback, AutoSync occurrs every 15 minutes, so there's a delay. For urgent runbook changes, manual sync can be triggered. 
#However during my tests (small Lab) I found all gh changes reflected instantly in the Cloud

#2 To enable Auto Sync when configuring the source control integration with Azure DevOps, you must be the Project Administrator or the GitHub repo owner. Collaborators can only configure Source Control without Auto Sync.


##Docs
#https://learn.microsoft.com/en-us/azure/automation/source-control-integration

#https://learn.microsoft.com/en-us/azure/automation/add-user-assigned-identity
#https://learn.microsoft.com/en-us/powershell/module/az.automation/export-azautomationrunbook?view=azps-11.5.0
#https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#using-a-personal-access-token-on-the-command-line


