Configuration ContosoWebsite
{
    Import-DSCResource -ModuleName ContosoDscResources
    
    "$(Get-Date) Module Imported" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append  
    
    Node "localhost"
    {  
        "$(Get-Date) DNS server Setup successfull" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append

        DNSServerRun RunDNS
        {
            "Domainname" = "microhard.dev"
            "DomainAdminUsername" = "pratham"
            "DomainAdminPassword" = "Applegr8"
        }

        "$(Get-Date) DNS server installed" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append
    }
}
