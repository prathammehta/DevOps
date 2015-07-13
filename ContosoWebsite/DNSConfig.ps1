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

    $securePassword = ConvertTo-SecureString -AsPlainText $DomainAdminPassword -Force;
    $DomainAdminCred = New-Object System.Management.Automation.PSCredential($DomainAdminUsername, $securePassword);
   
    Node 'localhost'
    { 
	#ConfigurationBlock
    
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
         
        WindowsFeature ADDSInstall 
        {   
            	Ensure = 'Present'
            	Name = 'AD-Domain-Services'
            	IncludeAllSubFeature = $true
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
    #Begin Pull Configuration

        PullServerSetup ConfigurePull
        {
		DependsOn='[ADDomainController]SetupDomainController' 		
        }   
    } 
}