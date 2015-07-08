configuration PullServerSetup
{
	param 
        ( 
            [string[]]$NodeName = 'localhost', 
            [ValidateNotNullOrEmpty()] 
            [string] $certificateThumbPrint = "AllowUnencryptedTraffic"
        ) 
 
        Import-DSCResource -ModuleName xPSDesiredStateConfiguration 
  
        WindowsFeature DSCServiceFeature 
        { 
            Ensure = "Present" 
            Name   = "DSC-Service"             
        } 
 
        WindowsFeature WinAuth 
        { 
            Ensure = "Present" 
            Name   = "web-Windows-Auth"             
        } 
 
        xDscWebService PSDSCPullServer 
        { 
            Ensure                  = "Present" 
            EndpointName            = "PullSvc" 
            Port                    = 8080 
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer" 
            CertificateThumbPrint   = $certificateThumbPrint          
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules" 
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"             
            State                   = "Started" 
            DependsOn               = "[WindowsFeature]DSCServiceFeature"                         
        } 
 
        xDscWebService PSDSCComplianceServer 
        {   
            Ensure                  = "Present" 
            EndpointName            = "DscConformance" 
            Port                    = 9090 
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer" 
            CertificateThumbPrint   = "AllowUnencryptedTraffic" 
            State                   = "Started" 
            IsComplianceServer      = $true 
            DependsOn               = @("[WindowsFeature]DSCServiceFeature","[WindowsFeature]WinAuth","[xDSCWebService]PSDSCPullServer") 
        }
}