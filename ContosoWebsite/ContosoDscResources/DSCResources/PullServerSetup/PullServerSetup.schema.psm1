configuration PullServerSetup
{
	param 
        ( 
            [string[]]$NodeName = 'localhost', 
            [ValidateNotNullOrEmpty()] 
            [string] $certificateThumbPrint = "AllowUnencryptedTraffic"
        ) 
 
        Import-DSCResource -ModuleName DevOpsDesiredStateConfiguration 
  
        WindowsFeature WinAuth 
        { 
            Ensure = "Present" 
            Name   = "web-Windows-Auth"             
        } 
 
        DevOpsDscWebService PSDSCPullServer 
        { 
            Ensure                  = "Present" 
            EndpointName            = "PullSvc" 
            Port                    = 8080 
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer" 
            CertificateThumbPrint   = $certificateThumbPrint          
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules" 
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"             
            State                   = "Started" 
        } 
 
        DevOpsDSCWebService PSDSCComplianceServer 
        {   
            Ensure                  = "Present" 
            EndpointName            = "DscConformance" 
            Port                    = 9090 
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer" 
            CertificateThumbPrint   = "AllowUnencryptedTraffic" 
            State                   = "Started" 
            IsComplianceServer      = $true 
            DependsOn               = @("[WindowsFeature]WinAuth","[xDSCWebService]PSDSCPullServer") 
        }
}