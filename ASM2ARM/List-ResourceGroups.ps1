workflow List-ResourceGroups
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
$RGs = Get-AzureRmResourceGroup
$out = ConvertTo-Json $RGs
Write-Output $out
                }
        else
        {write-output "Failed to have Data entered"}
}