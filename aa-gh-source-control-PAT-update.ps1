Connect-AzAccount -tenant '<tenantID>' #Modify: tenantID
$subscriptionID = '<subscriptionID>' #Modify: subscriptionID

$subsName = (Get-AzSubscription -SubscriptionId $subscriptionID).Name
$AAs = Get-AzAutomationAccount


$PAT = ConvertTo-SecureString -String '<PAT>' -AsPlainText -Force #Modify: PAT

foreach($AA in $AAs){
    $resourceGroup = $AA.ResourceGroupName
    $automationAccount = $AA.AutomationAccountName
    $subscriptionID = $AA.SubscriptionId
    

    Update-AzAutomationSourceControl `
    -Name 'SCGithub' `
    -ResourceGroupName $resourceGroup `
    -AutomationAccountName $automationAccount `
    -AccessToken $PAT `
    -Confirm:$false
    
}