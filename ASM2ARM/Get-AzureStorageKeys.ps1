workflow Get-AzureStorageKeys
{
param    ([object]$WebHookData)
        if ($WebHookData -ne $null){
            $reqdatabody = $WebHookData.RequestBody
            $req = convertfrom-json $reqdatabody
            $credname = $req.user
            $subid = $req.subid
            $region = $req.region
            $resGrpName = $req.RGName
            $StoreName = $req.StoreName
            $Creds = Get-AutomationPSCredential -Name $credname 
            $null = Login-AzureRmAccount -Environment (Get-AzureRmEnvironment -name AzureCloud) -Credential $Creds
            $null = Get-AzureRmSubscription -SubscriptionId $subID
            $storkey = Get-AzureRmStorageAccountKey -Name $StoreName -ResourceGroupName $resGrpName
            $out = convertto-json $storkey
            write-output $out
        }
        else
        {write-output "Failed to have Data entered"}
}