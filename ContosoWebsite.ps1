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
  
 $dscconfig = @'
 Configuration ContosoWebsite
{
  param ($MachineName)

    Import-DSCResource -ModuleName ContosoDscResources
    
    "$(Get-Date) Module Imported" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append 

    Node "localhost"
    {

       

        ContosoPrintServer EnablePrintServer
        {
        }

        "$(Get-Date) Print server installed" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append

        ContosoWebServer DisableWebServer
        {
        }

        "$(Get-Date) WebServer Disabled" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append
    }
   }
'@

Invoke-Expression $dscconfig

"$(Get-Date) Node block invoked" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append

ContosoWebsite -MachineName devvm0 

"$(Get-Date) Configuration function called" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append