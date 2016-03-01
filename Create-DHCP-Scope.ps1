

function Create-DHCP-Scope{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$StartRange, # defualt values?? calc values from ip address on the domain server
	
        [Parameter(Mandatory=$True,Position=2)]
        [string]$EndRange, # defualt values??? calc values from ip address on the domain server

        $subnetMask # can this be calculated?
        $Name
        $Description #optional - default "This has been created by script Create-DHCP-Scope la la la"
    )



    #Set up DHCP ipv4
    Add-DhcpServerv4Scope -StartRange -EndRange -SubnetMask -Name -Description


    #authourise dhcp in AD
    Add-DhcpServerInDC


}

#set up DHCP ipv6
