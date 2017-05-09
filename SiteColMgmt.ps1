$WebAppUrl = "http://sp13farm.ukwest.cloudapp.azure.com"

cd\
cd c:\iog

Add-PSSnapin "Microsoft.SharePoint.Powershell"

#This line will delete all site collections except the Root - useful when you've been creating test sites
#Get-SPWebApplication $WebAppUrl | Get-SPSite | Where-Object {$_.Url -like "*sites*"} | Remove-SPSite

#This section creates a new Site Collection and opens it in INternet Explorer
Function CreateSiteCollection{
    Param ([string] $Name)

    $Url = "http://sp13farm.ukwest.cloudapp.azure.com/sites/" + $Name

    $Owner = "CONTOSO\PeterWorlin"
    $TeamSiteTemplate = "STS#0"
    $BlankSiteTempalte = "STS#1"
    $PublishingSiteTemplate = "BLANKINTERNET#0"
    $IE = New-Object -ComObject InternetExplorer.Application
    $Site = New-SPSite -Url $Url -Name $Name -OwnerAlias $Owner -Template $TeamSiteTemplate
    $IE.Navigate($Site.Url)
    $IE.Visible = $true

}

CreateSiteCollection "site11"


