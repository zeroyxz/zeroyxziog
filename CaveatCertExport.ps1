#This is the caveat script to run - the caveat farms utilise the CTHub on the search server - needs running on each caveat farm - this is the CONSUMER
Add-PSSnapin "Microsoft.SharePoint.PowerShell"

#Export the root certificate from each caveat
$RootCert = (Get-SPCertificateAuthority).RootCertificate
$RootCert.Export("Cert") | Set-Content c:\windows\temp\Caveat1.cer -Encoding Byte

#This just takes place on the Consumer
#Export the STS certificate
$STSCert = (Get-SPSecurityTokenServiceConfig).LocalLoginProvider.SigningCertificate
$STSCert.Export("Cert") | Set-Content c:\windows\temp\CaveatSTS.cer -Encoding Byte

#Copy each caveat certificate to the Central farm that hosts the CTHub
Copy-Item C:\Windows\Temp\Caveat*.cer -Destination '\\sp13farm-spsql\C$\Windows\Temp'


#If you manually set up Publishing and trust you must use IE

#Once the certificate and the STS have been exported from the CTHub server and copied into this servers location we can import into the Trusted Root Certificate store
$CTHubRootCert = Get-PfxCertificate C:\Windows\Temp\CTHub.cer

New-SPTrustedRootAuthority CTHub -Certificate $CTHubRootCert

(Get-SPFarm).Id



#####Note that as well as the above I added the CTHub.cer (SPRoot Certificate) into the Trusted Certificate Root store####
###then I could browse to the $loadBalancerUrl later in this process without getting a security pop up about the certificates - doesn't solve the problem though####
###It doesn't look like you need an inbound firewall rule on the Publisher



#*****ON THE PUBLISHER FARM****
#run 'Publish-SPServiceApplication (Get-SPMetadataServiceApplication "<NameOfManagedMetadataService>' on the Publisher farm to Publish the service for external use
#run 'Get-SPTopologyServiceApplication | Format-Table -Wrap -AutoSize' on the Publisher farm to get the LoadBlancerUrl for below use
$LoadBalancerURL = "https://sp13farm-spsql:32844/Topology/topology.svc"



###This never worked
#New-SPMetadataServiceApplicationProxy (Receive-SPServiceApplicationConnectionInfo -FarmUrl "https://sp13farm-spsql:32844/Topology/topology.svc" | where {$_.Name -eq "MMS1"}).Uri

###So used this instead - getting the Uri from the Publisher farm after Publishing the Managed Metadata service - manually as it happens! along with importing the root and sts certs into the publisher SharePoint
New-SPMetadataServiceApplicationProxy -Name "MMSProxy" -Uri "urn:schemas-microsoft-com:sharepoint:service:e83c98e0cf48414898a4264db50c1256#authority=urn:uuid:1c6cb3354f714445b8f8f5cda9b2daba&authority=https://sp13farm-spsql:32844/Topology/topology.svc"

#Run the following command on the consumer farm to add the new proxy to the default proxy group
Add-SPServiceApplicationProxyGroupMember (Get-SPServiceApplicationProxyGroup -default) -Member (Get-SPMetadataServiceApplicationProxy "MMSProxy")

