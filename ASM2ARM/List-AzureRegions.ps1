workflow List-AzureRegions
{
 param    ([object]$WebHookData)
        if ($WebHookData -ne $null){
            $reqdatabody = $WebHookData.RequestBody
        $subname = convertfrom-json $reqdatabody
        $credname = $subname.name
$Creds = Get-AutomationPSCredential -Name $credname 
$null = Login-AzureRmAccount -Environment (Get-AzureRmEnvironment -name AzureCloud) -Credential $Creds
$regions = Get-AzureRmLocation | Select Location, DisplayName
$out = convertto-json $regions
Write-Output $out
}
}