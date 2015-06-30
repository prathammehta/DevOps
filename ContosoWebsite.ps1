Configuration ContosoWebsite
{
  param ($MachineName)

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

    $string = @'
    
    Node $MachineName
    {
 
        Import-DscResource -Module ContosoDscResources

        ContosoPrintServer EnablePrintServer
        {
        }

        ContosoWebServer DisableWebServer
        {
        }
    }
'@

    Invoke-Expression $string
 
}