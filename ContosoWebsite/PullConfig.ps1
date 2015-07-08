Configuration PullConfig
{
    Import-DSCResource -ModuleName ContosoDscResources
    
    Node "localhost"
    {  
      	PullServerSetup ConfigurePull
        {
		
        }
    }
}
