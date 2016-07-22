function Convert-JsonString{
    # This is a wrapper function for converting json into a serialized object.

    param(
        [string]$jsonString
    )

    try {
        $result = ConvertFrom-BigJson $jsonString -AutoExpandMaxJsonLength

    }
    catch [System.ArgumentException],[Microsoft.PowerShell.Commands.ConvertFromJsonCommand] {
        # Two common errors which have the same error type, need to be dealt with by message.
        # It is better to catch these errors than put them out to the console
        # because powershell also returns the ENTIRE json payload with the error :/

        if( $_.Exception.Message.Contains("Invalid object passed in") ) {
            Write-Error "Json is invalid`n"
            # Making obnoxious errors more manageable

        } elseif ( $_.Exception.Message.Contains("The length of the string exceeds the value set on the maxJsonLength property.") ) {
            Write-Error "Json is too large. Consider rerunning with the -AutoExpandMaxJsonLength option.`n"

        } else {
            Write-Error "Some unexpected error occurred`n"
            Write-Error $_
            # Anything else under this error type
        }
    } catch {
        Write-Error "Some unexpected error occurred`n"
        Write-Error $_
        # Any other error types
    }
    # One big ugly block of error handling

    return $result
}

function ConvertFrom-BigJson{
    # This is overly simplified reimplementation of the standard ConvertFrom-Json to allow for large objects

    param(
        [string]$jsonString,
        [switch]$AutoExpandMaxJsonLength
    )

    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
    $bigJsonSerializer = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
    # Load the Assembly and instantiate a new serializer
    # For these purposes, we only do this at New-Department instantiation.
        # If this function was going execute more often, it would be more performant for it to be an object member for repeated use.

    if($AutoExpandMaxJsonLength.isPresent){
        $bigJsonSerializer.MaxJsonLength  = $jsonString.length + 1024
    }
    # The default value for MaxJsonLength is very low. Effectively limiting your tree nodes under 10k count.
        # -AutoExpandMaxJsonLength automatically increases this max to fit whatever object we want, with a comfy 1024 bytes of wiggle room.

    $result = $bigJsonSerializer.DeserializeObject($jsonString)

    return $result
}

function Convert-JsonFile{
    param(
        [string]$path
    )

    try{
        $jsonString = Get-Content -Raw $path
        $result = ConvertFrom-BigJson $jsonString -AutoExpandMaxJsonLength
    } catch [PathNotFound],[Microsoft.PowerShell.Commands.GetContentCommand] {
        Write-Error $_
        return $null
    }
    catch [ArgumentException] {
        Write-Error "$path is valid, but the contents do not appear to be valid json"
        return $null
    }
        return $result
}
