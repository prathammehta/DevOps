Configuration BuildConfig
{
    Import-DSCResource -ModuleName ContosoDscResources
    


    Node "localhost"
    {  

        LocalConfigurationManager 
	{ 
            ConfigurationID = "16a94ac5-dfe0-4e9d-b647-ff2b5080c468";
       	    RefreshMode = "PULL";
       	    DownloadManagerName = "WebDownloadManager";
       	    RebootNodeIfNeeded = $true;
       	    RefreshFrequencyMins = 30;
       	    ConfigurationModeFrequencyMins = 30; 
       	    ConfigurationMode = "ApplyAndAutoCorrect";
       	    DownloadManagerCustomData = @{ServerUrl =    "http://dnsvm:8080/PSDSCPullServer.svc"; AllowUnsecureConnection = "TRUE"}
     	}

        BuildSetup setupBuildMachine
        {
        }

        InstallTFS setupTFS
	{
	}

    }
}
