﻿
#***************************************************************************************************************************************
#Title: Script to configure a SharePoint sites master page, favicon and suitebar
#Version: 0.1
#Date: 11-Apr-2017
#Author: Peter Worlin
#***************************************************************************************************************************************

#Update this value with the correct color for the caveat:
$colour = "white"

#---------------------------------#
#---Function Declarations Start---#
#---------------------------------#

#-Enables the Site Collection Publishing feature and the Site Publishing feature-#
function EnablePublishing{
    Write-Host "Enabling the Publishing features on your site collection and root web to enable modification of master page" -ForegroundColor Magenta
    try{
        Enable-SPFeature -Identity "PublishingSite" -Url $url -ErrorAction Stop #Needed because non-terminating errors do not trigger catch
    }
    catch{
        Write-Host "Failed to activate Publishing feature on site - probably already done - please check" -ForegroundColor Magenta
    }
    try{
        Enable-SPFeature -Identity "PublishingWeb" -Url $url -ErrorAction Stop #Needed because non-terminating errors do not trigger catch!
    }
    catch{
        Write-Host "Failed to activate Publishing feature on Web - probably already done - please check" -ForegroundColor Magenta
    }
}

#-Creates an IOG folder in the Style Library -#
function CreateIOGFolder{
    try{
        $folder = $StyleLibrary.AddItem("",[Microsoft.SharePoint.SPFileSystemObjectType]::Folder, "IOG")
        $folder.Update()
        Write-Host "Created IOG folder in style library" -ForegroundColor Magenta
    }
    catch{
        Write-Host "Couldn't create IOG folder in style library - probably already exists - please check" -ForegroundColor Magenta
    }

}

