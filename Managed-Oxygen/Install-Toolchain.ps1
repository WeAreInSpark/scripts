# Azure CLI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi;
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet';
Remove-Item .\AzureCLI.msi

# Azure Powershell
Invoke-WebRequest -Uri https://github.com/Azure/azure-powershell/releases/download/v10.0.0-June2023/Az-Cmdlets-10.0.0.37310-x64.msi -OutFile AzCmdlets.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzCmdlets.msi /quiet';
Remove-Item .\AzCmdlets.msi

# dotnet
Invoke-WebRequest -URI https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1
./dotnet-install.ps1

# DACPAC
dotnet tool install -g microsoft.sqlpackage