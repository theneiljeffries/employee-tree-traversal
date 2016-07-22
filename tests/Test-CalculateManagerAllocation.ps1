param
    (
        [string]$testsPath
    )

$tests = ConvertFrom-Json $(Get-Content -Raw -Path $testsPath)
$tests = $tests.tests

$originalLocaton = Get-Location
Set-Location $PSScriptRoot

Write-Host "`n`n[RUNNING] CalculateManagerAllocation for $testsPath" -ForegroundColor Black -BackgroundColor White

foreach($test in $tests){

    $now = date
    Write-Host "`n[RUNNING] $($test.name) tests ($now)" -ForegroundColor Yellow

    $dept = New-Department -rates $test.rates -people $test.people

    $times = Measure-Command { $result = $dept.CalculateManagerAllocation($test.managerid) }

    $pass = $result -eq $test.expected

    if ($pass){
        Write-Host "[PASSED]  $($test.name)" -BackgroundColor Green -ForegroundColor Black
    } else {
        Write-Host "[FAILED]  $($test.name) " -BackgroundColor Red -ForegroundColor White
    }

    Write-Host "Expected $($test.expected) -- Got $result"
    Write-Host "Node count: $($dept.people.count) ($([int]($dept.people.count/$times.TotalSeconds)) Nodes/Second *[assuming a single root/manager]) "
    Write-Host "Calculation Time: $($times.Hours):$($times.Minutes):$($times.Seconds):$($times.Milliseconds)"

    $dept = $null
    $result = $null
    $pass = $null
    $test = $null


}

Set-Location $originalLocaton
