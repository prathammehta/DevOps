configuration BuildSetup
{
	"$(Get-Date) Build setup entered" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append
	WindowsFeature IIS
	{
		'name' = 'web-server'
		'ensure' = 'present'
	}

	"$(Get-Date) Build setup Finished"| Out-File -FilePath C:\users\Public\Documents\logs.txt -Append	
}