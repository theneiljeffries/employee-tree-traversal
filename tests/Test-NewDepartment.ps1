param
    (
        [string]$testsPath
    )

$tests = ConvertFrom-Json $(Get-Content -Raw -Path $testsPath)


$originalLocaton = Get-Location
Set-Location $PSScriptRoot

Write-Host "`n`[RUNNING] $testsPath" -ForegroundColor Black -BackgroundColor White

foreach($test in $tests.sum_tests){

    $now = date
    Write-Host "`n[RUNNING] $($test.name) tests ($now)" -ForegroundColor Yellow

    $deptFromFiles = New-Department -rates $test.rates -people $test.people
    $deptFromStrings = New-Department -rates $(Get-Content -Raw -Path $test.rates) -people $(Get-Content -Raw -Path $test.people)

    $resultFromFiles = $deptFromFiles.CalculateManagerAllocation($test.managerid)
    $resultFromStrings = $deptFromStrings.CalculateManagerAllocation($test.managerid)

    $pass = $($resultFromFiles -eq $test.expected) -AND $($resultFromStrings -eq $test.expected)

    if ($pass){
        Write-Host "[PASSED]  $($test.name)" -BackgroundColor Green -ForegroundColor Black
    } else {
        Write-Host "[FAILED]  $($test.name)" -BackgroundColor Red -ForegroundColor White
    }

    Write-Host "Expected $($test.expected) -- Got $resultFromFiles (using a file) and $resultFromStrings (using a string)"

    #Better safe than sorry
    $deptFromFiles = $null
    $deptFromStrings = $null
    $resultFromFiles = $null
    $resultFromStrings = $null
    $pass = $null
    $test = $null

}

# this code is so WET it is water logged!

foreach($test in $tests.constuctor_tests){

    $now = date
    Write-Host "`n[RUNNING] $($test.name) tests ($now)" -ForegroundColor Yellow

    $dept = New-Department -rates $test.rates -people $test.people

    $pass = $($dept.people.count -eq $test.expected)

    if ($pass){
        Write-Host "[Passed]  $($test.name)" -BackgroundColor Green -ForegroundColor Black
    } else {
        Write-Host "[Failed]  $($test.name)" -BackgroundColor Red -ForegroundColor White
    }

    Write-Host "Expected $($test.expected) -- Got $($dept.people.count)"

    #Better safe than sorry
    $dept = $null
    $pass = $null
    $test = $null

}

Set-Location $originalLocaton
