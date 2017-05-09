
#***************************************************************************************************************************************
#Title: Script to configure an IOG SharePoint default website page
#Version: 0.1
#Date: 24-Apr-2017
#Author: Peter Worlin
#***************************************************************************************************************************************



#---------------------------------#
#---Function Declarations Start---#
#---------------------------------#

Write-Host "This script will create a folder in the root directory of your website to use for the default page" -ForegroundColor Magenta

$WebPath = "C:\inetpub\wwwroot\wss\VirtualDirectories\sp13farm.ukwest.cloudapp.azure.com80"
$ChangeLogin = Read-Host "The script assumes the path to the root folder is: $WebPath .Do you want to set it to something else, [Y]es or [N]o:"
if ($ChangeLogin -eq "Y"){
    $WebPath = Read-Host "Please enter the path to the login folder on this server:"
}

#-Remove folder if it already exists-#
if (Test-Path $WebPath\IOGDefault){
    Remove-Item -Path $LoginPath\IOGDefault
}

cd $WebPath
md IOGDefault
$WebPath = $WebPath + "\IOGDefault"

cd C:\iog\DefaultPage

Write-Host "Copying files to desired location..." -ForegroundColor Magenta
Copy-Item -Path 5Eyes.png -Destination $WebPath
Copy-Item -Path IOGDefault.css -Destination $WebPath
Copy-Item -Path IISStart.html -Destination $WebPath
Copy-Item -Path AusUK_banner_Flags.jpg -Destination $WebPath
Write-Host "SharePoint IOG Default Page setup complete.  Please sign-out of SharePoint to see changes." -ForegroundColor Magenta







