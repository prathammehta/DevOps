Configuration BuildConfig
{
    Import-DSCResource -ModuleName ContosoDscResources
    


    Node "localhost"
    {  
        BuildSetup setupBuildMachine
        {
        }

        InstallTFS setupTFS
	{
	}

    }
}
