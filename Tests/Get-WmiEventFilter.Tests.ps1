Import-Module -Force Uproot

Describe 'Get-WmiEventFilter' {    
    
    Context 'Strict mode' { 
        #Set-StrictMode -Version latest
        
        It 'Should work locally' {
            Get-WmiEventFilter | Should Not Be $Null
        }
    }
}