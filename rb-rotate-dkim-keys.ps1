#Requires -Modules @{ ModuleName = "ExchangeOnlineManagement"; ModuleVersion = "3.6.0" }

<#
.SYNOPSIS
    An Azure Automation runbook that rotates DKIM keys for accepted domains in Exchange Online.

.DESCRIPTION
    This runbook will rotate DKIM keys for all enabled accepted domains in Exchange Online.

.NOTES
    Version History:
    0.0.1 - (2026-02-06) Inital script development
#>

param (
    [Parameter(Mandatory = $True, HelpMessage = 'Specify MOERA domain, e.g contoso.onmicrosoft.com.')]
    [ValidateNotNullorEmpty()]
    [System.String]$Organization,
    [Parameter(Mandatory = $True, HelpMessage = 'Specify the size of the private key, e.g 1024 or 2048.')]
    [ValidateSet('1024', '2048')]
    [System.Int16]$KeySize
)

$ErrorActionPreference = 'Stop'

trap {
    Write-Error "Unhandled error caught: $($_.Exception.Message)"
    break
}

Connect-ExchangeOnline -ManagedIdentity -Organization $Organization -ShowBanner:$False
Write-Verbose 'Connected to Exchange Online' -Verbose

$Domains = Get-DkimSigningConfig | Where-Object { $_.Enabled -match 'True' -and $_.Domain -notlike '*.onmicrosoft.com' }
$Domains | ForEach-Object {
    Rotate-DkimSigningConfig -Identity $_.Name -KeySize $KeySize
    $Domain = Get-DKImSigningConfig -Identity $_.Name | Select-Object Identity, RotateOnDate, SelectorBeforeRotateOnDate, SelectorAfterRotateOnDate, Selector1KeySize, Selector2KeySize, Status
    Write-Output ($Domain | ConvertTo-Json)
}
