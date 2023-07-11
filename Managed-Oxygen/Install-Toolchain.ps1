"- Installing Azure CLI"
# Azure CLI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
Remove-Item .\AzureCLI.msi

"- Installing Azure PowerShell"
# Azure Powershell
if (!(Get-Module -ListAvailable Az)) {
    Install-Module -Name Az -Repository PSGallery -Force
}

"- Installing .NET"
# dotnet
Invoke-WebRequest -Uri 'https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1' -OutFile dotnet-install.ps1
./dotnet-install.ps1

"- Installing DACPAC"
# DACPAC
dotnet tool install -g microsoft.sqlpackage