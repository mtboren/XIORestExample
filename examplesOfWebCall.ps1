
## get some creds
$credToUse = Get-Credential
## REST method body params
$hshNewSnapItems = @{
	"from-consistency-group-id" = "mattTestCG0"
	"to-snapshot-set-id" = "SnapshotSet.1455487516618"
	# "no-backup" = $true
}

## the core cmdlet to invoke
Invoke-RestMethod -Uri "https://somexms.dom.com/api/json/v2/types/snapshots" -Method Post -Body ($hshNewSnapItems | ConvertTo-Json) -Headers @{Authorization = (Get-BasicAuthStringFromCredential -Credential $credToUse)}





## supporting stuff
function Get-BasicAuthStringFromCredential {
<#	.Description
	Function to get a Basic authorization string value from a PSCredential.  Useful for creating the value for an Authorization header item for a web request, for example.  Based on code from Don Jones at http://powershell.org/wp/forums/topic/http-basic-auth-request/
	.Outputs
	String
#>
	param(
		[parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$Credential
	) ## end param

	return "Basic $( [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($Credential.UserName.TrimStart('\')):$($Credential.GetNetworkCredential().Password)")) )"
} ## end function

## account for non-legit certificates
$oOrigServerCertificateValidationCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
