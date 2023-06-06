param (
    [string][Parameter(Mandatory=$true)]$url,
    [string][Parameter(Mandatory=$true)]$pat,
    [string][Parameter(Mandatory=$true)]$pool,
    [string][Parameter(Mandatory=$true)]$version,
    [string][Parameter(Mandatory=$true)]$username,
    [string][Parameter(Mandatory=$true)]$password
)

# Get agent
New-Item -Type Directory -Force "c:\tmp"
Invoke-WebRequest -Uri "https://vstsagentpackage.azureedge.net/agent/$version/vsts-agent-win-x64-$version.zip" -OutFile "c:\tmp\agent.zip" -UseBasicParsing
Expand-Archive -Path "c:\tmp\agent.zip" -DestinationPath "c:\agent"
Remove-Item -Path "c:\tmp\agent.zip"

# Configure agent
c:\agent\config --unattended --url $url --pool $pool --agent $env:computername --auth pat --token $pat --runAsService --windowsLogonAccount $agent\$username --windowsLogonPassword $password --replace

# Configure agent termination
$path = Join-Path $PSScriptRoot "Uninstall-ADOAgent.ps1"
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -File $path $(ConvertTo-SecureString -String $pat -AsPlainText)"
$trigger = New-ScheduledTaskTrigger -Once -RepetitionInterval (New-TimeSpan -Minutes 1) -at (get-date)


Register-ScheduledTask -User System -Action $action -Trigger $trigger -TaskName "Watchdog" -Description "Watch for VM termination events to deregister nodes from Azure DevOps"