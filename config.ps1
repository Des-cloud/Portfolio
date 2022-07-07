#This script handles the configuration of a VM when a new VM is added to the agent pool

#Creating a log file
$logfile = New-Item -Path 'C:\VMCreationExtension\Logs' -Name 'Hyper-V-Logs.txt' -Force
$date = "$((Get-Date).ToString('HH:mm:ss')) + /r/n/r/n"
Add-Content -Path $logfile -Value $date

#Checking/Installing hyper-v module
Add-Content -Path $logfile -Value "Checking/Installing hyper-v module./r/n/"
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online

if ($hyperv.State -eq 'Enabled') {
   Add-Content -Path $logfile -Value "Hyper-V is already installed and enabled./r/n/r/n"
} else {
   Add-Content -Path $logfile -Value "Hyper-V is not installed/enabled./r/n/"
   Add-Content -Path $logfile -Value "Installing Hyper-V./r/n"

   #Install Hyper-V
   Add-WindowsFeature Hyper-V,Hyper-V-Tools,Hyper-V-PowerShell -IncludeManagementTools -IncludeAllSubFeature 
   
   #Checking if installation was successful
   $hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online
   if ($hyperv.State -eq 'Enabled') {
      Add-Content -Path $logfile -Value "Hyper-V is installed and enabled./r/n/r/n"
   } else {
      Add-Content -Path $logfile -Value "Hyper-V could not be installed or enabled./r/n/r/n"
      Exit -1
   }
}

#Network switch configuration
Add-Content -Path $logfile -Value "Network switch configuration./r/n/"

#Getting network adapters
$netadapter = @()
$netadapter = Get-NetAdapter

#Loop through network adapters to get the interface index of adapter we want
$adapterName = 'Ethernet'
$InterfaceIndex = -9999
foreach($adapter in $netadapter)
{
   #Log name of Adapter
   $name = $adapter.name
   Add-Content -Path $logfile -Value "$name ./r/n/r/n"
   if(($adapter.name).Contains($adapterName))
   {
      $InterfaceIndex = $adapter.ifIndex
      break
   }
}

#Checking if adapter was found/exists
if($InterfaceIndex -eq -9999)
{
   Add-Content -Path $logfile -Value "Adapter not found./r/n/r/n"
   Exit -1
}
Add-Content -Path $logfile -Value "Adapter found with ifIndex $InterfaceIndex ./r/n/r/n"

#Create new NetIPAddress object
New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceIndex $InterfaceIndex
New-NetNat -Name "InternalNat" -InternalIPInterfaceAddressPrefix 192.168.0.0/24

#Registry Checking and setting the values to 1
$LongPathsEnabled = (Get-ItemProperty -path 'HKLM:/SYSTEM/ControlSet001/Control/FileSystem' -Name 'LongPathsEnabled').LongPathsEnabled
if($LongPathsEnabled -ne 1){Set-ItemProperty -path 'HKLM:/SYSTEM/ControlSet001/Control/FileSystem' -Name 'LongPathsEnabled' -Value '1'}
$LPGO = (Get-ItemProperty -path 'HKLM:/SYSTEM/ControlSet001/Control/FileSystem' -Name 'LPGO').LPGO
if($LPGO -ne 1){Set-ItemProperty -path 'HKLM:/SYSTEM/ControlSet001/Control/FileSystem' -Name 'LPGO' -Value '1'}

#Add other admins
Add-Content -Path $logfile -Value "Adding other admins./r/n/"
New-LocalUser -Name "scxsign" -Description "Adding redmond/scxsign" -NoPassword
Add-LocalGroupMember -Group "Administrators" -Member "scxsign"
