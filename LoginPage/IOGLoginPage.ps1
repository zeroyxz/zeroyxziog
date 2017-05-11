
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

$CaveatText="Unset"
$CaveatImage="Unset"

$LoginPath = "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\template\identitymodel\login"
$ChangeLogin = 'n'#DEBUG#Read-Host "The script assumes the path to the login folder is: $loginpath .Do you want to set it to something else, [Y]es or [N]o:"
if ($ChangeLogin -eq "Y"){
    $LoginPath = Read-Host "Please enter the path to the login folder on this server:"
}

cd $LoginPath
#-Back up the existing default.aspx page-#
if (Test-Path default.aspx.orig){
    #Don't remove it as this is probably the original file - use bkp1 extension instead
    if (Test-Path default.aspx.bkp1){
        #delete previous backup
        Remove-Item -Path default.aspx.bkp1          
    }
    #backup this version 
    Rename-Item -Path default.aspx -NewName default.aspx.bkp1 -Force
} 
else {
    #Back up the original
    Rename-Item -Path default.aspx -NewName default.aspx.orig -Force       
}





cd C:\iog\LoginPage


Write-Host "Copying files to desired location..." -ForegroundColor Magenta
Copy-Item -Path MoD_masthead.png -Destination $LoginPath
Copy-Item -Path IOGLogin.css -Destination $LoginPath
Copy-Item -Path Agree.png -Destination $LoginPath
Copy-Item -Path Default.aspx -Destination $LoginPath

Copy-Item -Path aus.jpg -Destination $LoginPath
Copy-Item -Path can.jpg -Destination $LoginPath
Copy-Item -Path nz.jpg -Destination $LoginPath
Copy-Item -Path uk.jpg -Destination $LoginPath
Copy-Item -Path us.jpg -Destination $LoginPath

#Put the right information in the file after copied to desitination
cd c:\iog

switch ($caveat)
{
    "A" {
        $CaveatText = "AUSUK"
        $CaveatImage = '<div style="width:50%;float:left"><img style="display:block" src="aus.jpg" alt="Australia"/></div><div style="width:50%;float:left"><img style="display:block" src="uk.jpg" alt="United Kingdom"/></div>'
        }
    "E" {
        $CaveatText = "5EYES"
        $CaveatImage = '<img style="margin-left:40px" src="aus.jpg" alt="Australia"/><img src="can.jpg" alt="Cananda"/><img src="uk.jpg" alt="United Kingdom"/><img src="nz.jpg" alt="New Zealand"/><img src="us.jpg" alt="United States of America"/>'
        }
    "U" {
        $CaveatText = "UKUS"
        $CaveatImage = '<div style="width:50%;float:left"><img style="display:block" src="uk.jpg" alt="United Kingdom"/></div><div style="width:50%;float:left"><img style="display:block" src="us.jpg" alt="United States of America"/></div>'
        }
    default {"Do not understand the caveat you have entered"}
}


.\ReplaceFileString.ps1 -Pattern 'caveattexthere' -Replacement $CaveatText -path $LoginPath\default.aspx -overwrite
.\ReplaceFileString.ps1 -Pattern 'caveatimageshere' -Replacement $CaveatImage -path $LoginPath\default.aspx -overwrite


Write-Host "SharePoint IOG Login Page setup complete.  Please sign-out of SharePoint to see changes." -ForegroundColor Magenta







