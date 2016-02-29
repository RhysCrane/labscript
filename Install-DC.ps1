#Set up DC and a basic new domain unattended given input parameters


function Install-ADDS-CreateDomain{

   [CmdletBinding()]
   Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$DomainName,
	
   [Parameter(Mandatory=$True,Position=2)]
   [string]$SafeModeAdmPwd
    )

    #Install features and management tools (does core need that?)
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

    #Set up domain
    $SecureSafeModeAdmPwd = ConvertTo-SecureString -String $SafeModeAdmPwd -AsPlainText -Force
    Install-ADDSForest –DomainName $DomainName -SafeModeAdministratorPassword $SecureSafeModeAdmPwd -DomainMode Win2012R2 -ForestMode Win2012R2 -InstallDNS -Force

    #Restarts - remove the warning?
    #Log output somewhere
}

#main run functions
Install-ADDS-CreateDomain