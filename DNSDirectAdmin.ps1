<#
Usage:
- Put this script into the Scripts directory of win-acme
- Edit $server, $user and $password according to your DirectAdmin credentials
- Then execute win-acme with the following parameters as-is:
  --validationmode dns-01 --validation script --dnsscript .\Scripts\DNSDirectAdmin.ps1 --dnscreatescriptarguments "create {ZoneName} {NodeName} {Token}" --dnsdeletescriptarguments "delete {ZoneName} {NodeName} {Token}"
#>

$server = "https://example.com:2222" # May not end with a slash
$user = 'Username'
$password = 'PA$$w0rd'


# END of user-configured variables

$pair = "$user"+":"+"$password"
$action = $args[0]
$zone = $args[1]
$node = $args[2]
$encoded =  [Convert]::ToBase64String(
    [Text.Encoding]::UTF8.GetBytes($pair)
)
if($action -eq "create") {
    $token = $args[3]
    Invoke-WebRequest -Method Get -Uri "$server/CMD_API_DNS_CONTROL?domain=$zone&action=add&type=TXT&name=$node&value=$token" -Headers @{ Authorization = "Basic $encoded" } -Confirm:$false
}elseif($action -eq "delete") {
    Add-Type -AssemblyName System.Web
    $text = [System.Web.HttpUtility]::UrlEncode("name=$node&value="+$args[3])
    Invoke-WebRequest -Uri "$server/CMD_API_DNS_CONTROL?domain=$zone&action=select&txtrecs0=$text" -Headers @{ Authorization = "Basic $encoded" } -Confirm:$false
}
