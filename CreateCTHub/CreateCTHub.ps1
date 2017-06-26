##################################################################################################
#  VERSION: V1.0
#
#  DATE: 14th June 2017
#
#  DESCRIPTION:
#    This script creates App Pools, Web Applications and a site collections to host a 
#    Content Type Hub.  It then creates a Managed Metadata Service to use the Content Type Hub
#
#  INPUTS:
#    $Subscr = Name of the Subscription
#    $Location = Location of provisioned resources
#    $RGGroupName= Resource Group Name
#    $SAName = Storage Account Name
#    $VNetName = Virtual Network Name
#    $AVSetName = Availability Set Name for this server
#
#  VERSION HISTORY
#    Version        Date        Author         Description
#    v1.0           12/06/17    Peter Worlin   Initial Script
#
#
##################################################################################################
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$Caveat, #expected is UKUS, AUSUK, FVEY

    [Parameter(Mandatory=$true)]
    [string]$WebApplicationURL,

    [Parameter(Mandatory=$true)]
    [string]$WebAppPoolAccount,

    [Parameter(Mandatory=$true)]
    [string]$SvcAppPoolAccount,

    [Parameter(Mandatory=$true)]
    [string]$SiteColOwnerAccount
)




# - Creates a Web Application in a farm for hosting the Content Type Hub Site Collection
Function CreateCTHubWebApplication{
    <#Param (
        [string] $WebAppURL,
        [string] $WebAppPoolAccount
    )#>
    #$cred = Get-Credential -Message "Enter the credentials of the account to use as the App Pool Account Identity"
    #New-SPManagedAccount -Credential $cred

    $ap = New-SPAuthenticationProvider

    New-SPServiceApplicationPool -Name $Caveat + "WebAppPool" -Account $SvcAppPoolAccount

    #-ApplicationPoolAccount (Get-SPManagedAccount $WebAppPoolAccount)
    New-SPWebApplication -Name "Web App for $Caveat CT Hub" -Port 80 -Url $WebApplicationURL -ApplicationPool $Caveat + "WebAppPool" -AuthenticationProvider $ap

}


#Creates a site collection in the root of the web application created for hosting this
Function CreateSiteCollection{
    <#Param (
        [string] $WebAppURL,
        [string] $Owner
    )#>

    $Url = "$WebApplicationURL/"

    $TeamSiteTemplate = "STS#0"
    #$IE = New-Object -ComObject InternetExplorer.Application
    $Site = New-SPSite -Url $WebApplicationURL -Name "Content Type Hub for $Caveat" -OwnerAlias $Owner -Template $TeamSiteTemplate
    #$IE.Navigate($Site.Url)
    #$IE.Visible = $true

}

#Creates the Managed Metadata Service Application
Function CreateMMS{
     
    #$cred = Get-Credential -Message "Enter the credentials of the account to use as the Service Account Identity - we are setting it as a managed account"
    #New-SPManagedAccount -Credential $cred

    New-SPServiceApplicationPool -Name $Caveat + "SvcAppPool" -Account SvcAppPoolAccount

    New-SPMetadataServiceApplication -Name "IOG Managed Metadata Service for $Caveat" -ApplicationPool $Caveat + "SvcAppPool" -DatabaseName $Caveat + "MMSDb" -HubUri $WebApplicationURL -SyndicationErrorReportEnabled -
}

#-Enables the Site Collection Publishing feature and the Site Publishing feature-#
function EnableCTHubFeature{
    <#Param(
        [string] $Url
    )#>
    Write-Host "Enabling the Content Type Publishing feature on your site collection" -ForegroundColor Magenta
    try{
        Enable-SPFeature -Identity "ContentTypeHub" -Url $WebApplicationURL -ErrorAction Stop #Needed because non-terminating errors do not trigger catch
    }
    catch{
        Write-Host "Failed to activate ContentTypeHub feature on site - please check" -ForegroundColor Magenta
    }
}


#Check the user has created an account to host the Application Pool Account
$Response = "Have you run the script that creates the App Pool Identity Accounts and creates DNS entries?[Y]es or [N]:"
If ($Response -eq 'N'){
    Write-Host "Go and run the script..." -ForegroundColor Magenta
    Exit
}


#Create a separate web application to host the Content Type Hub (we don't have to but it's cleaner to have it's own IIS site)
CreateCTHubWebApplication -Url 

#Create the site collection
CreateSiteCollection

#Enable the feature
EnableCTHubFeature

#Create the Managed Metadata Service
CreateMMS 
