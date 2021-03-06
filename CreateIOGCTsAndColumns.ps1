﻿##################################################################################################
#  VERSION: V1.0
#
#  DATE: 20th June 2017
#
#  DESCRIPTION:
#    This script creates columns and content types in a Content Type Hub
#    If possible run as the setup account
#
#  INSTRUCTIONS
#    1. Run Get-SPShellAdmin -database <id> and make sure you're logged on user account is listed - if not log on as a farm account and run Add-SPShellAdmin
#    2. Update the $url variable with the url of the content type hub site collection being configured
#
#  VERSION HISTORY
#    Version        Date        Author         Description
#    v1.0           26/06/17    Peter Worlin   Initial Script
#
#
##################################################################################################

Add-PSSnapIn "Microsoft.SharePoint.PowerShell"

Start-SPAssignment -Global

$site = $null
$web = $null
$groupName= "IOG"
$siteCollectionUrl = "http://cthub/sites/test5/"

function Create-SPObjects{
    param(
        [Parameter(mandatory=$true)][string]$CTHubUrl
    )

    
    if (!($script:web -eq $null))
    {
        $script:web.Close()
    }

    if (!($script:site -eq $null))
    {
        $script:site.Close() 
    }


    $script:site = Get-SPSite $CTHubUrl
    if (!$script:site){
        throw "No site found at " + $CTHubUrl
    }
    else
    {
        $script:web = $script:site.RootWeb;
        Write-Host "Created SharePoint Objects SPSite and SPWeb. Web title is " $script:web.Title -ForegroundColor Magenta
    }

}

function Get-TaxonomySessionDefault(){
    $centralAdmin = Get-SPWebApplication -IncludeCentralAdministration | Where {$_.IsAdministrationWebApplication} | Get-SPSite
    $session = New-Object Microsoft.SharePoint.Taxonomy.TaxonomySession($centralAdmin)
    if (!($session -eq $null)){
        return $session
    }
    else {
        Write-Host "Cannot get Taxonmy Session Default" -ForegroundColor Magenta
        throw "No default Taxonmy Session"
    }
}

function Get-TermStoreDefault(){
    $session = Get-TaxonomySessionDefault
    $serviceApp = Get-SPServiceApplication | Where {$_.TypeName -like "*Metadata*"}
    $termStore = $session.TermStores[$serviceApp.Name]
    if (!($termStore -eq $null)){
        return $termStore
    }
    else {
        throw "Cannot get Default Term Store that has a typename like 'Metadata'"
    }
}

function Get-TermSet(
    [string]$groupName,
    [string]$termSetName
)
{
    $termStore = Get-TermStoreDefault
    return $termStore.Groups[$groupName].TermSets[$termSetName]
}


function Create-TaxonomyField(
    [string]$staticName,
 #   [string]$displayName,
    [string]$group,
    [string]$termStoreGroupName,
    [string]$termSetName,
    [bool]$allowMultiValues,
    [bool]$required,
    [bool]$open
)
{
    Write-Host "In Create-TaxonomyField method values: $staticName, $group, $termStoreGroupName, $termSetName, $allowMultiValues, $required, $open " 
    $taxonomyFld = $script:web.Fields.CreateNewField("TaxonomyFieldType", $staticName)
    $termSet = Get-TermSet $termStoreGroupName $termSetName
    $taxonomyFld.SspId = $termSet.TermStore.Id
    $taxonomyFld.TermSetId = $termSet.Id
    $taxonomyFld.AllowMultipleValues = $allowMultiValues
    $taxonomyFld.Group = $group
    $taxonomyFld.Open = $open
    $taxonomyFld.StaticName = $staticName
#    $taxonomyFld.ShowInEditForm = $true
#    $taxonomyFld.ShowInNewForm = $true
    $taxonomyFld.Hidden = $false
    $taxonomyFld.Required=$required
    $script:web.Fields.Add($taxonomyFld)
    $script:web.Update()

    Write-Host "Created TaxonomyField " + $staticName -ForegroundColor Magenta

    return $taxonomyFld 
}

function Create-NoteField{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][bool]$Required,
        [Parameter(Mandatory=$true)][string]$Group
    )
    $fld = $script:web.Fields.CreateNewField("Note", $Name)
    $fld.Group = $Group
    $fld.Required = $Required
    $script:web.Fields.Add($fld)
    $script:web.Update()

    Write-Host "Created Note field " + $Name -ForegroundColor Magenta
    return $fld
}

