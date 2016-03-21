#Script to set up x servers
#Should be run as administrator
#20/03/2016 - creation
#date - added this
#

#Function to create new vm using a template 2012R2 install - only update administrator password has been changed

function New-VMHyperV{
    
    param (

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [string]$ComputerName,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [string]$VhdxTemplate,

        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=2)]
        [int32]$StartupBytes,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=3)]
        [string]$VSwitch



    )

    #Will run once for all objects
    Begin {
    }

    #Will run once for each object
    Process {

        $NewVMPath = 'D:\Hyper-V_VMs\Virtual Hard Disks\' + $ComputerName + '.vhdx'

        #new-VM
        New-VM -Name $ComputerName -MemoryStartupBytes $StartupBytes -Generation 2 -SwitchName $VSwitch -Verbose

        #Copy vhd to new vm directory
        Copy-Item -Path $VhdxTemplate -Destination $NewVMPath -Verbose

        #Add vhd to vm
        Add-VMHardDiskDrive -VMName $ComputerName -Path $NewVMPath -Verbose

        #set vm boot device to vhd
        $vmHardDiskDrive = Get-VMHardDiskDrive -VMName $ComputerName –ControllerType SCSI -ControllerNumber 1
        Set-VMFirmware -VMName $ComputerName -FirstBootDevice $vmHardDiskDrive

        #Start VM
        Start-VM -Name $ComputerName
    
    }


    #Will run once for all objects
    End {
    }
    
}


$ComputerName = (Read-Host('Enter the new VM Name: '))
$VSwitch = 'External Switch'
$StartupBytes = 1GB
$VhdxTemplate = 'D:\Hyper-V_VMs\Template VHDX\2012R2.vhdx'

New-VMHyperV -ComputerName $ComputerName -VhdxTemplate $VhdxTemplate -StartupBytes $StartupBytes -VSwitch $VSwitch
