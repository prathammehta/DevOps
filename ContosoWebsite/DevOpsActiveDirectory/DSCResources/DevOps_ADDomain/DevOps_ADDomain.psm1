#
# xADDomain: DSC resource to install a new Active Directory forest
# configuration, or a child domain in an existing forest.
#

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [String]$ParentDomainName,

        [String]$DomainNetbiosName,

        [Parameter(Mandatory)]
        [string]$DomainAdministratorUsername,

        [Parameter(Mandatory)]
        [string]$DomainAdministratorPassword,

        [Parameter(Mandatory)]
        [string]$SafemodeAdministratorUsername,

        [Parameter(Mandatory)]
        [string]$SafemodeAdministratorPassword,

        [PSCredential]$DnsDelegationCredential,

        [String]$DatabasePath,

        [String]$LogPath,

        [String]$SysvolPath
    )

    $DomainAdministratorCredential = New-Object System.Management.Automation.PSCredential(
                                            $DomainAdministratorUsername, (ConvertTo-SecureString -String $DomainAdministratorPassword -AsPlainText -Force)
                                        );
    $SafemodeAdministratorCredential = New-Object System.Management.Automation.PSCredential(
                                            $SafemodeAdministratorUsername, (ConvertTo-SecureString -String $SafemodeAdministratorPassword -AsPlainText -Force)
                                        );

    try
    {
        $fullDomainName = $DomainName
        if ($ParentDomainName)
        {
            $fullDomainName = $DomainName + "." + $ParentDomainName
        }

        Write-Verbose -Message "Resolving '$($fullDomainName)' ..."
        $domain = Get-ADDomain -Identity $fullDomainName -Credential $DomainAdministratorCredential
        if ($domain -ne $null)
        {
            Write-Verbose -Message "Domain '$($fullDomainName)' is present. Looking for DCs ..."
            try
            {
                $dc = Get-ADDomainController -Identity $env:COMPUTERNAME -Credential $DomainAdministratorCredential
                Write-Verbose -Message "Found domain controller '$($dc.Name)' in domain '$($dc.Domain)'."
                Write-Verbose -Message "Found parent domain '$($dc.ParentDomain)', expected '$($ParentDomainName)'."
                if (($dc.Domain -eq $DomainName) -and ((!($dc.ParentDomain) -and !($ParentDomainName)) -or ($dc.ParentDomain -eq $ParentDomainName)))
                {
                    Write-Verbose -Message "Current node '$($dc.Name)' is already a domain controller for domain '$($dc.Domain)'."
                }
            }
            catch
            {
                Write-Verbose -Message "Current node does not host a domain controller."
            }
        }
    }
    catch
    {
        if ($error[0]) {Write-Verbose $error[0].Exception}
        Write-Verbose -Message "Current node is not running AD WS, and hence is not a domain controller."
    }
    @{
        DomainName = $dc.Domain
    }
}

