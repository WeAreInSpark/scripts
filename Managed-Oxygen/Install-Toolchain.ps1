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

# Powershell 7
Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.3.4/PowerShell-7.3.4-win-x64.msi -OutFile pwsh.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I pwsh.msi /quiet'
Remove-Item .\pwsh.msi