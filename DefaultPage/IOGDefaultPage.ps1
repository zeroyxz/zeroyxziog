
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

$WebPath = "C:\inetpub\wwwroot"
$ChangeLogin = Read-Host "The script assumes the path to the root folder is: $WebPath .Do you want to set it to something else, [Y]es or [N]o:"
if ($ChangeLogin -eq "Y"){
    $WebPath = Read-Host "Please enter the path to the login folder on this server:"
}

BackUpOriginals $WebPath "iisstart.htm"

CopyMedia "C:\iog\DefaultPage" $WebPath "iisstart.htm"

UpdateMedia $WebPath "iisstart.htm"

Write-Host "SharePoint IOG Default Page setup complete." -ForegroundColor Magenta







