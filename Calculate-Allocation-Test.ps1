$originalLocaton = Get-Location
Set-Location $PSScriptRoot
Import-Module -Name ".\Calculate-Allocation.psm1" -Force
# The module is made available to the other test scripts run in this scope

# Run some basic functional tests on CalculateManagerAllocation
&".\tests\Test-CalculateManagerAllocation.ps1" -testsPath ".\tests\tests_CalculateManagerAllocation.json"

# Run some basic functional tests on CalculateDepartmentAllocation
&".\tests\Test-CalculateDepartmentAllocation.ps1" -testsPath ".\tests\tests_CalculateDepartmentAllocation.json"

# Run some constructor tests
&".\tests\Test-NewDepartment.ps1" -testsPath ".\tests\tests_NewDepartment.json"

# Run some unit tests on json conversion
&".\tests\Test-ConvertJsonHelpers.ps1" -testsPath ".\tests\tests_ConvertJsonHelpers.json"

# Run some tests on some big trees. these are all manager types
# These tests can take a while
if($(Read-Host "`nThe following tests may take 5 to 10 mins. `n`
    Are you sure you want to proceed? (y/n)") -eq "y"){
        Write-Host "NOTE: If you feel your shell has hung, just jog it with a character return.`n`
        If you don't see any more output, just wait a few more minutes." -BackgroundColor Yellow -ForegroundColor Black

        &".\tests\Test-CalculateManagerAllocation.ps1" -testsPath ".\tests\tests_BigTrees.json"
    } else {
        Write-Host "[SKIPPED] .\tests\tests_BigTrees.json" -BackgroundColor Green -ForegroundColor Black
    }


Write-Host "`n----------------`nTesting Complete`n----------------`n" -BackgroundColor White -ForegroundColor Black

# Clean up after
Remove-Module -Name "Calculate-Allocation"
Set-Location $originalLocaton
