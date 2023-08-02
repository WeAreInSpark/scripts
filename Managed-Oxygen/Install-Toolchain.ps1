"- Installing Azure CLI"
# Azure CLI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
Remove-Item .\AzureCLI.msi

"- Installing Azure PowerShell"
# Azure Powershell
if (!(Get-Module -ListAvailable Az)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name Az -Repository PSGallery -Force
}

"- Installing .NET"
# dotnet
Invoke-WebRequest -Uri 'https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1' -OutFile dotnet-install.ps1
./dotnet-install.ps1
dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org

"- Installing DACPAC"
# DACPAC
dotnet tool install -g microsoft.sqlpackage
dotnet tool install --global PowerShell --version 6.2.2
dotnet add package Microsoft.SqlServer.DacFx

"- Setting environment variables"
[System.Environment]::SetEnvironmentVariable('SqlPackage','C:\Windows\system32\config\systemprofile\.dotnet\tools\sqlpackage.exe', 'Machine')
