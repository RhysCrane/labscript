#Install new DC unattended in existing domain

function Install-DC-ExistingDomain{

   [CmdletBinding()]
   Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$DomainName,
	
   [Parameter(Mandatory=$True,Position=2)]
   [System.Management.Automation.CredentialAttribute()]
   [pscredential]$DomainCred,

   [Parameter(Mandatory=$True,Position=3)]
   [string]$SafeModeAdmPwd
    )

    #converrt pwd to secure string
    $SecureSafeModeAdmPwd = ConvertTo-SecureString -String $SafeModeAdmPwd -AsPlainText -Force

    #Install features and management tools (does core need that?)
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Install-ADDSDomainController –DomainName $DomainName -Credential $DomainCred -SafeModeAdministratorPassword $SecureSafeModeAdmPwd -Force -InstallDns

}

#main run functions
Install-DC-ExistingDomain