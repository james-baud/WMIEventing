function Add-WmiEventFilter
{
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $True)]
            [string[]]$ComputerName = 'localhost',
        [Parameter(Mandatory = $True)]
            [string]$Name,
        [Parameter()]
            [string]$EventNamespace = 'root\cimv2',
        [Parameter(Mandatory = $True)]
            [string]$Query,
        [Parameter()]
            [string]$QueryLanguage = 'WQL' 
    )

    BEGIN
    {
        $props = @{
            'Name' = $Name;
            'EventNamespace' = $EventNamespace;
            'Query' = $Query;
            'QueryLanguage' = $QueryLanguage
        }
    }

    PROCESS
    {
       $jobs = Set-WmiInstance -ComputerName $ComputerName -Namespace root\subscription -Class __EventFilter -Arguments $props -AsJob
    }

    END
    {
        Receive-Job -Job $jobs -Wait -AutoRemoveJob
    }
}