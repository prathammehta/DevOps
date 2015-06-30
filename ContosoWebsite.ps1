    $source = "https://codeload.github.com/prathammehta/DevOpsDSCResources/zip/master"
    $dest = "C:\Program Files\WindowsPowerShell\Modules\resource.zip"
    Invoke-WebRequest $source -OutFile $dest 
    
    $file = $dest 
    $destination = "C:\Program Files\WindowsPowerShell\Modules"

    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach($item in $zip.items())
    {
        $shell.Namespace($destination).copyhere($item)
    }
    
    cd "C:\Program Files\WindowsPowerShell\Modules\DevOpsDSCResources-master"
    Move-Item -Path "C:\Program Files\WindowsPowerShell\Modules\DevOpsDSCResources-master\ContosoDscResources" -Destination "C:\Program Files\WindowsPowerShell\Modules" 
    cd "C:\Program Files\WindowsPowerShell\Modules"
    Remove-Item $dest -Force -Recurse
    Remove-Item "C:\Program Files\WindowsPowerShell\Modules\DevOpsDSCResources-master" -Force -Recurse

    Add-WindowsFeature dsc-service
    Get-dscresource
  
 $dscconfig = @'
 Configuration ContosoWebsite
{
  param ($MachineName)

    Import-DSCResource -ModuleName ContosoDscResources
    
     
    Node $MachineName
    {

       

        ContosoPrintServer EnablePrintServer
        {
        }

        ContosoWebServer DisableWebServer
        {
        }
    }
   }
'@

Invoke-Expression $dscconfig

ContosoWebsite -MachineName devvm0 
