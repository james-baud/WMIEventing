function Get-WmiEventFilter
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(ValueFromPipeline = $True)]
            [string[]]$ComputerName = 'localhost',
        
        [Parameter(Mandatory = $True, ParameterSetName = "Name", Position = 0)]
            [string]$Name
    )

    PROCESS
    {
        if($PSCmdlet.ParameterSetName -eq 'Name')
        {
            $jobs = Get-WmiObject -ComputerName $ComputerName -Namespace root\subscription -Class __EventFilter -AsJob -Filter "Name=`'$($Name)`'"
        }
        else
        {
            $jobs = Get-WmiObject -ComputerName $ComputerName -Namespace root\subscription -Class __EventFilter -AsJob
        }

        $objects = Receive-Job -Job $jobs -Wait -AutoRemoveJob
        
        foreach($obj in $objects)
        {
            $props = @{
                'ComputerName' = $obj.__SERVER;
                'Path' = $obj.Path;
                'EventNamespace' = $obj.EventNamespace;
                'Name' = $obj.Name;
                'Query' = $obj.Query;
                'QueryLanguage' = $obj.QueryLanguage;
            }

            $obj = New-Object -TypeName PSObject -Property $props
            $obj.PSObject.TypeNames.Insert(0, 'WMIEventing.Filter')
            Write-Output $obj
        }
    }
}