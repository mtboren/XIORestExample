function Update-XIOSnapshotSetFromCG {
<#	.Description
	Function to update a snapshot set from a consistency group. This is meant to be an example of how to invoke the XIO REST API to perform such operation. The "real" Update-XIOSnapshot function will support all of the "from" and "to" options:
		from consistencygroup, from snapshotset, or from volume
		to consistencygroup, to snapshotset, or to volume
	.Example
	Update-XIOSnapshotSetFromCG -Backup -ComputerName somexms.dom.com -Credential $credMe -FromConsistencyGroup mattTestCG0 -ToSnapshotSet SnapshotSet.1455487516618
	Update the given SnapshotSet form the given Consistency Group, and make a backup SnapshotSet of the original SnapshotSet
#>
	param(
		## Name of XMS to which to connect to perform action
		[parameter(Mandatory=$true)]$ComputerName,
		## Credential to use for connecting to XMS
		[parameter(Mandatory=$true)]$Credential,
		## Name of Consistency Group from which to update item
		[parameter(Mandatory=$true)][string]$FromConsistencyGroup,
		## Name of SnapshotSet to update from Consistency Group
		[parameter(Mandatory=$true)][string]$ToSnapshotSet,
		## Switch:  Keep a backup of the destination SnapshotSet?
		[switch]$Backup
	)

	process {
		## make the parameter hashtable from which to make the JSON body for the request
		$hshReqBodyForCreateAndReassign = @{
			"from-consistency-group-id" = $FromConsistencyGroup
			"to-snapshot-set-id" = $ToSnapshotSet
		}
		if (-not $Backup) {$hshReqBodyForCreateAndReassign["no-backup"] = $true}

		## make the hashtable for the params for invoking the request
		$hshParamForReq = @{
			Uri = "https://$ComputerName/api/json/v2/types/snapshots"
			## does not work in testing against XMS's apparent desire for Basic Auth -- need to use Authorization header
			# Credential = $Credential
			Body = $hshReqBodyForCreateAndReassign | ConvertTo-Json
			Method = "Post"
			Headers = @{Authorization = (Get-BasicAuthStringFromCredential -Credential $Credential)}
		}

		## call in traditional way with named parameters
		# Invoke-RestMethod -Uri <someUri> -Credential $Credential -Body <somethingToGetJson> -Method Post
		Invoke-RestMethod @hshParamForReq
	}
}


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



<# fundamentals:
	JSON creation from data structure (instead of trying to craft JSON strings manually)
	Creds handling
	Certificates
		$oOrigServerCertificateValidationCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
		[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
	Parameter "splatting"
	REST method invocation
	not covered here:
		XMS computer name validation (valid DNS entry, responsive, etc.)
		pre-POST validation:  ensure that source Consistency Group and destination SnapshotSet exist
		add ShouldProccess() support ("-WhatIf" support)
		return meaningful objects upon success, not just some HREFs
#>