# rb-rotate-dkim-keys

```powershell
$ServicePrincipalId = '<ObjectId>'
$ServicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '00000002-0000-0ff1-ce00-000000000000'"
$AppRole = $ServicePrincipal.AppRoles | Where-Object { $_.Value -eq 'Exchange.ManageAsApp' -and $_.AllowedMemberTypes -contains 'Application' }
$BodyParameter = @{
    PrincipalId = $ServicePrincipalId
    ResourceId  = $ServicePrincipal.Id
    AppRoleId   = $AppRole.Id
}
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ServicePrincipalId -BodyParameter $BodyParameter
```

## SYNOPSIS
    An Azure Automation runbook that rotates DKIM keys for accepted domains in Exchange Online.

## DESCRIPTION
    This runbook will rotate DKIM keys for all enabled accepted domains in Exchange Online.

## PARAMETER Organization
    [Mandatory] MOERA domain of the organization, contoso.onmicrosoft.com.

## PARAMETER Organization
    [Mandatory] Size of the private key, e.g 1024 or 2048.
