#WMIEventing [![Build status](https://ci.appveyor.com/api/projects/status/d40ntb7284up5f98?svg=true)](https://ci.appveyor.com/project/Invoke-IR/wmieventing)

Developed by [@jaredcatkinson](https://twitter.com/jaredcatkinson), [@harmj0y](https://twitter.com/harmj0y), [@sixdub](https://twitter.com/sixdub)

## Overview
An Event Filter ([__EventFilter](https://msdn.microsoft.com/en-us/library/aa394639(v=vs.85).aspx)) is a WMI Query Language (WQL) query that specifies the type of object to look for (for more details on WQL please check out [Ravikanth Chaganti's free ebook](http://www.ravichaganti.com/blog/ebook-wmi-query-language-via-powershell/)). Event Consumers ([__EventConsumer](https://msdn.microsoft.com/en-us/library/aa394635(v=vs.85).aspx)) are the action component of the Event Subscription. Event Consumers tell the subscription what to do with an object that makes it past the filter. There are five default event consumers in Windows: [ActionScriptEventConsumer](https://msdn.microsoft.com/en-us/library/aa384749(v=vs.85).aspx) (runs arbitrary vbscript or jscript code), [CommandLineEventConsumer](https://msdn.microsoft.com/en-us/library/aa389231(v=vs.85).aspx) (executes an arbitrary command), [LogFileEventConsumer](https://msdn.microsoft.com/en-us/library/aa392277(v=vs.85).aspx) (writes to a specified flat log file), [NtEventLogEventConsumer](https://msdn.microsoft.com/en-us/library/aa392715(v=vs.85).aspx) (creates a new event log), and [SMTPEventConsumer](https://msdn.microsoft.com/en-us/library/aa393629(v=vs.85).aspx) (sends an email). Lastly, the Binding ([__FilterToConsumerBinding](https://msdn.microsoft.com/en-us/library/aa394647(v=vs.85).aspx)) pairs a Filter with a Consumer.

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

## [Module Installation](https://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx)
Jakub Jareš wrote an [excellent introduction](http://www.powershellmagazine.com/2014/03/12/get-started-with-pester-powershell-unit-testing-framework/) to module installation, so I decided to adapt his example for WMIEventing. 

To begin open an internet browser and navigate to the main WMIEventing github [page](https://github.com/Invoke-IR/WMIEventing). Once on this page you will need to download and extract the module into your modules directory.

![alt text](http://4.bp.blogspot.com/--awwh6xvH_A/Vd_C3tQpitI/AAAAAAAAA3Y/lCPGXa8mk08/s640/Screenshot%2B2015-08-27%2B21.52.40.png)

If you used Internet Explorer to download the archive, you need to unblock the archive before extraction, otherwise PowerShell will complain when you import the module. If you are using PowerShell 3.0 or newer you can use the Unblock-File cmdlet to do that:
```powershell
Unblock-File -Path "$env:UserProfile\Downloads\WMIEventing-master.zip"
```

If you are using an older version of PowerShell you will have to unblock the file manually. Go to your Downloads folder and right-click WMIEventing-master.zip and select "Properties". On the general tab click Unblock and then click OK to close the dialog.

![alt text](http://2.bp.blogspot.com/-4QzeiRBwHfI/Vd_C3l1dIXI/AAAAAAAAA3U/rvverb1qbpM/s640/Screenshot%2B2015-08-27%2B21.57.21.png)

Open your Modules directory and create a new folder called WMIEventing. You can use this script to open the correct folder effortlessly:
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

Extract the archive to the WMIEventing folder. When you are done you should have all these files in your WMIEventing directory:

![alt text](http://4.bp.blogspot.com/-NfSl2E5G7CM/Vd_Ei6Q_r6I/AAAAAAAAA3o/Ats2BlDSzmk/s640/Screenshot%2B2015-08-27%2B22.16.28.png)

Start a new PowerShell session and import the WMIEventing module using the commands below:
```powershell
Get-Module -ListAvailable -Name WMIEventing
Import-Module WMIEventing
Get-Command -Module WMIEventing
```

You are now ready to use the WMIEventing PowerShell module!

## Examples
### Add-WmiEventFilter
```powershell
Add-WmiEventFilter -Name ProcessStartTrace -Query "SELECT * FROM Win32_ProcessStartTrace"
```

### Add-WmiEventConsumer (ActiveScriptEventConsumer)
```powershell
$script = @"
Set objSysInfo = CreateObject("WinNTSystemInfo")
Set objHTTP = CreateObject("Microsoft.XMLHTTP")

objHTTP.open "POST", "http://$($ListeningPostIP)/", False
objHTTP.setRequestHeader "User-Agent", "UprootIDS"


Dim ipString

Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\localhost\root\cimv2")
Set IPConfigSet = objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration Where IPEnabled=TRUE")

For Each IPConfig in IPConfigSet
    If Not IsNull(IPConfig.IPAddress) Then 
         ipString = IPConfig.IPAddress(0)
    End If
Next


Dim outputString

outputString = outputString & "{""TargetEvent"":{"
outputString = outputString & """TimeCreated"":""" & TargetEvent.Time_Created & ""","
outputString = outputString & """SourceIP"":""" & ipString & ""","
outputString = outputString & """Server"":""" & objSysInfo.ComputerName & ""","

If ((TargetEvent.Path_.Class = "__NamespaceOperationEvent") Or (TargetEvent.Path_.Class = "__NamespaceModificationEvent") Or (TargetEvent.Path_.Class = "__NamespaceDeletionEvent") Or (TargetEvent.Path_.Class = "__NamespaceCreationEvent") Or (TargetEvent.Path_.Class = "__ClassOperationEvent") Or (TargetEvent.Path_.Class = "__ClassModificationEvent") Or (TargetEvent.Path_.Class = "__ClassCreationEvent") Or (TargetEvent.Path_.Class = "__InstanceOperationEvent") Or (TargetEvent.Path_.Class = "__InstanceCreationEvent") Or (TargetEvent.Path_.Class = "__MethodInvocationEvent") Or (TargetEvent.Path_.Class = "__InstanceModificationEvent") Or (TargetEvent.Path_.Class = "__InstanceDeletionEvent") Or (TargetEvent.Path_.Class = "__TimerEvent")) Then
    outputString = outputString & """EventType"":""" & TargetEvent.Path_.Class & ""","
    outputString = outputString & """InstanceType"":""" & TargetEvent.TargetInstance.Path_.Class & ""","
    outputString = outputString & """TargetInstance"":{"

    For Each oProp in TargetEvent.TargetInstance.Properties_
         outputString = outputString & """" & oProp.Name & """:""" & oProp & ""","
    Next
Else
    outputString = outputString & """EventType"":""ExtrinsicEvent"","
    outputString = outputString & """InstanceType"":""" & TargetEvent.Path_.Class & ""","
    outputString = outputString & """TargetInstance"":{"

    For Each oProp in TargetEvent.Properties_
         If oProp.Name <> "Sid" Then
            outputString = outputString & """" & oProp.Name & """:" & """" & oProp & ""","
        End If
    Next
End If

outputString = Left(outputString, Len(outputString) - 1)
outputString = outputString & "}"
outputString = outputString & "}}"

objHTTP.send outputString

Set objHTTP = Nothing
"@

Add-WmiEventConsumer -Name AS_GenericHTTP -ScriptingEngine VBScript -ScriptText $script
```

### Add-WmiEventSubscription
```powershell
Add-WmiEventSubscription -FilterName ProcessStartTrace -ConsumerName AS_GenericHTTP -ConsumerType ActiveScriptEventConsumer
```

### Get-WmiEventFilter
```powershell
Get-WmiEventFilter
```

```powershell
Get-WmiEventFilter -Name ProcessStartTrace
```

### Get-WmiEventConsumer
```powershell
Get-WmiEventConsumer
```

```powershell
Get-WmiEventConsumer -Name AS_GenericHTTP
```

### Get-WmiEventSubscription
```powershell
Get-WmiEventSubscripton
```

### Remove-WmiEventFilter
```powershell
Remove-WmiEventFilter
```

```powershell
Remove-WmiEventFilter -Name ProcessStartTrace
```

```powershell
Get-WmiEventFilter | Remove-WmiEventFilter
```

### Remove-WmiEventConsumer
```powershell
Remove-WmiEventConsumer
```

```powershell
Remove-WmiEventConsumer -Name AS_GenericHTTP
```

```powershell
Get-WmiEventConsumer | Remove-WmiEventConsumer
```

### Remove-WmiEventSubscription
```powershell
Remove-WmiEventSubscription
```

