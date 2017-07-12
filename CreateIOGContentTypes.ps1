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

            return $script:web.ContentTypes[$CTName];
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

    Write-Host "Calling Process-Fields function" -ForegroundColor Magenta

    $IOGDocCT = Create-ContentType -CTName "IOG Document" -CTParent "Document" -Group $groupName
    $IOGPicCT = Create-ContentType -CTName "IOG Picture" -CTParent "Picture" -Group $groupName
    $IOGModBoxCT = Create-ContentType -CTName "IOG MoDBox" -CTParent "IOG Document" -Group $groupName

    Import-Csv $filePath | ForEach-Object {
        $Name = $_.Name
        Write-Host "Processing field $Name - to add to content types"
        $fld1 = $script:web.Fields.GetField($Name)

        $fieldLink = New-Object Microsoft.SharePoint.SPFieldLink($fld1)

        if (!($IOGDocCT.Fields[$Name])){
            $IOGDocCT.FieldLinks.Add($fieldLink)
            $IOGDocCT.Update()
            } else {Write-Host "Field $Name already present on " $IOGDocCT.Name}
        
        if (!($IOGDocCT.Fields[$Name])){            
            $IOGPicCT.FieldLinks.Add($fieldLink)
            $IOGPicCT.Update()
            } else {Write-Host "Field $Name already present on " $IOGDocCT.Name}

        if (!($IOGDocCT.Fields[$Name])){        
            $IOGModBoxCT.FieldLinks.Add($fieldLink)
            $IOGModBoxCT.Update()
            } else {Write-Host "Field $Name already present on " $IOGDocCT.Name}
       
        }
    }
    


cls

Create-SPObjects -CTHubUrl $siteCollectionUrl

Process-Fields -filePath 'c:\iog\iog_columns.csv' -group $groupName

#Publish-ContentTypes -Group $groupName

Stop-SPAssignment -Global