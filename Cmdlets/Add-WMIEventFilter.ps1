function Add-WmiEventFilter
{
    [CmdletBinding(DefaultParameterSetName = "FilterFile")]
    Param(
        [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
            [string[]]$ComputerName = 'localhost',
        [Parameter(Mandatory = $True, ParameterSetName = "Name")]
            [string]$Name,
        [Parameter(Mandatory = $False, ParameterSetName = "Name")]
            [string]$EventNamespace = 'root\cimv2',
        [Parameter(Mandatory = $True, ParameterSetName = "Name")]
            [string]$Query,
        [Parameter(Mandatory = $False, ParameterSetName = "Name")]
            [string]$QueryLanguage = 'WQL'
    )

    PROCESS
    {
        foreach($computer in $ComputerName)
        {
            $class = [WMICLASS]"\\$computer\root\subscription:__EventFilter"

            $instance = $class.CreateInstance()
            $instance.Name = $Name
            $instance.EventNamespace = $EventNamespace
            $instance.Query = $Query
            $instance.QueryLanguage = $QueryLanguage
            $instance.Put()
        }
    }
}