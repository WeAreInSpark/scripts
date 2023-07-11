[CmdletBinding()]
param(
  [Parameter(Mandatory)]
  [string]
  $repo,

  [Parameter(Mandatory)]
  [string]
  $token,

  [Parameter(Mandatory)]
  [string[]]
  $labels
)

"Creating temp dir"
$TempDir = 'c:\actions-runner'

# Failsafe for version input
if ( $version -match "v" ) {
  $version = $version.Replace("v", "")
}

# Create a folder under the drive root
if (!(Test-Path $TempDir)) {
  New-Item -Type Directory $TempDir
}

Set-Location $TempDir

"Downloading runner"
$url = Invoke-RestMethod -Uri "https://api.github.com/repos/actions/runner/releases/latest" |
        Select-Object -ExpandProperty assets |
        Where-Object { $_.name -match "win-x64(?=-\d+\.\d+\.\d+\.zip)" } |
        Select-Object -expand browser_download_url

# Download the runner package of specified $version
Invoke-WebRequest -Uri $url -OutFile actions-runner.zip

"Extracting runner"
# Extract the package
Expand-Archive -Path actions-runner.zip -DestinationPath . -Force
Remove-Item actions-runner.zip

"Installing toolchain"
# Install toolchain
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/WeAreInSpark/scripts/main/Managed-Oxygen/Install-Toolchain.ps1" -OutFile Install-Toolchain.ps1
./Install-Toolchain.ps1

"Getting new registration token"
$params = @{
  Method = 'POST'
  Uri = "https://api.github.com/repos/$repo/actions/runners/registration-token"
  Headers = @{
    Authorization = "Bearer $token" 
  }
  ContentType = "application/vnd.github+json"
}

$registrationToken = (Invoke-RestMethod @params).token

"Configuting runner"
# Create the runner and start the configuration
./config.cmd --url "https://github.com/$repo" --token $registrationToken --labels $labels --unattended --replace --runasservice

"Starting runner"
./run.cmd