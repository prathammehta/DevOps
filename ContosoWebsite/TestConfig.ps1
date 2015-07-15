Configuration TestConfig
{
    Import-DSCResource -ModuleName ContosoDscResources
    
    Node "localhost"
    {  
	Configuration SimpleMetaConfigurationForPull 
	{ 

            Param
            (
            [Parameter(Mandatory=$True)]
            
            [String]$mac,
            [String]$user,
            [String]$pass
            )

	    $source = "http://dnsvm:9090/dscnodes.csv"
	    $destination = "c:\newdata.csv"
	    $secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
	    $credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)

    	    Invoke-WebRequest $source -OutFile $destination -Credential $credential

	    $data = import-csv "C:\newdata.csv" -header("NodeName","NodeGUID")

	    $NodeGUID =($data | where-object {$_."NodeName" -match $mac}).NodeGUID #or -eq 

     	    LocalConfigurationManager 
	    { 
       		ConfigurationID = $NodeGUID;
       		RefreshMode = "PULL";
       		DownloadManagerName = "WebDownloadManager";
       		RebootNodeIfNeeded = $true;
       		RefreshFrequencyMins = 30;
       		ConfigurationModeFrequencyMins = 30; 
       		ConfigurationMode = "ApplyAndAutoCorrect";
       		DownloadManagerCustomData = @{ServerUrl =    "http://dnsvm:8080/PSDSCPullServer.svc"; AllowUnsecureConnection = “TRUE”}
     	    } 
     
        }  


        SimpleMetaConfigurationForPull  -Output "." -mac "testvm0" -user "sampra" -pass "Applegr8"

        $FilePath = (Get-Location -PSProvider FileSystem).Path + "\SimpleMetaConfigurationForPull"

        Set-DscLocalConfigurationManager -ComputerName "localhost" -Path $FilePath -Verbose

        TestSetup setupTestMachine
        {
        }
    }
}
