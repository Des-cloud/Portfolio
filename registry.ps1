#Registry Checking and setting the values to 1
Add-Content -Path $logfile -Value "Registry Checking and setting the values to 1./r/n/"
$LongPathsEnabled = (Get-ItemProperty -path 'HKLM:/SYSTEM/ControlSet001/Control/FileSystem' -Name 'LongPathsEnabled').LongPathsEnabled
if($LongPathsEnabled -ne 1){Set-ItemProperty -path 'HKLM:/SYSTEM/ControlSet001/Control/FileSystem' -Name 'LongPathsEnabled' -Value '1'}
$LPGO = (Get-ItemProperty -path 'HKLM:/SYSTEM/ControlSet001/Control/FileSystem' -Name 'LPGO').LPGO
if($LPGO -ne 1){Set-ItemProperty -path 'HKLM:/SYSTEM/ControlSet001/Control/FileSystem' -Name 'LPGO' -Value '1'}

Add-Content -Path $logfile -Value "Done Registry Checking and setting the values to 1./r/n/"