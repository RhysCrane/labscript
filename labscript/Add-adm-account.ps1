#New adm User

function newadm{

   [CmdletBinding()]
   Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$AccountName,
	
   [Parameter(Mandatory=$True,Position=2)]
   [string]$AccountPwd
    )

    $securestring = ConvertTo-SecureString $AccountPwd -AsPlainText -Force
    
    #Administrator
    #If ou does not exist, create it   New-ADOrganizationalUnit -Name 'Administrator Accounts'
    if (!(Get-ADOrganizationalUnit -Filter {Name -like 'Administrator Accounts'})){
        
        New-ADOrganizationalUnit -Name 'Administrator Accounts'

    }


    #If $AccountName user does not exist, create it
    if (!(Get-ADUser -filter {SamAccountName -like $AccountName})){
    
        $OUPath = Get-ADOrganizationalUnit -Filter {Name -like 'Administrator Accounts'}
        New-ADUser -Name $AccountName -AccountPassword $securestring -Enabled $true -PasswordNeverExpires $true -Path $OUPath.DistinguishedName
        Get-ADGroup 'domain admins' | Add-ADGroupMember -Members $AccountName
    
    }
}

#run main
newadm