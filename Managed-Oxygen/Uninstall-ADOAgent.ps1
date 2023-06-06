
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [SecureString]
    $pat
)

$events = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri "http://169.254.169.254/metadata/scheduledevents?api-version=2020-07-01" | Select-Object -ExpandProperty events
$instance_name = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET  -Uri "http://169.254.169.254/metadata/instance/compute?api-version=2021-02-01" | Select-Object -ExpandProperty Name

foreach($event in $events){

    if($event.EventType -eq "Terminate" -and $instance_name -in $event.Resources){
        # VM is scheduled to shutdown. Uninstall runtime to deregister this node
        c:\agent\config remove --unattended --auth pat --token (ConvertFrom-SecureString -AsPlainText $pat)

        # Acknowledge event to expedite shutdown
        $id = $event.EventId

        $params = @{
            Headers = @{"Metadata" = "true"}
            Method = "POST"
            body = "{""StartRequests"": [{""EventId"": ""$id""}]}"
            Uri = "http://169.254.169.254/metadata/scheduledevents?api-version=2020-07-01"
        }
        Invoke-RestMethod @params
    }

}