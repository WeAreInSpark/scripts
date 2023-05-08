param(
  [Parameter(Mandatory)]
  [string]
  $key
)

function Download-Gateway([string] $path)
{
    $URL = "https://go.microsoft.com/fwlink/?linkid=839822"

    $request = [System.Net.WebRequest]::Create($url)
    $request.AllowAutoRedirect = $false
    $response = $request.GetResponse()

    If ($response.StatusCode -eq "Found") {
        $uri = $response.GetResponseHeader("Location")
    } else {
      throw "Unable to find Integration Runtime installer URL."
    }

    (New-Object System.Net.WebClient).DownloadFile($uri, $path)

    if (-Not (Test-Path $path -PathType Leaf)) {
        throw "Cannot download Integration Runtime installer to $path."
    }

    Write-Host "Integration Runtime installer has been downloaded to $path."
}

function Install-Gateway([string] $gwPath)
{

    Write-Host "Start Microsoft Integration Runtime installation"
    
    $process = Start-Process "msiexec.exe" "/i $gwPath /quiet /passive" -Wait -PassThru
    if ($process.ExitCode -ne 0)
    {
        throw "Failed to install Microsoft Integration Runtime. msiexec exit code: $($process.ExitCode)"
    }

    Write-Host "Succeed to install Microsoft Integration Runtime"
}

function Register-Gateway([string] $key, [string] $port, [string] $cert)
{
    $cmd = Get-CmdFilePath

    if (![string]::IsNullOrEmpty($port))
    {
        Write-Host "Start to enable remote access."
        $process = Start-Process $cmd "-era $port $cert" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0)
        {
            throw "Failed to enable remote access. Exit code: $($process.ExitCode)"
        }
        Write-Host "Succeed to enable remote access."
    }

    Write-Host "Start to register Microsoft Integration Runtime with key $key."
    $process = Start-Process $cmd "-rn $key $node" -Wait -PassThru -NoNewWindow

    if ($process.ExitCode -ne 0)
    {
            throw "Failed to register Microsoft Integration Runtime. Exit code: $($process.ExitCode)"
    }

    Write-Host "Succeed to register Microsoft Integration Runtime."
}

function Get-CmdFilePath()
{
    $filePath = Get-ItemPropertyValue "hklm:\Software\Microsoft\DataTransfer\DataManagementGateway\ConfigurationManager" "DiacmdPath"
    if ([string]::IsNullOrEmpty($filePath))
    {
        throw "Get-InstalledFilePath: Cannot find installed File Path"
    }

    return (Split-Path -Parent $filePath) + "\dmgcmd.exe"
}

function Create-ScheduledTask()
{

  $path = Join-Path $PSScriptRoot "uninstall-runtime.ps1"

  $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-NoProfile -File $path"

  $trigger = New-ScheduledTaskTrigger -Once -RepetitionInterval (New-TimeSpan -Minutes 1) -at (get-date) 
  Register-ScheduledTask -User System -Action $action -Trigger $trigger -TaskName "Watchdog" -Description "Watch for VM termination events to deregister nodes from ADF runtime"
}

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

$installerPath = Join-Path $PSScriptRoot "IntegrationRuntime.msi"

Download-Gateway $installerPath
Install-Gateway $installerPath
Register-Gateway $key 80
Create-ScheduledTask