# rb-rotate-dkim-keys

This script is designed to run within an Azure Automation Runbook. It connects to Exchange Online using a Managed Identity and rotates the DKIM signing keys for all active custom domains in your tenant (excluding default `*.onmicrosoft.com` MOERA domains).

For each active custom domain, the script executes `Rotate-DkimSigningConfig` using the designated key size (1024 or 2048 bit). It then retrieves and outputs the updated DKIM configuration details as JSON objects for logging and auditing.

# Setup

This script configures the necessary permissions for an Azure Automation Managed Identity. It assigns the `Exchange.ManageAsApp` Graph API permission and grants the identity the built-in Entra ID 'Exchange Administrator' directory role.

```powershell
# 1) Connect to Microsoft Graph to manage app roles and directory roles
Connect-MgGraph -Scopes AppRoleAssignment.ReadWrite.All, Application.Read.All, RoleManagement.ReadWrite.Directory

# Provide the Object ID of the Azure Automation Managed Identity
$MI_ID = '<Copy Managed Identity Object ID from Azure Automation>'

# 2) Grant Managed Identity permissions to talk to Exchange Online Enterprise Application
# Resource ID for Exchange Online well-known service principal: 00000002-0000-0ff1-ce00-000000000000
$ResourceID = (Get-MgServicePrincipal -Filter "AppId eq '00000002-0000-0ff1-ce00-000000000000'").Id

# AppRoleId 'dc50a0fb-09a3-484d-be87-e023b12c6440' corresponds to Exchange.ManageAsApp
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MI_ID -PrincipalId $MI_ID -AppRoleId 'dc50a0fb-09a3-484d-be87-e023b12c6440' -ResourceId $ResourceID

# 3) Assign the Exchange Administrator directory role to the Managed Identity
$RoleDefinition = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq 'Exchange Administrator'"
New-MgRoleManagementDirectoryRoleAssignment -PrincipalId $MI_ID -RoleDefinitionId $RoleDefinition.Id -DirectoryScopeId '/'

```

# Parameters

There are two mandatory parameters that must be set for a job run:

- **Organization**: The Microsoft Online Email Routing Address (MOERA) domain for your tenant. Example: `contoso.onmicrosoft.com`.
- **KeySize**: The desired size of the private key for rotation. Accepted values are `1024` or `2048`.
