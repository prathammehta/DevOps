Configuration TestConfig {

    Param(
        [Parameter(Mandatory=$True)]
        [String[]]$NodeGUID
    )
    
    Node $NodeGUID {

       WindowsFeature IIS  
        {  
            Ensure          = "Present"  
            Name            = "Web-Server"  
        } 

    }
}

$Computers = @("testvm","devvm","buildvm")

write-host "Generating GUIDs and creating MOF files..."
foreach ($Node in $Computers)
{
    $NewGUID = [guid]::NewGuid()
    $NewLine = "{0},{1}" -f $Node,$NewGUID
    TestConfig -NodeGUID $NewGUID
    $NewLine | add-content -path "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer\dscnodes.csv"
}

write-host "Creating checksums..."
New-DSCCheckSum -ConfigurationPath .\TestConfig -OutPath .\TestConfig -Verbose -Force

write-host "Copying configurations to pull service configuration store..."
$SourceFiles = (Get-Location -PSProvider FileSystem).Path + "\TestConfig\*.mof*"
$TargetFiles = "$env:SystemDrive\Program Files\WindowsPowershell\DscService\Configuration"
Move-Item $SourceFiles $TargetFiles -Force
Remove-Item ((Get-Location -PSProvider FileSystem).Path + "\TestConfig\")
