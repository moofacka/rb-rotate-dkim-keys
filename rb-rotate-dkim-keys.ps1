#Requires -Modules ExchangeOnlineManagement

<#
.SYNOPSIS
    Rotates Exchange Online DKIM keys for active custom domains using Azure Automation Managed Identity.

.DESCRIPTION
    This script connects to Exchange Online via Managed Identity and identifies all active DKIM
    configurations excluding default MOERA (*.onmicrosoft.com) domains.

    It executes a key rotation (`Rotate-DkimSigningConfig`) for each matching domain using the
    specified key size, then outputs the updated DKIM configuration details as JSON objects for
    logging and auditing purposes.

    Permissions:
    - Exchange.ManageAsApp

.NOTES
    Version History:
    0.0.1 - (2026-02-06) Initial script development
    0.0.2 - (2026-08-14) Updated header
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
$VerbosePreference = 'SilentlyContinue'

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
