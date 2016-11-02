workflow New-ARMStorageAccount
{
param    ([object]$WebHookData)
        if ($WebHookData -ne $null){
            $reqdatabody = $WebHookData.RequestBody
            $req = convertfrom-json $reqdatabody
            $credname = $req.user
            $subid = $req.subid
            $region = $req.region
            $resGrpName = $req.RGName
            $targetStoreType = $req.StoreType
            $targetStoreName = $req.StoreName
            $Creds = Get-AutomationPSCredential -Name $credname 
            $null = Login-AzureRmAccount -Environment (Get-AzureRmEnvironment -name AzureCloud) -Credential $Creds
            $null = Get-AzureRmSubscription -SubscriptionId $subID
            $stor = New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $TargetStorageName -Type $TargetStorageType -Location $region
            $out = convertto-json $stor
            write-output $out
        }
        else
        {write-output "Failed to have Data entered"}
}