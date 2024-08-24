##Modules required:
#Az.Automation
#Az.Accounts
#Az.Resources

##Considerations
#1. Even if Source Control is active in AA, you can still make runbook changes in Cloud. Conflict Resolution: Be cautious when making manual edits. 
#If there’s a conflict between the repository version and the manually edited version, the latter will overwrite the former during synchronization.
#as per Copilot feedback, AutoSync occurrs every 15 minutes, so there's a delay. For urgent runbook changes, manual sync can be triggered. 
#However during my tests (small Lab) I found all gh changes reflected instantly in the Cloud

#2. Script setups the source control only for Automation Accounts located in SPECIFIED subscription.

##Docs
#https://learn.microsoft.com/en-us/azure/automation/source-control-integration

#https://learn.microsoft.com/en-us/azure/automation/add-user-assigned-identity
#https://learn.microsoft.com/en-us/powershell/module/az.automation/export-azautomationrunbook?view=azps-11.5.0
#https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#using-a-personal-access-token-on-the-command-line


Connect-AzAccount -tenant '<tenantID>' #Modify: tenantID

#region variables
$subscriptionID = '<subscriptionID>' #Modify: subscriptionID

#managedIdentity
$UAMI = '<name of managed identity>' #Modify: MI name
$UAMIobj = '<managed identity objectid>' #Modify: MI objectID
$UAMIclientId = '<managed identity clientId' #Modify: MI clientID
$UAMIRG = "<RG where MI is located>" #Modify: MI Resource Group name
#endregion

#get-AzSubscription is needed for further Az actions, additionally we fetch the name of the subscription for later gh repo structure
$subsName = (Get-AzSubscription -SubscriptionId $subscriptionID).Name


$AAs = Get-AzAutomationAccount

#1. adding UAMI to all Automation Accounts in the subscription
#https://learn.microsoft.com/en-us/azure/automation/add-user-assigned-identity
foreach($AA in $AAs){
    $resourceGroup = $AA.ResourceGroupName
    $automationAccount = $AA.AutomationAccountName
    $subscriptionID = $AA.SubscriptionId


    $output = Set-AzAutomationAccount `
    -ResourceGroupName $resourceGroup `
    -Name $automationAccount `
    -AssignUserIdentity "/subscriptions/$subscriptionID/resourcegroups/$UAMIRG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$UAMI" -debug

$output
}


###################
#2. adding contributor role for MI in Automation Accounts and MI to AA variables
foreach($AA in $AAs){
    $resourceGroup = $AA.ResourceGroupName
    $automationAccount = $AA.AutomationAccountName
    $subscriptionID = $AA.SubscriptionId


    $output = New-AzRoleAssignment `
    -ObjectId $UAMIobj `
    -Scope "/subscriptions/$subscriptionID/resourceGroups/$resourceGroup/providers/Microsoft.Automation/automationAccounts/$automationAccount" `
    -RoleDefinitionName "Contributor" 

    $output

    #adding MI variable to the AA variables - Microsoft's prerequisite
    #https://learn.microsoft.com/en-us/azure/automation/source-control-integration
    New-AzAutomationVariable -ResourceGroupName $ResourceGroup `
    -AutomationAccountName $AutomationAccount `
    -Name "AUTOMATION_SC_USER_ASSIGNED_IDENTITY_ID" `
    -Value $UAMIclientId `
    -Encrypted $false
}


####################
#3 Creation of GH repo structure /<env>/<Subscription Name>/<Automation Account Name>
#fetch all runbook names and AA name they are included in
$allRunbooks = @()
foreach($AA in $AAs){
    $runbook = Get-AzAutomationRunbook -AutomationAccountName $AA.AutomationAccountName -ResourceGroupName $AA.ResourceGroupName | Select-Object AutomationAccountName, Name, ResourceGroupName
    $allRunbooks += $runbook
}



foreach ($runbook in $allRunbooks){
    $RG = $runbook.ResourceGroupName
    $AA = $runbook.AutomationAccountName
    $runbookName = $runbook.Name
    
    #GH repo structure creation
    $path = "<Repo Path>\GitHub\aa-gh-source-control\LAB\$subsName\$AA" #Modify: Repo Path
    
    if(Get-Item -Path $path -ErrorAction SilentlyContinue){
        Write-Warning "Path $path already exists"
    } else {
        New-Item -ItemType Directory -Path $path
    }
    
    #Initial replication from Cloud - Adding runbooks for each automation /<env>/<Subscription Name>/<AA name>/<Runbook name>
    #https://learn.microsoft.com/en-us/powershell/module/az.automation/export-azautomationrunbook?view=azps-11.5.0
    try{
        Export-AzAutomationRunbook -ResourceGroupName $RG -AutomationAccountName $AA -Name $runbookName -Slot "Published" `
        -OutputFolder "<Repo Path>\GitHub\aa-gh-source-control\LAB\$subsName\$AA" -ErrorAction Stop #Modify: Repo Path
    } catch [System.ArgumentException] {
        if($_.Exception.Message -like 'Runbook file already exists*'){
            Write-Warning "Runbook file $runbookName already exists"
        }
    }
}




#4. Add source control to AA
$PAT = ConvertTo-SecureString -String '<PAT value>' -AsPlainText -Force #Modify: PAT


foreach($AA in $AAs){
    $resourceGroup = $AA.ResourceGroupName
    $automationAccount = $AA.AutomationAccountName
    $subscriptionID = $AA.SubscriptionId
    
    #Modify: RepoUrl
    New-AzAutomationSourceControl `
    -Name SCGitHub `
    -RepoUrl https://github.com/amaluga/aa-gh-source-control.git `
    -SourceType GitHub `
    -FolderPath "/LAB/$subsName/$AutomationAccount" `
    -Branch main `
    -AccessToken $PAT `
    -ResourceGroupName $resourceGroup `
    -AutomationAccountName $automationAccount `
    -EnableAutoSync:$true `
    -Confirm:$false
    
    
}

    



#region tests
$AA = $Aas[0]
$resourceGroup = $AA.ResourceGroupName
$automationAccount = $AA.AutomationAccountName
$subscriptionID = $AA.SubscriptionId

Start-AzAutomationSourceControlSyncJob `
-ResourceGroupName $resourceGroup `
-AutomationAccountName $automationAccount `
-Name "SCGitHub" `
-Debug
#endregion

