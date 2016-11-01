workflow List-VMResources
{
 param    ([object]$WebHookData)
        if ($WebHookData -ne $null){
            $reqdatabody = $WebHookData.RequestBody
        $req = convertfrom-json $reqdatabody
                $credname = $req.user
                $subID = $req.subid
                $sourceCS = $req.CloudService
$Creds = Get-AutomationPSCredential -Name $credname 
$null = Login-AzureRmAccount -Environment (Get-AzureRmEnvironment -name AzureCloud) -Credential $Creds
$null = Get-AzureRmSubscription -SubscriptionId $sourcesub.SubscriptionId
$VMs = Find-AzureRmResource -ExpandProperties | ? {$_.ResourceType -eq 'Microsoft.ClassicCompute/virtualMachines'} | `
select Name,Location,`
@{Name='CloudService';Expression={$_.ResourceGroupName}},`
@{Name='VirtualNetworkName';Expression={$_.properties.networkprofile.virtualnetwork.name}},`
@{Name='PowerState';Expression={$_.properties.instanceview.powerstate}}
$sourceresources = Get-AzureRmResource -ExpandProperties
$csvms = $sourceresources | ? {$_.ResourceGroupName -eq $sourceCS -and $_.ResourceType -eq 'Microsoft.ClassicCompute/virtualMachines'}
$vNetName = $CSVMResources.properties.networkprofile.virtualnetwork.name[0]
$CSvNetResource = $SourceResources | ? {$_.ResourceName -eq $vNetName -and $_.ResourceType -eq 'Microsoft.ClassicNetwork/virtualNetworks'}
if($vNetName){$vNetName = $vNetName -Replace '\W',''}
$int = 1
$CSVMResources | % {$_ | Add-Member @{Int=$int};$int++}
write-output $out
        }
        else
        {write-output "Failed to have Data entered"}
}