param
    (
        [string]$testsPath,
        [string]$scriptPath
    )

$tests = ConvertFrom-Json $(Get-Content -Raw -Path $testsPath)
$tests = $tests.tests

$originalLocaton = Get-Location
Set-Location $PSScriptRoot

. "..\Convert-JsonHelpers.ps1"

Write-Host "`n[RUNNING] $testsPath" -ForegroundColor Black -BackgroundColor White

foreach($test in $tests){

    $now = date
    Write-Host "`n[RUNNING] $($test.name) tests ($now)" -ForegroundColor Yellow

    $resultFromFile = Convert-JsonFile $test.people 
    $resultFromString = Convert-JsonString $(Get-Content -Raw -Path $test.people)

    $pass = $($resultFromFile.Count -eq $resultFromString.Count)

    if ($pass){
        Write-Host "[PASSED]  $($test.name)" -BackgroundColor Green -ForegroundColor Black
    } else {
        Write-Host "[FAILED]  $($test.name) " -BackgroundColor Red -ForegroundColor White
    }

    Write-Host "Expected Convert-JsonFile and Convert-JsonString conversion to be equal -- Got $pass"

    $resultFromFile = $null
    $resultFromString = $null
    $pass = $null

}

Set-Location $originalLocaton
