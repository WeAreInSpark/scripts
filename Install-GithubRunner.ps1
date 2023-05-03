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

# Create a folder under the drive root
mkdir actions-runner; cd actions-runner

# Download the latest runner package
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/$version/actions-runner-win-x64-$version.zip -OutFile actions-runner.zip

# Extract the installer
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner.zip", "$PWD")

# Create the runner and start the configuration experience
./config.cmd --url https://github.com/$repo --token $token --labels $labels

# Run
./run.cmd