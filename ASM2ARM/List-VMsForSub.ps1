workflow List-VMsForSub
{
        param    ([object]$WebHookData)
        if ($WebHookData -ne $null){
            $reqdatabody = $WebHookData.RequestBody
        $req = convertfrom-json $reqdatabody
                $credname = $req.user
                $subID = $req.subid
$Creds = Get-AutomationPSCredential -Name $credname 
$null = Login-AzureRmAccount -Environment (Get-AzureRmEnvironment -name AzureCloud) -Credential $Creds
$null = Get-AzureRmSubscription -SubscriptionId $subID
$VMs = Find-AzureRmResource -ExpandProperties | ? {$_.ResourceType -eq 'Microsoft.ClassicCompute/virtualMachines'} | `
select Name,Location,`
@{Name='CloudService';Expression={$_.ResourceGroupName}},`
@{Name='VirtualNetworkName';Expression={$_.properties.networkprofile.virtualnetwork.name}},`
@{Name='PowerState';Expression={$_.properties.instanceview.powerstate}}
$out = ConvertTo-Json $VMs
Write-Output $out
                }
        else
        {write-output "Failed to have Data entered"}
}