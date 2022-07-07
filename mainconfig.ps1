# Variables
$resourcegroup = "InternJob"
$vmssname = "TestFlex"
$extensionname = "CustomScript"

# Get information about the scale set
$vmss = Get-AzVmss -ResourceGroupName $resourcegroup -VMScaleSetName $vmssname

# Remove extension
Remove-AzVmssExtension -VirtualMachineScaleSet $vmss -Name $extensionname
Update-AzVmss -ResourceGroupName $resourcegroup -Name $vmssname -VirtualMachineScaleSet $vmss

# Define the script for your Custom Script Extension to run on vmss
$fileUri = @(,"https://cs41003200200cc10f2.blob.core.windows.net/internjobstorage/config.ps1", 
  "https://cs41003200200cc10f2.blob.core.windows.net/internjobstorage/admin.ps1", 
  "https://cs41003200200cc10f2.blob.core.windows.net/internjobstorage/registry.ps1")

$customConfig = @{
  "fileUris" = $fileUri;
  "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File config.ps1"
}

$vmss = Add-AzVmssExtension -VirtualMachineScaleSet $vmss -Name $extName -Publisher "Microsoft.Compute" -Type "CustomScriptExtension" -TypeHandlerVersion 2.0 -Setting $customConfig

# Update the scale set and apply the Custom Script Extension to the VM instances
Update-AzVmss -ResourceGroupName $resourcegroup -Name $vmssname -VirtualMachineScaleSet $vmss
