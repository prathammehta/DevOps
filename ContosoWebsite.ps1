Configuration ContosoWebsite
{

  $sourceFile = "http://www.compit.se/download/MSI/VLC%20Media%20Player-x64-v2.1.5.msi"
  $destFile = "c:\users\public\documents\vlc.msi"
  Invoke-WebRequest $sourceFile -outFile $destFile
  Start-Process $destFile -ArgumentList "/qn" -Wait
	
  param ($MachineName)

  Node $MachineName
  {
    #Install the IIS Role
    WindowsFeature IIS
    {
      Ensure = “Present”
      Name = “Web-Server”
    }

    #Install ASP.NET 4.5
    WindowsFeature ASP
    {
      Ensure = “Present”
      Name = “Web-Asp-Net45”
    }

     WindowsFeature WebServerManagementConsole
    {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
    }
  }
} 