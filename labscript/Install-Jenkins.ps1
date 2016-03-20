#Script to install Jenkins
Copy 'E:\Powershell\Modules\jenkins.msi' %TEMP%

$path = 'E:\Powershell\Modules\Devops_utils\Jenkins.msi'
$arguments = '/qn /L*V jenkins.log JENKINSDIR="C:\Program Files\jenkins"'


&$path $arguments
