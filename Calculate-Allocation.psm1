# Usage
# Import-Module Calculate-Allocation.psm1

. $PSScriptRoot\Convert-JsonHelpers.ps1
# These helper functions stay scoped to this module alone. The shell or caller never see them unless they import them directly.

function _CalculateAllocation{
    # This is a recursive function that walks a tree and sums up the node weights according to a lookup dictionary or type:values
    # Specifically, this function sums up the rate allocations for a given manager in a department

    param(
        [string]$id,
        [ref]$total,
        [ref]$rates,
        [ref]$people
    )
    # Passing id by value because it will change each time
    # Passing total by reference so it can tally sums independent of the execution stack.
        # Powershell "functions" are leaky
    # Passing rates and people by reference because they are static lookups

    # $rates is a simple dictionary
        # Could easily change the lookup mechanism from a dot to brackets. By using a Powershell hashtable. Unsure if there are advantages.

    # $people is a tree structured dictionary, but not a dictionary tree. Or more like a hash tree but without the hash.
        # You can only do breadth-first search on this tree because the links only go one way.

    if( $people.value.$id -eq $null ) {
            # This would be a good place for an error...
    }
    elseif( $people.value.$id.type -eq "Manager" ) {
        $total.value += $rates.value.($people.value.$id.type)
        # Add the managers rate

        foreach( $directId in $people.value.$id.directs ) {
        # If this is a "Manager" we need to iterate over her direct reports

            _CalculateAllocation $directId $total $rates $people
            # No need to pass-by-reference here as they are already references
            # This would be a good place for some Powershell automatic variable magic
                # Without that, we rely on the magic string of the function name
        }
    }
    else {
        $total.value += $rates.value.($people.value.$id.type)
        # Finally, for non-managers, we add them as well.
        # This would be an opportunity for error logging, if a non-manager had direct reports
    }
}


function New-Department{
    # Usage
    # $d = New-Department -rates <path to rates json file or string> -people <path to people json file or string>
    # $d.CalculateManagerAllocation("<name of a manager>")
    # $d.CalculateDepartmentAllocation

    # Faux constructor
    param(
        [parameter(Mandatory = $true)]
        [alias("ratesJsonString","ratesJsonFile")]
        [string]$rates,

        [parameter(Mandatory=$true)]
        [alias("peopleJsonString","peopleJsonFile")]
        [string]$people

    )


    if( Test-Path $rates ){ $theseRates = Convert-JsonFile $rates
    } else { $theseRates = Convert-JsonString $rates }

    if( Test-Path $people ){ $thesePeople = Convert-JsonFile $people
    } else { $thesePeople = Convert-JsonString $people }

    $newDepartment = New-Object PSObject
    Add-Member -InputObject $newDepartment -type NoteProperty -Name "rates" -Value $theseRates
    Add-Member -InputObject $newDepartment -type NoteProperty -Name "people" -Value $thesePeople

    Add-Member -InputObject $newDepartment -type ScriptMethod -Name "CalculateDepartmentAllocation" -Value {
        [int]$total=0

        Foreach($person in $this.people.GetEnumerator()){
            $total += $this.rates.($person.value.type)
        }

        return $total
    }

    Add-Member -InputObject $newDepartment -type ScriptMethod -Name "CalculateManagerAllocation" -Value {
        param(
            [string]$ManagerId
        )

        [int]$total = 0

        _CalculateAllocation $ManagerId ([ref]$total) ([ref]$this.rates) ([ref]$this.people)
        # This triggers the recursive calculation. The result is stored in $total

        return $total
    }

    return $newDepartment
}

Export-ModuleMember -Function New-Department
