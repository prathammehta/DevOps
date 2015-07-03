configuration TestSetup
{
	WindowsFeature IIS
	{
		'name' = 'web-server'
		'ensure' = 'present'
	}
}