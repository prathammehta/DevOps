configuration TestSetup
{
	"$(Get-Date) Test setup entered" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append
	WindowsFeature IIS
	{
		'name' = 'web-server'
		'ensure' = 'present'
	}
	"$(Get-Date) Test setup Finished"| Out-File -FilePath C:\users\Public\Documents\logs.txt -Append
}