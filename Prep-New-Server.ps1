#Prep computer - Basic setup tasks tasks

#run common tasks for new vm - tested working on 2012R2 - 27/01/16 
function New-VM-Prep{

   [CmdletBinding()]
   Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$ComputerName,

   [Parameter(Mandatory=$True,Position=2)]
   [string]$ipaddr
    )


    #Set for powershell remoting
    winrm quickconfig -force

    #Set to respond to ping
    Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"

    #Rename computer 
    Rename-Computer -NewName $ComputerName

    #Set static IPv4 and a defualt gateway of .1 on whatever /24 subnet ip adddress is
    $gateway = (([ipaddress] $ipaddr).GetAddressBytes()[0..2] -join "." ) + ".1"
    New-NetIPAddress -IPAddress $ipaddr -InterfaceAlias 'Ethernet' -DefaultGateway $gateway -PrefixLength 24
   
    #IPv6 settings go here - automatic subnetting using host bits from ipv4 address (update this to ipv4 in ipv6 format at a later date???)
    $ipv6addr = "fd35:28e6:fa3c::" + $ipaddr
    $ipv6addr = $ipv6addr -replace '\.',':'
    New-NetIPAddress -IPAddress $ipv6addr -AddressFamily IPv6 -InterfaceAlias 'Ethernet' -DefaultGateway "fd35:28e6:fa3c::1" -PrefixLength 48

    #ip dns
    Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddresses ('10.0.0.2','fd35:28e6:fa3c:0:10::2')

    Restart-Computer -Force
    #Report results
}

New-VM-Prep