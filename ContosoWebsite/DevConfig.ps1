Configuration DevConfig
{
    Import-DSCResource -ModuleName ContosoDscResources
    
    Node "localhost"
    {  
        DevSetup setupDevMachine
        {
        }

    }
}
