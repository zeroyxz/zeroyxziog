##################################################################################################
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

function Get-TaxonomySessionDefault(){
    $centralAdmin = Get-SPWebApplication -IncludeCentralAdministration | Where {$_.IsAdministrationWebApplication} | Get-SPSite
    $session = New-Object Microsoft.SharePoint.Taxonomy.TaxonomySession($centralAdmin)
    return $session
}

function Get-TermStoreDefault(){
    $session = Get-TaxonomySessionDefault
    $serviceApp = Get-SPServiceApplication | Where {$_.TypeName -like "*Metadata*"}
    $termStore = $session.TermStores[$serviceApp.Name]
    return $termStore
}

function Get-TermSet(
    [string]$groupName,
    [string]$termSetName
)
{
    $termStore
}

function Create_SPObjects{
    param(
        [Parameter(mandatory=$true)][string]$CTHubUrl
    )
    $site = Get-SPSite $CTHubUrl
    if (!($site -eq $null)){
        throw "No site found at " + $CTHubUrl
    }
    else
    {
        $web = $site.RootWeb;
    }
}

function Create_TextColumns{
    param(
        [Parameter(mandatory=$true)][string]$Name,
        [Parameter(mandatory=$true)][bool]$MultiLine,
        [Parameter(mandatory=$true)][bool]$Required,
        [Parameter(mandatory=$true)][string]$Group
    )

    $web.Fields.Add($Name, "Text", $Required)
    $fld = $web.Fields.GetField($Name)
    $fld.Group = $Group
}

function Create_ContentTypes{
    param(
        [Parameter(mandatory=$true)][string]$CTName,
        [Parameter(mandatory=$true)][string]$CTParent,
        [Parameter(mandatory=$true)][string]$Group
    )

    #Check it doesn't already exist - create if not present
    $ct = $web.AvailableContentTypes[$CTName]
    if ($ct -eq $null){
        $ct = new-object Microsoft.SharePoint.SPContentType($web.AvailableContentTypes[$CTParent],$web.contenttypes, $CTName)
    }

    if ($ct.Group -ne $Group){
        $web.contenttypes.add($ct)
    }

}

function Publish_ContentTypes{
    param(
        [Parameter(mandatory=$true)][string]$Group
    )

    $CTPublisher = New-Object Micrsoft.SharePoint.Taxonomy.ContentTypeSync.ContentTypePublisher($site)
    $site.RootWeb.ContentTypes | ? {$_.Group -match $Group} | ForEach-Object {
        $CTPublisher.Publish($_)
        Write-Host "Published Content Type " $_.Name -ForegroundColor Magenta
    }
    
    
}

Create_SPObjects -CTHubUrl "http://cthub/"

Create_ContentTypes -CTName "IOG Document" -CTParent "Document" -Group "IOG"
Create_ContentTypes -CTName "IOG Picture" -CTParent "Picture" -Group "IOG"
Create_ContentTypes -CTName "IOG MoDBox" -CTParent "IOG Document" -Group "IOG"

Publish_ContentTypes -Group "IOG"

Stop-SPAssignment -Global
