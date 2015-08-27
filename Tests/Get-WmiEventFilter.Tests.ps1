Import-Module -Force $PSScriptRoot\..\WMIEventing.psd1

Remove-WmiEventFilter
Remove-WmiEventConsumer
Remove-WmiEventSubscription

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

Describe '__EventFilters' {    
    
    Context 'Strict mode' { 
        
        It 'Should add a local __EventFilters' {
            { Add-WmiEventFilter -Name filter0 -Query 'SELECT * FROM Win32_ProcessStartTrace' } | Should Not Throw
        }

        It 'Should get all local __EventFilters' {
            Add-WmiEventFilter -Name filter1 -Query 'SELECT * FROM Win32_ProcessStartTrace'
            Add-WmiEventFilter -Name filter2 -Query 'SELECT * FROM Win32_ProcessStartTrace'
            Add-WmiEventFilter -Name filter3 -Query 'SELECT * FROM Win32_ProcessStartTrace'
            Add-WmiEventFilter -Name filter4 -Query 'SELECT * FROM Win32_ProcessStartTrace'
            $filters = Get-WmiEventFilter 
            $filters.Length | Should Be 5
        }

        It 'Should get a local __EventFilter by name' {
            $filter = Get-WmiEventFilter -Name filter0
            $filter.Name | Should Be 'filter0'
        }

        It 'Should remove a local __EventFilter by name' {
            Remove-WmiEventFilter -Name filter0
            Get-WmiEventFilter -Name filter0 | Should Be $Null
        }

        It 'Should remove a local __EventFilter through the pipeline' {
            Get-WmiEventFilter -Name filter1 | Remove-WmiEventFilter
            Get-WmiEventFilter -Name filter1 | Should Be $Null
        }

        It 'Should remove all local __EventFilters' {
            Remove-WmiEventFilter
            Get-WmiEventFilter | Should Be $Null
        }
    }
}

Describe '__EventConsumers' {
    
    Context 'Strict mode' {

        It 'Should add a local ActiveScriptEventConsumer' {
            { Add-WmiEventConsumer -Name AS_consumer -ScriptingEngine VBScript -ScriptText $script } | Should Not Throw
        }

        #It 'Should add a local CommandLineEventConsumer' {
        #    { Add-WmiEventConsumer -Name CL_consumer -Query 'SELECT * FROM Win32_ProcessStartTrace' } | Should Not Throw
        #}

        It 'Should add a local LogFileEventConsumer' {
            { Add-WmiEventConsumer -Name LF_consumer -Filename C:\Windows\Temp\test.txt -Text "%TargetInstance%" } | Should Not Throw
        }

        #It 'Should add a local NtEventLogEventConsumer' {
        #    { Add-WmiEventConsumer -Name EL_consumer -Query 'SELECT * FROM Win32_ProcessStartTrace' } | Should Not Throw
        #}

        #It 'Should add a local SMTPEventConsumer' {
        #    { Add-WmiEventConsumer -Name SMTP_consumer -Query 'SELECT * FROM Win32_ProcessStartTrace' } | Should Not Throw
        #}

        It 'Should get all local __EventConsumers' {
            Add-WmiEventConsumer -Name AS_consumer1 -ScriptingEngine VBScript -ScriptText $script
            Add-WmiEventConsumer -Name AS_consumer2 -ScriptingEngine VBScript -ScriptText $script
            Add-WmiEventConsumer -Name AS_consumer3 -ScriptingEngine VBScript -ScriptText $script
            $consumers = Get-WmiEventConsumer
            $consumers.Length | Should Be 5
        }

        It 'Should get a local __EventConsumer by Name' {
            $consumer = Get-WmiEventConsumer -Name AS_consumer
            $consumer.Name | Should Be 'AS_consumer'
        }

        It 'Should remove a local __EventConsumer by name' {
            Remove-WmiEventConsumer -Name AS_consumer
            Get-WmiEventConsumer -Name AS_consumer | Should Be $Null
        }

        It 'Should remove a local __EventConsumer through the pipeline' {
            Get-WmiEventConsumer -Name LF_consumer | Remove-WmiEventFilter
            Get-WmiEventConsumer -Name LF_consumer | Should Be $Null
        }

        It 'Should remove all local __EventConsumers' {
            Remove-WmiEventConsumer
            Get-WmiEventConsumer | Should Be $Null
        }

    }
}

Describe '__FilterToConsumerBinding' {
    
    Context 'Strict mode' {
        
        Add-WmiEventFilter -Name filter0 -Query 'SELECT * FROM Win32_ProcessStartTrace'
        Add-WmiEventFilter -Name filter1 -Query 'SELECT * FROM Win32_ProcessStartTrace'
        Add-WmiEventFilter -Name filter2 -Query 'SELECT * FROM Win32_ProcessStartTrace'
        Add-WmiEventFilter -Name filter3 -Query 'SELECT * FROM Win32_ProcessStartTrace'
        Add-WmiEventFilter -Name filter4 -Query 'SELECT * FROM Win32_ProcessStartTrace'
        Add-WmiEventConsumer -Name AS_consumer -ScriptingEngine VBScript -ScriptText $script

        It 'Should add a local __FilterToConsumerBinding' {
            { Add-WmiEventSubscription -FilterName filter0 -ConsumerName AS_consumer -ConsumerType ActiveScriptEventConsumer } | Should Not Throw
        }

        It 'Should get all local __FilterToConsumerBindings' {
            Add-WmiEventSubscription -FilterName filter1 -ConsumerName AS_consumer -ConsumerType ActiveScriptEventConsumer
            Add-WmiEventSubscription -FilterName filter2 -ConsumerName AS_consumer -ConsumerType ActiveScriptEventConsumer
            Add-WmiEventSubscription -FilterName filter3 -ConsumerName AS_consumer -ConsumerType ActiveScriptEventConsumer
            Add-WmiEventSubscription -FilterName filter4 -ConsumerName AS_consumer -ConsumerType ActiveScriptEventConsumer
            $subscriptions = Get-WmiEventSubscription 
            $subscriptions.Length | Should Be 5
        }

        It 'Should get a local __FilterToConsumerBinding by name' {
            $subscription = Get-WmiEventSubscription -Name filter0
            $subscription.FilterName | Should Be 'filter0'
        }

        It 'Should remove a local __FilterToConsumerBinding by name' {
            Remove-WmiEventSubscription -Name filter0
            Get-WmiEventSubscription -Name filter0 | Should Be $Null
        }

        It 'Should remove a local __FilterToConsumerBinding through the pipeline' {
            Get-WmiEventSubscription -Name filter1 | Remove-WmiEventSubscription
            Get-WmiEventSubscription -Name filter1 | Should Be $Null
        }

        It 'Should remove all local __FilterToConsumerBindings' {
            Remove-WmiEventSubscription
            Get-WmiEventSubscription | Should Be $Null
        }
    }
}