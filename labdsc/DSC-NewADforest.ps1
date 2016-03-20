$ConfigData =@{
    AllNodes = @(
        @{NodeName = 'localhost';
          PSDSCAllowPlainTextPassword = $True
          }
    )

}

Configuration BuildDC{

    Param(

        [parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$NodeName,

        [parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$ComputerName,

        [parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$Domain,

        [parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$IP,

        [parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$Gateway,

        [parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [string]$Subnet

        #[pscredential]$DomainAdminCred,
        #[pscredential]$SafeModeAdminCred

    )#Param

    #unsecure, not safe or recommended way to do this
    $Creds = ConvertTo-SecureString "Password1" -AsPlainText -Force
    $DomainAdminCred = New-Object System.Management.Automation.PSCredential ("Administrator", $Creds)
    $SafeModeAdminCred = New-Object System.Management.Automation.PSCredential ("Administrator", $Creds)

    Import-DscResource -ModuleName xActiveDirectory,xNetworking,xComputerManagement,xPendingReboot,xSystemSecurity,xRemoteDesktopAdmin,xDhcpServer,xTimeZone,xWinEventLog,PSDesiredStateConfiguration

    Node $NodeName{

        LocalConfigurationManager{
            RebootNodeifNeeded = $True
        }

        xComputer RenameDC{
           Name = $ComputerName
       }

        File Scripts{
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = "C:\Scripts"
        }

        xIEESC SetAdminIEESC{
            UserRole = "Administrators"
            IsEnabled = $False           
        }

        xUAC UAC{
            Setting = "NeverNotifyAndDisableAll"         
        }

        xTimeZone ServerTime{
            TimeZone = "Central Standard Time"

        }

        xRemoteDesktopAdmin RemoteDesktopSettings
        {
           Ensure = 'Present'
           UserAuthentication = 'Nonsecure'
        }

        xIPAddress SiteDCIP{
            IPAddress = $IP
            DefaultGateway = $Gateway
            SubnetMask = $Subnet
            AddressFamily = "IPv4"
            InterfaceAlias = "Ethernet"
            DependsOn = "[File]Scripts"
        }

        WindowsFeature AD-Domain-Services {
            Ensure = "Present"
            Name   = "AD-Domain-Services"
            DependsOn = "[xIPAddress]SiteDCIP"
        }
        WindowsFeature RSAT-AD-AdminCenter {
            Ensure = "Present"
            Name   = "RSAT-AD-AdminCenter"
        }
        WindowsFeature RSAT-ADDS {
            Ensure = "Present"
            Name   = "RSAT-ADDS"
        }
        WindowsFeature RSAT-AD-PowerShell {
            Ensure = "Present"
            Name   = "RSAT-AD-PowerShell"
        }
        
        WindowsFeature Telnet-Client{
            Ensure = "Present"
            Name = "Telnet-Client"
        }

        Service ADDomainWebServices{
            State = "Running"
            StartupType = "Automatic"
            BuiltInAccount = "LocalSystem"
            Name = "ADWS"
        }

        xADDomain BuildSiteDC{
            DomainAdministratorCredential = $DomainAdminCred
            SafeModeAdministratorPassword = $SafeModeAdminCred
            DomainName = $Domain
            DependsOn = "[WindowsFeature]AD-Domain-Services","[Service]ADDomainWebServices"                     
        }


        xPendingReboot PostDomainDeploy{
            Name = "Test for reboot after building a domain"
        }
        

        xDNSServerAddress DCDNS{
            Address = $IP
            InterfaceAlias = "Ethernet"
            AddressFamily = "IPv4"
            DependsOn = "[xPendingReboot]PostDomainDeploy"
        }
        

        xWinEventLog DirectoryService{
            LogName = "Directory Service"
            DependsOn = "[xDNSServerAddress]DCDNS"
            LogMOde = "Circular"
            MaximumSizeInBytes = 16MB
        }
        

        #Install dhcp
        WindowsFeature InstallDHCP {
            Ensure       = "Present"
            Name         = "DHCP"
            DependsOn    = "[xADDomain]BuildSiteDC"
        }


        #DHCP setup
        xDhcpServerScope NewDHCPScope {
            IPStartRange         = ((([ipaddress]$IP).GetAddressBytes()[0..2] -join "." ) + ".21")
            IPEndRange           = ((([ipaddress]$IP).GetAddressBytes()[0..2] -join "." ) + ".39")
            Name                 = "VirtualBoxLab"
            SubnetMask           = $Subnet
            State                = "Active"
            Ensure               = "Present"
            DependsOn            = "[WindowsFeature]InstallDHCP"
        }



    }#Node


}#Configuration
$ScriptPath = 'C:\Scripts\BuildDC'

BuildDC -NodeName localhost -Domain YourDomain.com -IP 10.0.0.2 -Gateway 10.0.0.1 -Subnet 24 -OutputPath $ScriptPath -ConfigurationData $ConfigData -ComputerName 'DC01'
Set-DscLocalConfigurationManager -Path $ScriptPath
Get-DSCLocalConfigurationManager
Start-DscConfiguration -Wait -Force -Verbose -Path $ScriptPath