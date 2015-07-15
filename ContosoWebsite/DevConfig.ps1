Configuration DevConfig
{
    Import-DSCResource -ModuleName ContosoDscResources
    
    Node "localhost"
    {  

	LocalConfigurationManager 
        { 
            ConfigurationID = "429cc47b-1406-4c88-a3f8-bbc8fb81a1c9";
            RefreshMode = "PULL";
            DownloadManagerName = "WebDownloadManager";
            RebootNodeIfNeeded = $true;
            RefreshFrequencyMins = 30;
            ConfigurationModeFrequencyMins = 30; 
            ConfigurationMode = "ApplyAndAutoCorrect";
            DownloadManagerCustomData = @{ServerUrl =    "http://dnsvm:8080/PSDSCPullServer.svc"; AllowUnsecureConnection = "TRUE"}
        } 

        DevSetup setupDevMachine
        {
        }

    }
}