function Set-TargetResource
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [String]$ParentDomainName,

        [String]$DomainNetbiosName,

        [Parameter(Mandatory)]
        [string]$DomainAdministratorUsername,

        [Parameter(Mandatory)]
        [string]$DomainAdministratorPassword,

        [Parameter(Mandatory)]
        [string]$SafemodeAdministratorUsername,

        [Parameter(Mandatory)]
        [string]$SafemodeAdministratorPassword,

        [PSCredential]$DnsDelegationCredential,

        [String]$DatabasePath,

        [String]$LogPath,

        [String]$SysvolPath
    )

    $DomainAdministratorCredential = New-Object System.Management.Automation.PSCredential(
                                            $DomainAdministratorUsername, (ConvertTo-SecureString -String $DomainAdministratorPassword -AsPlainText -Force)
                                        );
    $SafemodeAdministratorCredential = New-Object System.Management.Automation.PSCredential(
                                            $SafemodeAdministratorUsername, (ConvertTo-SecureString -String $SafemodeAdministratorPassword -AsPlainText -Force)
                                        );

    # Debug can pause Install-ADDSForest/Install-ADDSDomain, so we remove it.
    $parameters = $PSBoundParameters.Remove("Debug");

    $fullDomainName = $DomainName
    if ($ParentDomainName)
    {
        $fullDomainName = $DomainName + "." + $ParentDomainName
    }

    Write-Verbose -Message "Checking if domain '$($fullDomainName)' is present ..."
    $domain = $null;
    try
    {
        $domain = Get-ADDomain -Identity $fullDomainName -Credential $DomainAdministratorCredential
    }
    catch
    {
    }
    if ($domain -ne $null)
    {
        throw (new-object -TypeName System.InvalidOperationException -ArgumentList "Domain '$($Name)' is already present, but it is not hosted by this node.")
    }

    Write-Verbose -Message "Verified that domain '$($DomainName)' is not already present, continuing ..."
    if (($ParentDomainName -eq $null) -or ($ParentDomainName -eq ""))
    {
        Write-Verbose -Message "Domain '$($DomainName)' is NOT present. Creating forest '$($DomainName)' ..."
        $params = @{
            DomainName = $DomainName
            InstallDns = $true
            NoRebootOnCompletion = $true
            Force = $true
        }
        if ($DomainNetbiosName -ne $null)
        {
            $params.Add("DomainNetbiosName", $DomainNetbiosName)
        }
        if ($DnsDelegationCredential -ne $null)
        {
            $params.Add("DnsDelegationCredential", $DnsDelegationCredential)
            $params.Add("CreateDnsDelegation", $true)
        }
        if ($DatabasePath -ne $null)
        {
            $params.Add("DatabasePath", $DatabasePath)
        }
        if ($LogPath -ne $null)
        {
            $params.Add("LogPath", $LogPath)
        }
        if ($SysvolPath -ne $null)
        {
            $params.Add("SysvolPath", $SysvolPath)
        }

        Install-ADDSForest @params -SafeModeAdministratorPassword $SafemodeAdministratorCredential.Password
        Write-Verbose -Message "Created forest '$($DomainName)'."
    }
    else
    {
        Write-Verbose -Message "Domain '$($DomainName)' is NOT present. Creating domain '$($DomainName)' as a child of '$($ParentDomainName)' ..."
        $params = @{
            NewDomainName = $DomainName
            ParentDomainName = $ParentDomainName
            DomainType = [Microsoft.DirectoryServices.Deployment.Types.DomainType]::ChildDomain
            InstallDns = $true
            NoRebootOnCompletion = $true
            Force = $true
        }
        if ($DomainNetbiosName -ne $null)
        {
            $params.Add("DomainNetbiosName", $DomainNetbiosName)
        }
        if ($DnsDelegationCredential -ne $null)
        {
            $params.Add("DnsDelegationCredential", $DnsDelegationCredential)
            $params.Add("CreateDnsDelegation", $true)
        }
        if ($DatabasePath -ne $null)
        {
            $params.Add("DatabasePath", $DatabasePath)
        }
        if ($LogPath -ne $null)
        {
            $params.Add("LogPath", $LogPath)
        }
        if ($SysvolPath -ne $null)
        {
            $params.Add("SysvolPath", $SysvolPath)
        }

        Install-ADDSDomain @params -SafeModeAdministratorPassword $SafemodeAdministratorCredential.Password -Credential $DomainAdministratorCredential
        Write-Verbose -Message "Created domain '$($DomainName)'."
    }

    if ($error[0]) {Write-Verbose $error[0].Exception}

    # Signal to the LCM to reboot the node to compensate for the one we
    # suppressed from Install-ADDSForest/Install-ADDSDomain
    $global:DSCMachineStatus = 1
}

function Test-TargetResource
{
	[OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [String]$ParentDomainName,

        [String]$DomainNetbiosName,

        [Parameter(Mandatory)]
        [string]$DomainAdministratorUsername,

        [Parameter(Mandatory)]
        [string]$DomainAdministratorPassword,

        [Parameter(Mandatory)]
        [string]$SafemodeAdministratorUsername,

        [Parameter(Mandatory)]
        [string]$SafemodeAdministratorPassword,

        [PSCredential]$DnsDelegationCredential,

        [String]$DatabasePath,

        [String]$LogPath,

        [String]$SysvolPath
    )

    $DomainAdministratorCredential = New-Object System.Management.Automation.PSCredential(
                                            $DomainAdministratorUsername, (ConvertTo-SecureString -String $DomainAdministratorPassword -AsPlainText -Force)
                                        );
    $SafemodeAdministratorPassword = New-Object System.Management.Automation.PSCredential(
                                            $SafemodeAdministratorUsername, (ConvertTo-SecureString -String $SafemodeAdministratorPassword -AsPlainText -Force)
                                        );
    try
    {
        $parameters = $PSBoundParameters.Remove("Debug");
        $existingResource = Get-TargetResource @PSBoundParameters
        $existingResource.DomainName -eq $DomainName
    }
    catch
    {
        Write-Verbose -Message "Domain '$($Name)' is NOT present on the current node."
        $false
    }
}


Export-ModuleMember -Function *-TargetResource
