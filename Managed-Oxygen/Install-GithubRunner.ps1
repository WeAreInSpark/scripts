param(
  [Parameter(Mandatory)]
  [string]
  $version,
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

# Failsafe for version input
if ( $version[0] -ne "v" )
{
    $version = "v$version"
}
$versionUnprefixed = $version.Replace("v", "")

# Create a folder under the drive root
New-Item -Type Directory c:\actions-runner; Set-Location c:\actions-runner

# Download the runner package of specified $version
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/$version/actions-runner-win-x64-$versionUnprefixed.zip -OutFile actions-runner.zip

# Extract the package
Expand-Archive -Path actions-runner.zip -DestinationPath .
Remove-Item actions-runner.zip

# Install toolchain
Invoke-WebRequest -Uri https://raw.githubusercontent.com/WeAreInSpark/scripts/main/Managed-Oxygen/Install-Toolchain.ps1 -OutFile Install-Toolchain.ps1
./Install-Toolchain.ps1

# Get time limited registration token
$headers = @{Authorization = "Bearer $token"}
$registrationToken = Invoke-RestMethod -Method Post -Uri https://api.github.com/repos/WeAreInSpark/Solution.ManagedOxygen.Deployment/actions/runners/registration-token `
                                       -headers $headers `
                                       -ContentType "application/vnd.github+json" | Select-Object -ExpandProperty token

# Create the runner and start the configuration
./config.cmd --url https://github.com/$repo --token $registrationToken --labels $labels --unattended --replace --runasservice

# Reboot
Restart-Computer