[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $url,

    [Parameter(Mandatory=$true)]
    [string]
    $pat,

    [Parameter(Mandatory=$true)]
    [string]
    $pool,

    [Parameter(Mandatory=$true)]
    [string]
    $version,

    [Parameter(Mandatory=$true)]
    [string]
    $username,

    [Parameter(Mandatory=$true)]
    [SecureString]
    $password
)

# Create a folder under the drive root
New-Item -Type Directory c:\agent; Set-Location c:\agent

# Download the agent package of specified $version
Invoke-WebRequest -Uri https://vstsagentpackage.azureedge.net/agent/$version/vsts-agent-win-x64-$version.zip -OutFile c:\tmp\agent.zip

# Extract the agent
Expand-Archive -Path agent.zip -DestinationPath .
Remove-Item -Path agent.zip

# Install toolchain
Invoke-WebRequest -Uri https://raw.githubusercontent.com/WeAreInSpark/scripts/main/Managed-Oxygen/Install-Toolchain.ps1 -OutFile Install-Toolchain.ps1
./Install-Toolchain.ps1

# Configure agent
c:\agent\config --unattended --url $url --pool $pool --agent $env:computername --auth pat --token $pat --runAsService --windowsLogonAccount $agent\$username --windowsLogonPassword $password --replace

# Configure agent termination
$path = Join-Path $PSScriptRoot "Uninstall-ADOAgent.ps1"

$params = @{
    user = "System"
    taskname = "Watchdog"
    action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -File $path $pat"
    trigger = New-ScheduledTaskTrigger -Once -RepetitionInterval (New-TimeSpan -Minutes 1) -at (get-date)
    description = "Watch for VM termination events to deregister nodes from Azure DevOps"
    hidden = $true
}

Register-ScheduledTask @params

# Reboot
Restart-Computer