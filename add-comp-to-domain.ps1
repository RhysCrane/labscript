#join server to domain 

$domain = Read-Host('Enter domain Name')
Add-Computer -DomainName $domain -Credential (Get-Credential) -Restart -Verbose
#if successful - restart-computer