function Create-TextField{
    param(
        [Parameter(mandatory=$true)][string]$Name,
        [Parameter(mandatory=$true)][bool]$Required,
        [Parameter(mandatory=$true)][string]$Group
    )

    $fld = $script:web.Fields.CreateNewField("Text", $Name)
    $fld.Group = $Group
    $fld.Required = $Required
    $script:web.Fields.Add($fld)
    $script:web.Update()

    Write-Host "Created Text field " + $Name -ForegroundColor Magenta
    return $fld
}


function Create-ContentType{
    param(
        [Parameter(mandatory=$true)][string]$CTName,
        [Parameter(mandatory=$true)][string]$CTParent,
        [Parameter(mandatory=$true)][string]$Group
    )

    #Check it doesn't already exist - create if not present
    if ($script:web){
        if ($script:web.AvailableContentTypes){
            $ct = $script:web.AvailableContentTypes["$CTName"]
            if (!$ct){
                $ct = new-object Microsoft.SharePoint.SPContentType($script:web.AvailableContentTypes[$CTParent],$script:web.contenttypes, $CTName)
                $script:web.contenttypes.add($ct)
                Write-Host "Created Content Type $CTName" -ForegroundColor Magenta     
            }
            else
            {
                Write-host "Content Type $CTName already present. It has not been re-created" -ForegroundColor Magenta
            }
            if ($ct.Group -ne $Group){
                $ct.Group = $Group
            }

            return $ct;
        } 
        else 
        {
            throw "No Available Content Types can be found"
        }
    } 
    else 
    {
        throw "No SPWeb Object" 
    }
}

function Publish-ContentTypes{
    param(
        [Parameter(mandatory=$true)][string]$Group
    )

    $CTPublisher = New-Object Micrsoft.SharePoint.Taxonomy.ContentTypeSync.ContentTypePublisher($script:site)
    $script:site.RootWeb.ContentTypes | ? {$_.Group -match $Group} | ForEach-Object {
        $CTPublisher.Publish($_)
        Write-Host "Published Content Type " $_.Name -ForegroundColor Magenta
    }
}

function Process-Fields{
    param(
        [Parameter(mandatory=$true)][string]$filePath,
        [Parameter(mandatory=$true)][string]$group
    )
    $Req = $null
    $fld = $null

    Write-Host "Calling Process-Fields function" -ForegroundColor Magenta

    Import-Csv $filePath | ForEach-Object {
        $Name = $_.Name
        $fldCheck = $null
        $Process = $true
        $termSetName = $_.termSetName
        
        Write-Host "Processing field" $Name -ForegroundColor Magenta

        try{
            $fldCheck = $script:web.Fields.GetField($Name)
            Write-Host "A field with the name $Name already exists and will not be recreated"
            $Process = $false
        }
        catch {
            $Process = $true
        }

        If ($Process){
            if (!($Name -eq "Title")){
                if ($_.Required -eq "Y") {$Req = $true} else {$Req = $false}

                Switch ($_.Type){
                    "Text" {
                        $fld = Create-TextField -Name $Name -Required $Req -Group $group
                    }
                    "Note" {
                        $fld = Create-NoteField -Name $Name -Required $Req -Group $group
                    }
                    "Managed Metadata"{
                        Write-Host "TermSetName=" $termSetName
                        $fld = Create-TaxonomyField -staticName $Name -group $group -termStoreGroupName "IOG" -termSetName $termSetName -allowMultiValues $false -required $true -open $false
                    }
        
                }
            }
        }
    }
    
}

cls

Create-SPObjects -CTHubUrl $siteCollectionUrl


#[Microsoft.SharePoint.SPContentType[]]$contentTypes

#$contentTypes = @()
#$contentTypes += Create-ContentType -CTName "IOG Document" -CTParent "Document" -Group $groupName
#$contentTypes += Create-ContentType -CTName "IOG Picture" -CTParent "Picture" -Group $groupName
#$contentTypes += Create-ContentType -CTName "IOG MoDBox" -CTParent "IOG Document" -Group $groupName

Process-Fields -filePath 'c:\iog\iog_columns.csv' -group $groupName


#Publish-ContentTypes -Group $groupName





Stop-SPAssignment -Global
