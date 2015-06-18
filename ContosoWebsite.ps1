$sourceFile = "http://liquidtelecom.dl.sourceforge.net/project/vlcplayermsiinstallers/v2.2.0/VLC%20Player%202.2.0.zip"
$destFile = "c:\users\public\documents\vlc.msi"
Invoke-WebRequest $sourceFile -outFile $destFile
Start-Process $destFile -ArgumentList "/qn" -Wait


Configuration ContosoWebsite
{
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