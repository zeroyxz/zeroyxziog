
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
$CaveatText="Unset"
$CaveatImage="Unset"

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

function BackUpOriginals([string]$PathToOriginal, [string]$FileName){
    
    cd $PathToOriginal
    
    #-Back up the existing page-#
    if (Test-Path -Path ($FileName + ".orig")){
        #Don't remove it as this is probably the original file - use bkp1 extension instead
        if (Test-Path -Path ($FileName + ".bkp1")){
            #delete previous backup
            Remove-Item -Path ($FileName + ".bkp1")          
        }
        #backup this version 
        if (Test-Path -Path $FileName){
            Rename-Item -Path $FileName -NewName ($FileName + ".bkp1") -Force
        }
    } 
    else {
        #Back up the original - if it exists
        if (Test-Path -Path $FileName){
            Rename-Item -Path $FileName -NewName ($FileName + ".orig") -Force 
        }      
    }
}

function CopyMedia([string]$SourcePath, [string]$DestPath, [string]$FileName){

    cd $SourcePath

    Write-Host "Copying files to $DestPath from $SourcePath" -ForegroundColor Magenta

    #Create the directories if they dont exist
    if (!(Test-Path -Path $DestPath\IOG)){md $DestPath\IOG}
    if (!(Test-Path -Path $DestPath\IOG\Images)){md $DestPath\IOG\Images}
    if (!(Test-Path -Path $DestPath\IOG\Stylesheets)){md $DestPath\IOG\Stylesheets}


    Copy-Item -Path .\iog\images\MoD_masthead.png -Destination $DestPath\iog\images
    Copy-Item -Path .\iog\stylesheets\IOG.css -Destination $DestPath\iog\stylesheets
    Copy-Item -Path .\iog\images\Agree.png -Destination $DestPath\iog\images
    Copy-Item -Path .\$FileName -Destination $DestPath #because different default.aspx vs iisstart.htm

    Copy-Item -Path .\iog\images\aus.jpg -Destination $DestPath\iog\images
    Copy-Item -Path .\iog\images\can.jpg -Destination $DestPath\iog\images
    Copy-Item -Path .\iog\images\nz.jpg -Destination $DestPath\iog\images
    Copy-Item -Path .\iog\images\uk.jpg -Destination $DestPath\iog\images
    Copy-Item -Path .\iog\images\us.jpg -Destination $DestPath\iog\images

    #remve previous items if they exist
    if (Test-Path -Path $DestPath\*.jpg){Remove-Item -path $DestPath\*.jpg}
    if (Test-Path -Path $DestPath\IOGLogin.css){Remove-Item -path $DestPath\IOGLogin.css}
    if (Test-Path -Path $DestPath\*.png){Remove-Item -path $DestPath\*.png}
}

function UpdateMedia([string]$DestPath, [string]$FileName){

    cd "c:\iog"

    #Put the right information in the file after copied to destination
    switch ($caveat)
    {
        "A" {
            $CaveatText = "AUSUK"
            $CaveatImage = '<div style="width:50%;float:left"><img style="display:block" src="iog/images/aus.jpg" alt="Australia"/></div><div style="width:50%;float:left"><img style="display:block" src="iog/images/uk.jpg" alt="United Kingdom"/></div>'
            }
        "E" {
            $CaveatText = "5EYES"
            $CaveatImage = '<img style="margin-left:40px" src="iog/images/aus.jpg" alt="Australia"/><img src="iog/images/can.jpg" alt="Cananda"/><img src="iog/images/uk.jpg" alt="United Kingdom"/><img src="iog/images/nz.jpg" alt="New Zealand"/><img src="iog/images/us.jpg" alt="United States of America"/>'
            }
        "U" {
            $CaveatText = "UKUS"
            $CaveatImage = '<div style="width:50%;float:left"><img style="display:block" src="iog/images/uk.jpg" alt="United Kingdom"/></div><div style="width:50%;float:left"><img style="display:block" src="iog/images/us.jpg" alt="United States of America"/></div>'
            }
        default {"Do not understand the caveat you have entered"}
    }

    if ($FileName -eq "default.aspx"){
        .\ReplaceFileString.ps1 -Pattern 'caveattexthere' -Replacement $CaveatText -path $DestPath\default.aspx -overwrite
        .\ReplaceFileString.ps1 -Pattern 'caveatimageshere' -Replacement $CaveatImage -path $DestPath\default.aspx -overwrite
    } else {
        .\ReplaceFileString.ps1 -Pattern 'caveatimageshere' -Replacement $CaveatImage -path $DestPath\iisstart.htm -overwrite
    }



}



$RunIOGSiteSetup = Read-Host "Do you want to configure the IOG site, [Y]es or [N]o (only run once per farm):"
$ConfigureLoginPage = Read-Host "Do you want to configure the IOG Login page, [Y]es or [N]o (run on every WFE):"
$ConfigureIISDefaultPage = Read-Host "Do you want to configure the IOG Default page, [Y]es or [N]o (run on every WFE):"
$caveat = Read-Host "Which caveat is being customised?:[E]=5-EYE, [U]=UKUS, [A]=AUSUK, enter E,U or A:"

if ($RunIOGSiteSetup -eq "Y"){
    cd c:\iog\SiteSetup
    #-Note that the IOG setup only needs to be run once on a server farm and applies to a web application and site collection-#
    .\IOGSiteSetup.ps1
    cd..
}

if ($ConfigureLoginPage -eq "Y"){
    cd c:\iog\LoginPage
    #-Note that the Login page is a SharePoint file changed on the file system and needs to be run on every WFE-#
    .\IOGLoginPage.ps1
    cd..
}

if ($ConfigureIISDefaultPage -eq "Y"){
    cd c:\iog\DefaultPage
    #-Note that the default page is an IIS file changed on the file system and needs to be run on every WFE-#
    .\IOGDefaultPage.ps1
    cd..
}




