    $source = "https://codeload.github.com/prathammehta/DevOpsDSCResources/zip/master"
    $dest = "C:\Program Files\WindowsPowerShell\Modules\resource.zip"
    Invoke-WebRequest $source -OutFile $dest 
    
    "$(Get-Date) Module downloaded" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append

    $file = $dest 
    $destination = "C:\Program Files\WindowsPowerShell\Modules"

    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach($item in $zip.items())
    {
        $shell.Namespace($destination).copyhere($item)
    }

    "$(Get-Date) Module Unzipped" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append
    
    cd "C:\Program Files\WindowsPowerShell\Modules\DevOpsDSCResources-master"
    Move-Item -Path "C:\Program Files\WindowsPowerShell\Modules\DevOpsDSCResources-master\ContosoDscResources" -Destination "C:\Program Files\WindowsPowerShell\Modules" 
    cd "C:\Program Files\WindowsPowerShell\Modules"
    Remove-Item $dest -Force -Recurse
    Remove-Item "C:\Program Files\WindowsPowerShell\Modules\DevOpsDSCResources-master" -Force -Recurse

    "$(Get-Date) Module CleanUp completed" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append

    Add-WindowsFeature dsc-service
    Get-dscresource

    "$(Get-Date) Get DSCResource Completed" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append

    $ConfigData = @{
        AllNodes = @(
            @{ NodeName="localhost" ; PSDscAllowPlainTextPassword = $true }
    )};

    function Make-Credential
	{
		param (
			[Parameter(Mandatory=$true)]
			[string]$Username,
			[Parameter(Mandatory=$true)]
			[string]$Password
		)

		$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force;
		$credential = New-Object System.Management.Automation.PSCredential($Username, $securePassword);

		return $credential;
	}

	function Extract-ZIPFile
	{
		param (
			[Parameter(Mandatory=$true)]
			[string]
			$PathToZIP,
			[Parameter()]
			[string]
			$PathInsideZip="\",
			[Parameter(Mandatory=$true)]
			[string]
			$DestinationFolderPath
		)

		$shell = New-Object -ComObject Shell.Application;
		$zip = $shell.NameSpace(($PathToZIP+$PathInsideZip));
                
		foreach($item in $zip.items())
		{
			$shell.Namespace($DestinationFolderPath).copyhere($item);
		}
	}

	function Install-DSCResourceKit
	{
		param (
			[Parameter(Mandatory=$true)]
			[string]
			$downloadDirectory
		)

		$sourceURL = "https://gallery.technet.microsoft.com/scriptcenter/DSC-Resource-Kit-All-c449312d/file/131371/4/DSC%20Resource%20Kit%20Wave%2010%2004012015.zip";
		$destinationFileName = "DSCResourceKit.zip";
		$fullDestinationPath = ($downloadDirectory+"\"+$destinationFileName);

		# Download the DSC Resource Kit
		Write-Output "INFO: Fetching DSC Resource Kit from $sourceURL";
		Invoke-WebRequest $sourceURL -OutFile ($fullDestinationPath);

		# PowerShell module directory
		$psModuleDirectory = "$env:ProgramFiles\WindowsPowerShell\Modules";

		# If PowerShell Module Path does not exist. (Should always exist)
		if(!(Test-Path $psModuleDirectory)) {
			Write-Output "INFO: Powershell Module directory does not exist. Creating $psModuleDirectory...";
			New-Item -ItemType directory -Path $psModuleDirectory;
		}

		# Extract ZIP
		Write-Output "INFO: PowerShell Module directory Exists";
		Write-Output "INFO: Extracting to module directory $psModuleDirectory";
		Extract-ZIPFile -PathToZIP $fullDestinationPath -PathInsideZIP "\All Resources" -DestinationFolderPath $psModuleDirectory
	}

	function Setup-System
	{
		param (
			# Username of the administrator account when the VM was created.
			[Parameter(Mandatory=$true)]
			[string]
			$adminUserName
		)

		$downloadDirectory = ("C:\Users\Public\Downloads");

		# Install the DSC Resource Kit
		Write-Output "INFO: Installing DSC Resource Kit";
		Install-DSCResourceKit -downloadDirectory $downloadDirectory;

		# Configure WinRM
		Write-Output "INFO: Configuring WinRM"
		Enable-PSRemoting -Force -Verbose;

		# Allow File and Printer Sharing Firewall rule
		# ToDo
	}

	Setup-System -adminUserName "pratham"
  
 $dscconfig = @'
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
'@

Invoke-Expression $dscconfig

"$(Get-Date) Node block invoked" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append

ContosoWebsite -ConfigurationData $ConfigData -outputpath "c:\users\public\documents"

Start-DscConfiguration -ComputerName "localhost" -Path "c:\users\public\documents\" -Wait -Verbose

"$(Get-Date) Configuration function called" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append
