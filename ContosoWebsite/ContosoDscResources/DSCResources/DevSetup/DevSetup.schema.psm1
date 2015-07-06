configuration DevSetup
{
	"$(Get-Date) Dev setup entered" | Out-File -FilePath C:\users\Public\Documents\logs.txt -Append
	WindowsFeature IIS
	{
		'name' = 'web-server'
		'ensure' = 'present'
	}
	"$(Get-Date) Dev setup Finished"| Out-File -FilePath C:\users\Public\Documents\logs.txt -Append
}