workflow NewARMResGroup
{
        param    ([object]$WebHookData)
        if ($WebHookData -ne $null){
            $reqdatabody = $WebHookData.RequestBody
        $req = convertfrom-json $reqdatabody
        $credname = $req.user
        $subid = $req.subid
        $region = $req.region
        $resGrpName = $req.RGName
$Creds = Get-AutomationPSCredential -Name $credname 
$null = Login-AzureRmAccount -Environment (Get-AzureRmEnvironment -name AzureCloud) -Credential $Creds
$null = Get-AzureRmSubscription -SubscriptionId $subID
if(!(Get-AzureRmResourceGroup -Name $resGrpName -Location $region -ErrorAction SilentlyContinue)){
$rg = New-AzureRmResourceGroup -Name $resGrpName -Location $region -Force}
$out = convertto-json $rg
write-output $out
        }
        else
        {write-output "Failed to have Data entered"}
}