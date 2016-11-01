$SourceTargetTenant = Get-AutomationVariable -Name 'SourceTargetTenant'

#region Logon to Source & Target environment | @marckean
if($SourceTargetTenant -eq 'No'){
# Logon to Source environment | @marckean

    $SourceCreds = Get-AutomationPSCredential -Name 'SourceMig'
    $SourceAzure = Get-AzureRmEnvironment 'AzureCloud'
    $SourceEnv = Login-AzureRmAccount -Credential $SourceCreds -Environment $SourceAzure -Verbose

# Logon to Target environment | @marckean

    $TargetCreds = Get-AutomationPSCredential -Name 'TargetMig'
    $TargetAzure = Get-AzureRmEnvironment 'AzureCloud'
    $TargetEnv = Login-AzureRmAccount -Credential $TargetAzure -Environment $TargetAzure -Verbose

} else {

# Logon to Azure environment | @marckean

    $MigrationCreds = Get-AutomationPSCredential -Name 'SourceMig'
    $MigrationAzure = Get-AzureRmEnvironment 'AzureCloud'
    $MigrationEnv = Login-AzureRmAccount -Environment $MigrationAzure -Verbose
}
#endregion

#region Select a source & target subscription | @marckean

if($SourceTargetSubscription -eq 'No'){
    Select-AzureRmProfile -Profile $SourceEnv
    $SourceSubscription = (Get-AzureRmSubscription | Out-GridView -Title "Choose a Source Subscription ..." -PassThru)
    $SourceSubscriptionID = $SourceSubscription.SubscriptionId
    $SourceSubscriptionName = $SourceSubscription.SubscriptionName

# Select a target subscription

    Select-AzureRmProfile -Profile $TargetEnv
    $TargetSubscription = (Get-AzureRmSubscription | Out-GridView -Title "Choose a Target Subscription ..." -PassThru)
    $TargetSubscriptionID = $TargetSubscription.SubscriptionId
    $TargetSubscriptionName = $TargetSubscription.SubscriptionName

} else {

# Select a subscription

    Select-AzureRmProfile -Profile $MigrationEnv
    $MigrationSubscription = (Get-AzureRmSubscription | Out-GridView -Title "Choose a Source & Target Subscription ..." -PassThru)
    $MigrationSubscriptionID = $MigrationSubscription.SubscriptionId
    $MigrationSubscriptionName = $MigrationSubscription.SubscriptionName
}


#Login Source ('old' Azure) | @marckean
cls
Write-Host "`nEnter credentials for Azure Classic..." -ForegroundColor Cyan
Add-AzureAccount
if($SourceTargetSubscription -eq 'No'){
Select-AzureSubscription $SourceSubscription.SubscriptionName
} else {
Select-AzureSubscription $MigrationSubscription.SubscriptionName
}
#endregion