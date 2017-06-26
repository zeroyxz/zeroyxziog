##################################################################################################
#  VERSION: V1.0
#
#  DATE: 20th June 2017
#
#  DESCRIPTION:
#    This script creates service accounts, DNS Entries and invokes a child script to create a Content Type Hub
#
#  INSTRUCTIONS
#    1. Update the PARAMETERS section variables (both SECTION 1 and SECTION 2 will use these values) & Save
#    2. Copy this file (or its contents) to the Domain Server 
#    3. Run File (or contents in ISE)
#    4. Comment out all lines of SECTION 1 - you dont want to run this on the SPS servers
#    5. Copy this file and the CreateCTHub.ps1 file to each farm's SharePoint Application Server
#    6. Uncomment the relevant line in SECTION 2 
#    7. Run File
#
#  VERSION HISTORY
#    Version        Date        Author         Description
#    v1.0           20/06/17    Peter Worlin   Initial Script
#
#
##################################################################################################




#SECTION PARAMETERS::Update these values before running
    #--Create accounts with these names to host the App Pool used for the Web Site that hosts the Content Type Hub
    $AUSUK_Web_App_Pool_Name = "ausukwebapppool"
    $UKUS_Web_App_Pool_Name = "ukuswebapppool"
    $FVEY_Web_App_Pool_Name = "fveywebapppool"

    #--Create accounts with these names to host the App Pool used for the service that hosts the MMS
    $AUSUK_Svc_App_Pool_Name = "ausuksvcapppool"
    $UKUS_Svc_App_Pool_Name = "ukussvcapppool"
    $FVEY_Svc_App_Pool_Name = "fveysvcapppool"

    #--Create Type A DNS Records for the Content Type Hub Web Application with this names
    $AUSUK_Web_DNS = "ausukcthub"
    $UKUS_Web_DNS = "ukuscthub"
    $FVEY_Web_DNS = "fveycthub"

    #--Point the DNS records for each of the above to either the WFE NIC or a Load Balanced NIC
    $AUSUK_LB_IP = "10.0.0.3"
    $UKUS_LB_IP = "10.0.0.4"
    $FVEY_LB_IP = "10.0.0.6"

    #--Create the accounts with the correct domain prefix
    $domain = "corp"

    #--Create the DNS entries in the correct Forward Lookup Zone
    $zone = "corp.contoso.com"
#END SECTION PARAMETERS


#SECTION FUNCTIONS
Function CreateAccount{ 
    Param(
        [Parameter(Mandatory=$true)]
        [string]$AccountName,

        [Parameter(Mandatory=$true)]
        [Security.SecureString]$pwd
    )

    New-ADUser -SamAccountName $AccountName -AccountPassword $pwd -name $AccountName -enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false

}

Function CreateDNS{
    Param(

        [Parameter(Mandatory=$true)]
        [string]$ZoneName,

        [Parameter(Mandatory=$true)]
        [string]$HostName,

        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )

    Add-DnsServerResourceRecordA -Name $HostName -ZoneName $ZoneName -AllowUpdateAny -IPv4Address $IPAddress -TimeToLive 01:00:00
}

#END SECTION FUNCTIONS


#SECTION 1: DOMAIN SERVER ONLY
    #This creates service accounts and DNS entries for caveat specific web app to host Content Type Hub
    $pwd = read-host "Set password to use for all service accounts" -AsSecureString

    CreateAccount -AccountName $AUSUK_Web_App_Pool_Name -pwd $pwd  
    CreateDNS -ZoneName $zone -HostName $AUSUK_Web_DNS -IPAddress $AUSUK_LB_IP

    CreateAccount -AccountName $UKUS_Web_App_Pool_Name -pwd $pwd
    CreateDNS -ZoneName $zone -HostName $UKUS_Web_DNS -IPAddress $UKUS_LB_IP
    
    CreateAccount -AccountName $FVEY_Web_App_Pool_Name -pwd $pwd
    CreateDNS -ZoneName $zone -HostName $FVEY_Web_DNS -IPAddress $FVEY_LB_IP

    #This creates service accounts for the App Pool that hosts the caveat specific Managed Metadata Service
    CreateAccount -AccountName $AUSUK_Svc_App_Pool_Name -pwd $pwd
    CreateAccount -AccountName $UKUS_Svc_App_Pool_Name -pwd $pwd
    CreateAccount -AccountName $FVEY_Svc_App_Pool_Name -pwd $pwd
#END SECTION 1


#SECTION 2: SPS APPLICATION SERVER ONLY
    #This creates a web application & site collection for the Content Type Hub - each line must be uncommented according to the farm you are configuring
    #.\CreateCTHub -Caveat "AUSUK" -WebApplicationURL http://$AUSUK_Web_DNS -WebAppPoolAccount $domain\$AUSUK_Web_App_Pool_Name -SvcAppPoolAccount $AUSUK_Svc_App_Pool_Name -SiteColOwnerAccount $env:UserName
    #.\CreateCTHub -Caveat "UKUS" -WebApplicationURL http://$UKUS_Web_DNS -WebAppPoolAccount $domain\$UKUS_Web_App_Pool_Name -SvcAppPoolAccount $UKUS_Svc_App_Pool_Name -SiteColOwnerAccount $env:UserName
    #.\CreateCTHub -Caveat "FVEY" -WebApplicationURL http://$FVEY_Web_DNS -WebAppPoolAccount $domain\$FVEY_Svc_App_Pool_Name -SvcAppPoolAccount $FVEY_Svc_App_Pool_Name -SiteColOwnerAccount $env:UserName
#END SECTION 2

#CREATE CONTENT TYPES and COLUMNS


#SECTION 3: CREATE TERM SETS
#CLASSIFICATION

#SECTION 4: CREATE SITE TEMPLATE
#BASED ON TEAM SITE


#RETENTION AND DISPOSAL

