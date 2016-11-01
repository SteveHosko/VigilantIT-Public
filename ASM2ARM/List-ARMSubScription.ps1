workflow List-ARMSubScription
{
        param    ([object]$WebHookData)
        if ($WebHookData -ne $null){
            $reqdatabody = $WebHookData.RequestBody
        $subname = convertfrom-json $reqdatabody
        $credname = $subname.name
$Creds = Get-AutomationPSCredential -Name $credname 
$null = Login-AzureRmAccount -Environment (Get-AzureRmEnvironment -name AzureCloud) -Credential $Creds
$subs = Get-AzureRmSubscription
$out = convertto-json $subs
write-output $out
        }
        else
        {write-output "Failed to have Data entered"}
}