Configuration PullConfig
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $DomainName
    )

    Import-DSCResource -ModuleName ContosoDscResources
    
    Node "localhost"
    {  
        CommonSetup commonSetup
        {
            DomainName = $DomainName
        }

      	PullServerSetup ConfigurePull
        {
		
        }
    }
}
