Import-Module -Force $PSScriptRoot\..\WMIEventing.psd1

Describe 'WMIEventing' {    
    
    Context 'Strict mode' { 
        
        It 'Should add a local Event Filter' {
            { Add-WmiEventFilter -Name test -Query 'SELECT * FROM Win32_ProcessStartTrace' } | Should Not Throw
        }

        It 'Should work locally' {
            Get-WmiEventFilter | Should Not Be $Null
        }

        It 'Should work locally by name' {
            Get-WmiEventFilter -Name test | Should Not Be $Null
        }

        It 'Should remove the Filter' {
            Remove-WmiEventFilter
            Get-WmiEventFilter | Should Be $Null
        }
    }
}