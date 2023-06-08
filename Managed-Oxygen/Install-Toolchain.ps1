# Azure CLI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi;
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet';
Remove-Item .\AzureCLI.msi

# Azure Powershell
Install-Module -Name Az -Repository PSGallery -Force

# dotnet
Invoke-WebRequest -URI https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1
./dotnet-install.ps1

# DACPAC
dotnet tool install -g microsoft.sqlpackage

# Bicep

# Fetch the latest Bicep CLI binary
$InstallPath = "C:\Program Files\Bicep"
New-Item -Type Directory $InstallPath
Invoke-WebRequest -Uri https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe -OutFile "$InstallPath\bicep.exe"

# Add bicep to path
$Path = [Environment]::GetEnvironmentVariable("PATH", "Machine") + [IO.Path]::PathSeparator + $InstallPath
[Environment]::SetEnvironmentVariable("PATH", $Path, "Machine")