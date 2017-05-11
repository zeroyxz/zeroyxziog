
#***************************************************************************************************************************************
#Title: Script to configure an IOG SharePoint sites master page, favicon and suitebar
#Version: 0.1
#Date: 11-Apr-2017
#Author: Peter Worlin
#***************************************************************************************************************************************



#---------------------------------#
#---Function Declarations Start---#
#---------------------------------#
Write-Host "Before you run this script check that the original default.aspx exists in the Login location as this will be backed-up by this script" -ForegroundColor Magenta



$LoginPath = "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\template\identitymodel\login"
$ChangeLogin = Read-Host "The script assumes the path to the login folder is: $loginpath .Do you want to set it to something else, [Y]es or [N]o:"
if ($ChangeLogin -eq "Y"){
    $LoginPath = Read-Host "Please enter the path to the login folder on this server:"
}

BackUpOriginals $LoginPath "default.aspx"

CopyMedia "C:\iog\LoginPage" $LoginPath "default.aspx"

UpdateMedia $LoginPath "default.aspx"


Write-Host "SharePoint IOG Login Page setup complete.  Please sign-out of SharePoint to see changes." -ForegroundColor Magenta







