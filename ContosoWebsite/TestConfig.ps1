Configuration TestConfig
{
    Import-DSCResource -ModuleName ContosoDscResources
    
    Node "localhost"
    {  
        TestSetup setupTestMachine
        {
        }

    }
}
