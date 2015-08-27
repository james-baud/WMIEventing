#WMIEventing [![Build status](https://ci.appveyor.com/api/projects/status/d40ntb7284up5f98?svg=true)](https://ci.appveyor.com/project/Invoke-IR/wmieventing)

Developed by [@jaredcatkinson](https://twitter.com/jaredcatkinson), [@harmj0y](https://twitter.com/harmj0y), [@sixdub](https://twitter.com/sixdub)

## Overview
An Event Filter is a WMI Query Language (WQL) query that specifies the type of object to look for (for more details on WQL please check out Ravikanth Chaganti's free ebook at http://www.ravichaganti.com/blog/ebook-wmi-query-language-via-powershell/). Event Consumers are the action component of the Event Subscription. Event Consumers tell the subscription what to do with an object that makes it past the filter. There are five default event consumers in Windows: ActionScriptEventConsumer (runs arbitrary vbscript or jscript code), CommandLineEventConsumer (executes an arbitrary command), LogFileEventConsumer (writes to a specified flat log file), NtEventLogEventConsumer (creates a new event log), and SMTPEventConsumer (sends an email). Lastly, the Filter to Consumer Binding pairs a Filter with a Consumer.

## Cmdlets
### Event Filter (__EventFilter):
```
Add-WmiEventFilter - Adds a WMI Event Filter to a local or remote computer.
Get-WmiEventFilter - Gets the WMI Event Filters that are "installed" on the local or a remote computer.
Remove-WmiEventFilter - Removes a WMI Event Filter to a local or remote computer.
```

### Event Consumers (__EventConsumer):
```
Add-WmiEventConsumer - Adds a WMI Event Consumer to a local or remote computer.
Get-WmiEventConsumer - Gets the WMI Event Consumers that are "installed" on the local computer or a remote computer.
Remove-WmiEventConsumer - Removes a WMI Event Consumer to a local or remote computer.
```

### Event Subscription (__FilterToConsumerBinding):
```
Add-WmiEventSubscription - Adds a WMI Event Subscription to a local or remote computer.
Get-WmiEventSubscription - Gets the WMI Event Subscriptions that are "installed" on the local computer or a remote computer.
Remove-WmiEventSubscription - Removes a WMI Event Subscriptions to a local or remote computer.
```

## Signatures
(Write something about Intrinsic vs. Extrinsic)
BOTTOM LINE: Whenever possible, use Extrinsic events instead of Intrinsic events. Intrinsic events require polling, which is more resource intensive (although I haven't come across any major issues yet) than Extrinsic events.

## Examples
### Install Module (PSv3)
```powershell
function Get-UserModulePath {
 
    $Path = $env:PSModulePath -split ";" -match $env:USERNAME
 
    if (-not (Test-Path -Path $Path))
    {
        New-Item -Path $Path -ItemType Container | Out-Null
    }
        $Path
}
 
Invoke-Item (Get-UserModulePath)
```

```powershell
Browse to download.uproot.invoke-ir.com
Decompress downloaded zip file
Rename folder to Uproot
Move folder PowerShell Module directory (Get-ChildItem Env:\PSModulePath | Select-Object -ExpandProperty Value)
Run PowerShell as Admin
Set-ExecutionPolicy Unrestricted
Unblock-File \path\to\module\Uproot\*
Unblock-File \path\to\module\Uproot\en-US\*
Import-Module Uproot
```
