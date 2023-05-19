param (
    [string][Parameter(Mandatory=$true)]$url,
    [string][Parameter(Mandatory=$true)]$pat,
    [string][Parameter(Mandatory=$true)]$pool,
    [string][Parameter(Mandatory=$true)]$version,
    [string][Parameter(Mandatory=$true)]$username,
    [string][Parameter(Mandatory=$true)]$password
)

mkdir -force "c:\tmp"
Invoke-WebRequest -Uri "https://vstsagentpackage.azureedge.net/agent/$version/vsts-agent-win-x64-$version.zip" -OutFile "c:\tmp\agent.zip" -UseBasicParsing
Expand-Archive -Path "c:\tmp\agent.zip" -DestinationPath "c:\agent"
c:\agent\config --unattended --url $url --pool $pool --agent $env:computername --auth pat --token $pat --runAsService --windowsLogonAccount $agent\$username --windowsLogonPassword $password --replace