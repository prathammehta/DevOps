Configuration PrintServer
{
    param ($NodeFQDN)

    function Expand-ZIPFile($file, $destination)
    {
        $shell = new-object -com shell.application
        $zip = $shell.NameSpace($file)
        foreach($item in $zip.items())
        {
            $shell.Namespace($destination).copyhere($item)
        }
    }


    $source = "https://codeload.github.com/prathammehta/DevOpsDSCResources/zip/master"
    $dest = "C:\Program Files\WindowsPowerShell\Modules\resource.zip"
    Invoke-WebRequest $source -OutFile $dest 
    Expand-ZIPFile -file $dest -destination "C:\Program Files\WindowsPowerShell\Modules"
    
    cd "C:\Program Files\WindowsPowerShell\Modules\DevOpsDSCResources-master"
    Move-Item -Path "C:\Program Files\WindowsPowerShell\Modules\DevOpsDSCResources-master\ContosoDscResources" -Destination "C:\Program Files\WindowsPowerShell\Modules" 
    cd "C:\Program Files\WindowsPowerShell\Modules"
    Remove-Item $dest -Force -Recurse
    Remove-Item "C:\Program Files\WindowsPowerShell\Modules\DevOpsDSCResources-master" -Force -Recurse

 
    Import-DscResource -Module ContosoDscResources
 
    Node $NodeFQDN
    {
        ContosoPrintServer EnablePrintServer
        {
        }

        ContosoWebServer DisableWebServer
        {
        }
    }
 
}

cd C:\Users\sampra\Desktop
 
PrintServer -NodeFQDN "testvm0"