Configuration DNSConfig
{ 
    
     param
    ( 
         
        [Parameter()][string]$DomainName = "internaldomain.com",
        [Parameter(Mandatory=$true)][string]$DomainAdminUsername,
        [Parameter(Mandatory=$true)][string]$DomainAdminPassword
    ) 
        
    #Import the required DSC Resources  
    Import-DscResource -ModuleName xComputerManagement 
    Import-DscResource -ModuleName DevOpsActiveDirectory
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xRemoteDesktopAdmin
    Import-DscResource -ModuleName ContosoDscResources
    Import-DscResource -ModuleName xPendingReboot
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $securePassword = ConvertTo-SecureString -AsPlainText $DomainAdminPassword -Force;
    $DomainAdminCred = New-Object System.Management.Automation.PSCredential($DomainAdminUsername, $securePassword);
   
    Node 'localhost'
    { 
    
    #LCM configuration

    xPendingReboot Reboot1 
    { 
        Name = 'BeforeSoftwareInstall' 
  	} 
    LocalConfigurationManager 
    { 
        RebootNodeIfNeeded = $True 
   	}

	xRemoteDesktopAdmin RDPAdmin 
	{
		Ensure = "Present"
		UserAuthentication = "NonSecure"
	}

	WindowsFeature DSCService 
	{
            	Name = "DSC-Service"
            	Ensure = "Present"
            	IncludeAllSubFeature = $true
	    	DependsOn = "[xRemoteDesktopAdmin]RDPAdmin"
        }

        PullServerSetup ConfigurePull
        {
		DependsOn='[WindowsFeature]DSCService' 		
        } 

	#ConfigurationBlock

        WindowsFeature ADDSInstall 
        {   
            	Ensure = 'Present'
            	Name = 'AD-Domain-Services'
            	IncludeAllSubFeature = $true
		DependsOn = '[PullServerSetup]ConfigurePull'
        }
         
        WindowsFeature RSATTools 
        { 
            	DependsOn= '[WindowsFeature]ADDSInstall'
            	Ensure = 'Present'
            	Name = 'RSAT-AD-Tools'
            	IncludeAllSubFeature = $true
        }

        ADDomain SetupDomain 
	{	
            	DomainName = $DomainName
            	DomainAdministratorUsername = $DomainAdminUsername
            	DomainAdministratorPassword = $DomainAdminPassword
            	SafemodeAdministratorUsername = $DomainAdminUsername
            	SafemodeAdministratorPassword = $DomainAdminPassword
            	DependsOn='[WindowsFeature]RSATTools'
        }
 
        ADDomainController SetupDomainController 
	{
            	DomainName = $DomainName
            	DomainAdministratorUsername = $DomainAdminUsername
            	DomainAdministratorPassword = $DomainAdminPassword
            	SafemodeAdministratorUsername = $DomainAdminUsername
            	SafemodeAdministratorPassword = $DomainAdminPassword
            	DependsOn='[ADDomain]SetupDomain'
        }	

    #End Configuration Block 
    } 
}