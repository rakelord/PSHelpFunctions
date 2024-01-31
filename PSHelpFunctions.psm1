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
    Convert-UTF8ToString($String)
    
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
    2023-01-22T00:00:00.000

    #>
    Param(
        $InputDate
    )
    try {
        return ([DATETIME]$InputDate).ToString("yyy-MM-ddTHH:mm:ss.fff")
    } catch { 
        return ""
    }
}

function Remove-SpecialCharacters {
    <#
    .SYNOPSIS
    Removes special characters
    
    .DESCRIPTION
    Removes all special characters, like . - #¤%"#¤&/, basically anything that is not a character or a number
    
    .PARAMETER InputString
    The input string
    
    .EXAMPLE
    $String = "asidfar----srtjrstjrstjt....j"
    Remove-SpecialCharacters($String)
    
    OUTPUT
    asidfarsrtjrstjrstjtj

    #>
    param(
        $InputString
    )
    return [regex]::Replace($InputString, "[^a-zA-Z0-9\s]", "")
}

function IsNotNULL {
    param(
        $InputString
    )
    return ![STRING]::IsNullOrEmpty($InputString)
}
function IsNULL {
    param(
        $InputString
    )
    return [STRING]::IsNullOrEmpty($InputString)
}

Function Invoke-MultiThreads {
    <#
    .SYNOPSIS
    Run multithreading (processes) on larger powershell objects
    
    .DESCRIPTION
    Run multithreading (processes) on larger powershell objects
    
    .PARAMETER RunObjects
    The object to loop through
    
    .PARAMETER ScriptBlock
    This ScriptBlock to use multithreading on
    $args[0] = The RunObject
    $args[1] = API authentication, if you need to supply header to Invoke-RestMethod

    .PARAMETER APIAuthentication
    If you have a Header you want to use within the request, is refered to $args[1] in ScriptBlock
    
    .EXAMPLE
    $TestObject = Invoke-MultiThreads -RunObjects $LargerArray -APIAuthentication $APIHeader -ScriptBlock {
        $OutputObject = @()
        foreach ($RunObject in $args[0]){
            $OutputObject += @{
                parameter1 = data1
                parameter2 = data2
                parameter3 = data3
                parameter4 = Invoke-RestMethod -Uri "https://bla.se/api/endpoint" -Headers $args[1] -Method GET -ContentType "application/json"
            }
        }
        $OutputObject
    }
    #>
    param(
        [parameter(mandatory)]
        $RunObjects,
        [parameter(mandatory)]
        $ScriptBlock,
        $APIAuthentication
    )
    $HowManyJobs = [math]::Round(($RunObjects.Count / 200) + 0.5)
    $WorkerName = "PSMultiThreadingWorker"

    for($i = 0;$i -lt $HowManyJobs;$i++){
        $ObjectStart = ($i*200)
        $RunObjectsFraction = $RunObjects[$ObjectStart..($ObjectStart+200-1)]

        Start-Job -Name $WorkerName -ArgumentList $RunObjectsFraction,$APIAuthentication -ScriptBlock $ScriptBlock | Out-Null
    }

    Write-Host "Started jobs: $WorkerName"

    do {
        Write-Host "Waiting $WorkerName to finish..."
        Start-Sleep -Seconds 3
        $NotCompletedJobs = (Get-Job -Name $WorkerName | Where-Object {$_.State -ne 'Completed'})
    } while($NotCompletedJobs.Count -ne 0)

    $OutputData = Get-Job -Name $WorkerName | Receive-Job
    Remove-Job -Name $WorkerName
    Return $OutputData
}