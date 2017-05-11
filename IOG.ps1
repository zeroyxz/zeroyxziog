
#***************************************************************************************************************************************
#Title: Script to configure a SharePoint Publishing Implementation
#Version: 0.1
#Date: 11-Apr-2017
#Author: Peter Worlin
#***************************************************************************************************************************************
cd\
cd c:\iog
cls
$Policy = "RemoteSigned"
$OldPolicy = "Unchanged"

If ((Get-ExecutionPolicy) -ne $Policy){
    Write-Host "Updating your execution policy. The script will set it back at the end." -ForegroundColor Magenta
    $OldPolicy = Get-ExecutionPolicy
    Set-ExecutionPolicy $Policy -Force
}

#---------------------------------#
#---Function Declarations Start---#
#---------------------------------#

#-Add PowerShell snapin - not needed if running the SharePoint Powershell command tool-#
function AddPowerShellSnapin(){
    Write-Host "Adding SharePoint Powershell module to environment" -ForegroundColor Magenta
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

$RunIOGSiteSetup = 'N'#DEBUG#Read-Host "Do you want to configure the IOG site, [Y]es or [N]o (only run once per farm):"
$ConfigureLoginPage = 'Y'#DEBUG#Read-Host "Do you want to configure the IOG Login page, [Y]es or [N]o (run on every WFE):"
$ConfigureIISDefaultPage = 'N'#DEBUG#Read-Host "Do you want to configure the IOG Default page, [Y]es or [N]o (run on every WFE):"
$caveat = Read-Host "Which caveat is being customised?:[E]=5-EYE, [U]=UKUS, [A]=AUSUK, enter E,U or A:"

if ($RunIOGSiteSetup -eq "Y"){
    cd SiteSetup
    #-Note that the IOG setup only needs to be run once on a server farm and applies to a web application and site collection-#
    .\IOGSiteSetup.ps1
    cd..
}

if ($ConfigureLoginPage -eq "Y"){
    cd LoginPage
    #-Note that the Login page is a SharePoint file changed on the file system and needs to be run on every WFE-#
    .\IOGLoginPage.ps1
    cd..
}

if ($ConfigureIISDefaultPage -eq "Y"){
    cd DefaultPage
    #-Note that the default page is an IIS file changed on the file system and needs to be run on every WFE-#
    .\IOGDefaultPage.ps1
    cd..
}




