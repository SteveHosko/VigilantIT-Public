workflow List-VMResources
{
 param    ([object]$WebHookData)
        if ($WebHookData -ne $null)
        {
            $reqdatabody = $WebHookData.RequestBody
            $req = convertfrom-json $reqdatabody
            $credname = $req.user
            $subID = $req.subid
            $sourceCS = $req.CloudService
            $Creds = Get-AutomationPSCredential -Name $credname 
            $null = Login-AzureRmAccount -Environment (Get-AzureRmEnvironment -name AzureCloud) -Credential $Creds
            $null = Get-AzureRmSubscription -SubscriptionId $subID
            $sourceresources = Get-AzureRmResource -ExpandProperties | ? {$_.ResourceGroupName -eq $sourcecs}
            $out = convertto-json $sourceresources
            write-output $out
        }
        else
        {write-output "Failed to have Data entered"}
}

