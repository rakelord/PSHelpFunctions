function Remove-BadStringCharacters {
    <#
    .SYNOPSIS
    Remove bad string characters
    
    .DESCRIPTION
    Removes bad character so it is easier to use within script, for example I am swedish and we have äöå alot in our language, this converts äöå to aoa instead.
    
    .PARAMETER String
    The string to convert
    
    .EXAMPLE
    Remove-BadStringCharacters("Hej är du hemma eller åker du bil?")

    OUTPUT
    Hej ar du hemma eller aker du bil?

    #>
    param(
        [parameter(mandatory)]
        [string]$String
    )
    [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($String))
}

function Get-ValueWithinString {
    <#
    .SYNOPSIS
    Find a value within a large string.
    
    .DESCRIPTION
    Find a value within a larger string, for example if you want to retrieve a a code within a large string set (Regex helpfunction)
    
    .PARAMETER InputString
    The string you want to look for data in.
    
    .PARAMETER Begin
    The text to begin with
    
    .PARAMETER End
    The text to End with, everything inbetween Begin and End
    
    .EXAMPLE
    $String = "Every email is sent with this text, here is a code: 23498 please use this"

    #This will get everything inbetween "code: " AND " please"
    Get-ValueWithinString -InputString $String -Begin "code: " -End " please"

    OUTPUT
    23498
    #>
    param(
        [parameter(mandatory)]
        $InputString,
        [parameter(mandatory)]
        $Begin,
        [parameter(mandatory)]
        $End
    )
    return ([regex]::match("$($InputString)","$($Begin)(.*?)$End").Groups[1].Value).Trim()
}

Function Convert-UTF8ToString {
    <#
    .SYNOPSIS
    If your text returns some wierd UTF8 values
    
    .DESCRIPTION
    There are some cases when PowerShell will give you wierd UTF8 Data when retrieving API requests and Content-Type charset=utf8 is not working.
    This solves that problem, mostly used if you have some sort of non-english language.
    
    .PARAMETER Text
    The text to convert
    
    .EXAMPLE
    $String = "PowerlÃ¤nk AB"
    FixUTF($String)
    
    OUTPUT
    Powerlänk AB
    
    .NOTES
    General notes
    #>
    param(
        [STRING]$Text
    )
    if ($Text -eq ""){ return $null }
    $bytes = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetBytes($text)
    return [System.Text.Encoding]::UTF8.GetString($bytes)
}

Function Get-ValidDate {
    <#
    .SYNOPSIS
    Get a valid date and do not throw an error if it cannot be converted.
    
    .DESCRIPTION
    Sometimes you retrieve wierd dates, this uses the powershell date conversion to convert the date to a valid datetime object and returns it.
    It does ignore the date if it is not parsable.
    
    .PARAMETER InputDate
    The date string you want to convert
    
    .EXAMPLE
    $Date = "2023-01-22"
    Get-ValidDate($Date)

    OUTPUT
    2023-01-22T00:00:00

    #>
    Param(
        [parameter(mandatory)]
        $InputDate
    )
    try {
        return ([DATETIME]$InputDate).ToString("yyy-MM-ddTHH:mm:ss")
    } catch { 
        return ""
    }
}