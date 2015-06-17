function Format-DscScriptBlock()
{
    param(
        [parameter(Mandatory=$true)]
        [System.Collections.Hashtable] $Params,
        [parameter(Mandatory=$true)]
        [System.Management.Automation.ScriptBlock] $ScriptBlock
    )






    $result = $ScriptBlock.ToString();
    foreach( $key in $Params.Keys )
    {
        $result = $result.Replace("`$$key", $Params[$key]);
    }
    return $result;
}
Clear-Host




#PRATHAM IS AWEOMSE

# Params
$Params = @{
    "FWLookupZoneName" = "ak-network.com";
    "ServerName" = "ak-testvm-02";
}

Configuration DNSServerConfiguration
{
    Node $Params.ServerName {
        
        # Enable the DNS Windows Feature
        WindowsFeature DNS {
            Name = "DNS"
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        # Enable the DNS Manager
        WindowsFeature DNSTools {
            Name = "RSAT-DNS-Server"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]DNS"
        }

        # Script to set the DNS forward lookup zone.
        # This will be the same as the primary DNS suffix of all VMs in the subnet
        Script DNSForwardZone { 

            TestScript = Format-DscScriptBlock -Params $Params -ScriptBlock { 
                # Write-Output "INFO: Checking if Forward Lookup Zone '$FWLookupZoneName' exists"
                $ZoneClass = Get-WMIObject MicrosoftDNS_Zone -Namespace "root\MicrosoftDNS" -ComputerName "$ServerName" -Filter "ContainerName='$FWLookupZoneName'"
                if(!(!($ZoneClass))) {
                    # Write-Output "INFO: Forward Lookup Zone '$FWLookupZoneName' exists"
                    $true
                } else {
                    $false
                }
            }

            SetScript = Format-DscScriptBlock -Params $Params -ScriptBlock {
                ([WMIClass]"\\localhost\root\MicrosoftDNS:MicrosoftDNS_Zone").CreateZone($FWLookupZoneName, 0)
                dnscmd /config $FWLookupZoneName /AllowUpdate 1
            } 

            GetScript = {
                @{"ScriptName" = "DNSForwardZone"; "ScriptAction" = "Set Forward Zone"}
            }

            DependsOn = "[WindowsFeature]DNSTools"
        }

        Registry ZoneUpdateSetting {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
            ValueName = "Domain"
            ValueData = $Params.FWLookupZoneName
            DependsOn = "[Script]DNSForwardZone"
        }

    }
}

DNSServerConfiguration

Start-DscConfiguration -Path ./DNSServerConfiguration -ComputerName $Params.ServerName -Verbose -Wait -Force

Restart-Computer -ComputerName $Params.ServerName