#-Uploads a file to the Master Page Gallery-#
function UploadFileToMasterPageGallery {
    Param([string]$Filename)

    Write-Host "Uploading " $Filename " to Master Page Gallery" -ForegroundColor Magenta
    
    $url = $url.trim()
    If ($url.EndsWith('/')){
        $url-$url.substring(0,$url.Length-1)
    }
        
     
    $WebURL = $url + "/_catalogs/masterpage/"   

    $Stream = [IO.File]::OpenRead($PSScriptRoot + "\" + $Filename);
    $file = $MasterPageList.Files.Add($WebURL + $Filename,$Stream,$true);    
    $file.Item.Update()
    $file.Update()
    $web.Update()
    $file.Publish("Published by process")
    $stream.Close()

    #Give SharePoint time to create the master file
    #Start-Sleep -Seconds 30

    Write-Host "Setting master page for site and system" -ForegroundColor Magenta
    foreach($website in $Site.AllWebs){
        $MasterUrl = $file.ServerRelativeUrl
        $MasterUrl = $MasterUrl.Replace(".html",".master")

        $website.MasterUrl = $MasterUrl
        $website.CustomMasterUrl = $MasterUrl
        $website.Update()
    }
}

#-Uploads a file to a style library in a particular web or root web-#
#-Because we want some design files only present in the RootWeb we take a Location parameetr-#
function UploadFileToStyleLibrary{
    Param([string]$Location, [string]$Filename)

    $Stream = [IO.File]::OpenRead($PSScriptRoot + "\" + $Filename)

    if ($Location = "Root"){
        Write-Host "Uploading " $Filename " to " $RootStyleLibrary.RootFolder.Url "/IOG/" -ForegroundColor Magenta
        $file = $RootSite.RootWeb.GetFile($RootStyleLibrary.RootFolder.Url + "/IOG/" + $filename)
        if ($file.Exists -eq $true){
        Write-Host "File already exists...checking out for update" -ForegroundColor Magenta
            $file.CheckOut()
        }
        
        $RootSite.RootWeb.Files.Add($RootStyleLibrary.RootFolder.Url + "/IOG/" + $filename,$Stream,$true)
        
    }
    else{
        Write-Host "Uploading " $Filename " to " $StyleLibrary.RootFolder.Url "/IOG/" -ForegroundColor Magenta 
        $file = $Web.GetFile($RootStyleLibrary.RootFolder.Url + "/IOG/" + $filename)
        if ($file.Exists -eq $true){
            Write-Host "File already exists...checking out for update" -ForegroundColor Magenta
            $file.CheckOut()
        }

        $Web.Files.Add($RootStyleLibrary.RootFolder.Url + "/IOG/" + $filename,$Stream,$true)
          
    }

    
    
    
    $file.CheckIn("Checked in by process")
    $file.Publish("Published by process")
    $file.Update()

    $stream.Close()
}

#-Sets the SuiteBar for the Web Application-#
function ChangeSuiteBar {
    #Note the suitebar is updated for the entire web application - not on a site collection basis
    $wa = $site.WebApplication
    $wa.SuiteBarBrandingElementHtml = " <div id=""iogSuiteBarLeft"" class=""iogsuitebar""> `
        <img id=""leftSuiteImage""src=""/Style%20Library/IOG/banner_flags.jpg"" alt=""banner-left"" /> `
        <img id=""rightSuiteImage"" src=""/Style%20Library/IOG/banner_flags.jpg"" alt=""banner-right"" /> `
        <span id=""suiteText"">$Script:SuiteBarText</span> `
      </div>"
    $wa.Update()
    Write-Host "Updated the suitebar" -ForegroundColor Magenta
}

function ResetSuiteBar{
    #Note the suitebar is updated for the entire web application - not on a site collection basis
    $wa = $site.WebApplication
    $wa.SuiteBarBrandingElementHtml = ""
    $wa.Update()
    Write-Host "Reset the suitebar" -ForegroundColor Magenta
}

#-Get the correct image for the caveat being deployed-#
function GetRightImage{
    switch ($caveat)
    {
        "A" {
            Copy-Item AUSUK_banner_flags.jpg -Destination banner_flags.jpg
            $Script:SuiteBarText="Minimum classification of content is UK SECRET AUS/UK EYES only"
        }
        "E" {
            Copy-Item EYE_banner_flags.jpg -Destination banner_flags.jpg
            $Script:SuiteBarText="Minimum classification of content is UK SECRET AUS/CAN/NZL/UK/USA EYES only"
        }
        "U" {
            Copy-Item UKUS_banner_flags.jpg -Destination banner_flags.jpg
            $Script:SuiteBarText="Minimum classification of content is UK SECRET UK/US EYES only"
        }
        default {"Do not understand the caveat you have entered"}
    }
}

#-------------------------------#
#---Function Declarations End---#
#-------------------------------#


#Make sure SharePoint Powershell module is loaded
Add-PSSnapin "Microsoft.SharePoint.PowerShell"

#-Get information from user about what we are deployin-#

$option = "F" #Read-Host "Do you want the full customisation of the IOG site [F] or just the SuiteBar [S]"
$url = Read-Host "What is the URL of your site collection:"

#-Set variables used throughout-#
$Site = Get-SPSite $url
$Web = $Site.RootWeb
$MasterPageList = ($Web).GetFolder("Master Page Gallery")
$StyleLibrary = $Web.Lists["Style Library"]
$RootSite = Get-SPSite $site.WebApplication.Url
$RootStyleLibrary = $RootSite.RootWeb.Lists["Style Library"]
$SuiteBarText=""


#-If we're doing a full deployment execute this section-#
if ($option -eq "F"){
    #Get the right image into SharePoint for the banner
    GetRightImage

    #Enable Publishing on the site collection & site
    EnablePublishing

    #Create IOG folder in Style Library
    CreateIOGFolder

    #Upload file to Master Page Gallery
    UploadFileToMasterPageGallery("IOG.html")


    #Upload files to Style Library
    UploadFileToStyleLibrary "Root" "banner_flags.jpg"
    UploadFileToStyleLibrary "Root" "UK_Flag.ico"
    UploadFileToStyleLibrary "Root" "IOG_SP.css"

    #delete copied file
    Remove-Item "banner_flags.jpg" -Force

    ChangeSuiteBar $SuiteBarText

}




