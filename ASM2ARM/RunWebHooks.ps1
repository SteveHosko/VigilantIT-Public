 function Run-Webhook{
param (
[object]$body,
[string]$webhook
)

<#
  Example to demonstrate Web API hooks for Azure Automation Workflows
#>
$adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
[System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
[System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null

#// Constants
#PowerShell ClientID
[string]$ClientId              = '1950a258-227b-4e31-a9cf-717495945fc2'
[string]$redirectUri           = 'urn:ietf:wg:oauth:2.0:oob' #####
[string]$resourceAppIdURI      = 'https://management.azure.com/'

#// Unique Azure Account Information
[string]$ResourceGroup         = "ASM2ARM"
[string]$AutomationAccount     = "ASM2ARM-Migration"
[string]$adTenant              = "infinitisarm.onmicrosoft.com"
[string]$SubscriptionId        = "6a4a05b9-9940-47da-8d14-481457f42370"

#// Construct a Token request payload and request header - then submit via POST

$authority = "https://management.core.windows.net/"
$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList "https://login.windows.net/$adTenant/"
$authResultARM = $authContext.AcquireToken($authority, $clientId, $redirectUri, "Auto")
$authHeader = $authResultARM.CreateAuthorizationHeader()

#// +--------------------
#// Construct Azure Automation Runbook Invocation
#// The proviously returned token is used in the Autorisation Header
#// 
#// +--------------------

$RequestHeader = @{
  "Content-Type" = "application/json";
  "x-ms-version" = "2014-10-01";
  "Authorization" = $authHeader
}


#// Declare the body of the POST request - including any input
#// parameters that may be required
        

$Response = Invoke-RestMethod -Uri $webhook -Method Post -body $body -Headers $requestHeader

#// +--------------------
#// Check the submitted job status
#// & poll until the job is completed
#// 
#// +--------------------
$jobid = $Response.JobIds

$URI = "https://management.azure.com/subscriptions/$($subscriptionId)/"`
      +"resourceGroups/$($ResourceGroup)/providers/Microsoft.Automation/"`
      +"automationAccounts/$($AutomationAccount)/Jobs/"`
      +"$($JobId)?api-version=2015-10-31"

$doLoop = $true
While ($doLoop) {
   $job = Invoke-RestMethod -Uri $URI -Method GET -Headers $RequestHeader
   $status = $job.properties.provisioningState
   $doLoop = (($status -ne "Succeeded") -and 
   ($status -ne "Failed") -and ($status -ne "Suspended") -and 
   ($status -ne "Stopped"))
}

#// +--------------------
#// Retrieve the Output stream from the Runbook Job
#// 
#// +--------------------

$URI  = "https://management.azure.com/subscriptions/$($subscriptionId)/"`
      +"resourceGroups/$($ResourceGroup)/providers/Microsoft.Automation/"`
      +"automationAccounts/$($AutomationAccount)/jobs/$($jobid)/"`
      +"output?api-version=2015-10-31" 

$response = Invoke-RestMethod -Uri $URI -Method GET -Headers $requestHeader

$Response}


#region Subs
$webhooksub = "https://s8events.azure-automation.net/webhooks?token=Bj4jKctLhZG6Kgfoz5J1tVbPySADsTEeNqlVm6t6xm8%3d"

$sourceid  = @(
            @{ name="SourceMig"}
        )
$sourcebody = ConvertTo-Json -InputObject $sourceid

$sourcesub = Run-Webhook -body $sourcebody -webhook $webhooksub

$targetid  = @(
            @{ name="targetMig"}
        )
$targetbody = ConvertTo-Json -InputObject $targetid
$targetsub = Run-Webhook -body $targetbody -webhook $webhooksub

#endregion  

$selectedSourceSub = $sourcesub | ogv -PassThru
$selectedtargetsub = $targetsub | ogv -PassThru

#region sourceVMs
$webhookVMs = "https://s8events.azure-automation.net/webhooks?token=9aIZPriTHf3V0IST%2fgU6dk10pkzLktyiLcT1JFrfp38%3d"

$sourcesubid  = @(
            @{ user="SourceMig"; subid=$selectedSourceSub.SubscriptionId}
        )
$sourcesubbody = ConvertTo-Json -InputObject $sourcesubid

$sourcevms = Run-Webhook -body $sourcesubbody -webhook $webhookVMs
#endregion

$selectedSourceVM = $sourcevms | ogv -PassThru
$selectedSourceVM

#region Get Azure Regions
$webhookRegions = "https://s8events.azure-automation.net/webhooks?token=s5M7%2bh5%2bB%2fthSlx04%2bJsBuoa6iRvt0dmvSEQWoqkIjc%3d"

$regionid = @(
            @{ name="SourceMig"}
        )
$regionbody = ConvertTo-Json -InputObject $regionid
$regions = Run-Webhook -body $regionbody -webhook $webhookRegions
#endregion

$selectedRegion = $regions | ogv -PassThru
$selectedRegion

#region ResourceGroups
$webhookRGs = "https://s8events.azure-automation.net/webhooks?token=Rt5E645qYPmKRZJnjp%2fq1NYz64qEn%2fgHvj2SgovkYVw%3d"

$RGIds  = @(
            @{ user="SourceMig"; subid=$selectedSourceSub.SubscriptionId}
        )
$RGBody = ConvertTo-Json -InputObject $RGIds

$RGs = Run-Webhook -body $RGBody -webhook $webhookRGs
#endregion

$SelectedRG = $rgs | ogv -PassThru
$SelectedRG

#region VNets
$webhookvNets = "https://s8events.azure-automation.net/webhooks?token=m0TGyPUBCrtiQ2fbTHk4m2Blhus0DQeJLr%2fYeoN3Qk0%3d"

$vNetIDs = @(
             @{ user="SourceMig"; subid=$selectedSourceSub.SubscriptionId; CloudService=$selectedSourceVM.CloudService}
             )
$vNetBody = ConvertTo-Json -InputObject $vNetIDs

$vNets = Run-Webhook -body $vNetBody -webhook $webhookvNets
#endregion

$selectedvNet = $vNets | ? {$_.ResourceType -eq 'Microsoft.ClassicNetwork/virtualNetworks'}
$selectedvNet
$selectedVStorage = $vNets | ? {$_.ResourceType -eq 'Microsoft.ClassicStorage/storageAccounts'}
$selectedVStorage

#region NewRG
$webhookNewRG = "https://s8events.azure-automation.net/webhooks?token=EFBHW1RUlIHEqEKtg%2bglAO%2fs3%2fdDJTD5KqdvrPovaF4%3d"

$NewRgIDs =  @(
             @{ user="targetMig"; subid=$selectedtargetsub.SubscriptionId; RGName=$selectedSourceVM.CloudService; region=$selectedRegion.Location}
             )
$NewRgBody = ConvertTo-Json -InputObject $NewRgIDs

$newrg = Run-Webhook -body $NewRgBody -webhook $webhookNewRG

#endregion

#region NewStor
$webhookNewStor = "https://s8events.azure-automation.net/webhooks?token=AjZVAc3QPQtfa6jzJfH3L513KYmpltQNNs9bqpYe%2frQ%3d"

$NewStorIDs = @(
             @{ user="targetMig"; subid=$selectedtargetsub.SubscriptionId; RGName=$selectedSourceVM.CloudService; region=$selectedRegion.Location; StoreType='Standard_GRS'; StoreName="demostorage3563"}
             )
$NewStorBody = ConvertTo-Json -InputObject $NewStorIDs

$newStor = Run-Webhook -body $NewStorBody -webhook $webhookNewStor

#endregion

#region StorageKeys
$webhookstoragekeys = "https://s8events.azure-automation.net/webhooks?token=%2bW8ZgLRQR15EYdnZha7xeA%2f1g4%2ffn9%2fIG9M7ri0Bb6w%3d"

$StoragekeysIDs = @(
             @{ user="targetMig"; subid=$selectedtargetsub.SubscriptionId; RGName=$selectedSourceVM.CloudService; region=$selectedRegion.Location; StoreName="demostorage3563"}
             )
$StoragekeysBody = ConvertTo-Json -InputObject $StoragekeysIDs

$StorageKeys = Run-Webhook -body $StoragekeysBody -webhook $webhookstoragekeys

#endregion