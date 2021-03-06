configuration InstallTFS
{
    "$(Get-Date) TFS download started"| Out-File -FilePath C:\users\Public\Documents\logs.txt -Append	
    $TFSSource = "http://download.microsoft.com/download/3/1/1/31149D54-CE97-4403-99E2-EBBEB790B718/vs2013.4_tfs_enu.iso"
    $TFSDest = "c:\users\public\documents\tfs.iso"
    Invoke-WebRequest $TFSSource -outFile $TFSDest
    "$(Get-Date) TFS download completed"| Out-File -FilePath C:\users\Public\Documents\logs.txt -Append	
    
    #Mount ISO & run file
    
    $mountResult = Mount-DiskImage -ImagePath $TFSDest -PassThru
    $driveLetter = ($mountResult | Get-Volume).DriveLetter
    $loc = ("$driveletter" + ":\TFS_Server.exe /quiet /install")
    Invoke-Expression $loc
    "$(Get-Date) TFS setup finished"| Out-File -FilePath C:\users\Public\Documents\logs.txt -Append	
}