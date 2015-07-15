Configuration TestConfig
{
    Import-DSCResource -ModuleName ContosoDscResources
    
    Node "localhost"
    {  
	LocalConfigurationManager 
	{ 
            ConfigurationID = "334a740d-0aac-4c92-9bb6-6895ac050ead";
       	    RefreshMode = "PULL";
       	    DownloadManagerName = "WebDownloadManager";
       	    RebootNodeIfNeeded = $true;
       	    RefreshFrequencyMins = 30;
       	    ConfigurationModeFrequencyMins = 30; 
       	    ConfigurationMode = "ApplyAndAutoCorrect";
       	    DownloadManagerCustomData = @{ServerUrl =    "http://dnsvm:8080/PSDSCPullServer.svc"; AllowUnsecureConnection = “TRUE”}
     	} 
        TestSetup setupTestMachine
        {
        }
    }
}
