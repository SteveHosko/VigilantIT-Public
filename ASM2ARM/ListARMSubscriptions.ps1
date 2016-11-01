$SourceCreds = Get-AutomationPSCredential -Name 'SourceMig'
$SourceAzure = Get-AzureRmEnvironment 'AzureCloud'
$SourceEnv = Login-AzureRmAccount -Credential $SourceCreds -Environment $SourceAzure -Verbose
Select-AzureRmProfile -Profile $SourceEnv | out-null
$SourceSubscription = Get-AzureRmSubscription
return $SourceSubscription