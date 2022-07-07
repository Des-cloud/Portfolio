#Add other admins
Add-Content -Path $logfile -Value "Adding other admins./r/n/"
New-LocalUser -Name "scxsign" -Description "Adding redmond/scxsign" -NoPassword
Add-LocalGroupMember -Group "Administrators" -Member "scxsign"

Add-Content -Path $logfile -Value "Completed Adding other admins./r/n/"