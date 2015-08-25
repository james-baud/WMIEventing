﻿function Remove-WmiEventConsumer
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $False)]
            [string[]]$ComputerName = 'localhost',
        [Parameter(Mandatory = $True, ParameterSetName = 'Name', Position = 0)]
            [string]$Name,
        [Parameter(Mandatory = $True, ParameterSetName = "InputObject", ValueFromPipeline = $True)]
            $InputObject
    )

    PROCESS
    {
        if($PSCmdlet.ParameterSetName -eq "InputObject")
        {
            ([WMI]$InputObject.Path).Delete()
        }
        else
        {
            foreach($computer in $ComputerName)
            {
                if($PSCmdlet.ParameterSetName -eq 'Name')
                {
                    $objects = Get-WmiObject -ComputerName $computer -Namespace 'root\subscription' -Class __EventConsumer | Where-Object {$_.Name -eq $Name}
                    #if($objects = $null)
                    #{
                    #    $Exception = New-Object System.Exception("Get-WmiEventConsumer : Cannot find a consumer with the name `"$Name`". Verify the consumer name and call the cmdlet again.")
                    #    throw
                    #}
                }
                else
                {
                    $objects = Get-WmiObject -ComputerName $computer -Namespace 'root\subscription' -Class __EventConsumer
                }
            }
        }
        foreach($obj in $objects)
        {
            $obj | Remove-WmiObject
        }
    }
}