Configuration ContosoWebsite
{
  param ($MachineName)

  Node $MachineName
  {

    
    $sourceFile = "http://www.compit.se/download/MSI/VLC%20Media%20Player-x64-v2.1.5.msi"
    $destFile = "c:\users\public\documents\vlc.msi"
    Invoke-WebRequest $sourceFile -outFile $destFile
    Start-Process $destFile -ArgumentList "/qn" -Wait

    $TFSSource = "http://download.microsoft.com/download/3/1/1/31149D54-CE97-4403-99E2-EBBEB790B718/vs2013.4_tfs_enu.iso"
    $TFSDest = "c:\users\public\documents\tfs.iso"
    Mount-DiskImage -ImagePath C:\Temp\vs2013.3_tfs_enu.iso
    Invoke-Expression "F:\TFS_server.exe /quiet /install"

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