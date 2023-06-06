# Azure CLI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; 
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; 
Remove-Item .\AzureCLI.msi

# Azure Powershell
Install-Module -Name Az -Repository PSGallery -Force

# dotnet
Invoke-WebRequest -URI https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1 -UseBasicParsing | Invoke-Expression

# DACPAC
dotnet tool install -g microsoft.sqlpackage