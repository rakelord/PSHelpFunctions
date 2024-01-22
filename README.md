# PSHelpFunctions
Functions to make things easier to remember, conversions and other helpful stuff!

# Installation
```powershell
Install-Module -Name PSHelpFunctions
```

# Available functions
## Remove-BadStringCharacters
Removes bad character so it is easier to use within script, for example I am swedish and we have äöå alot in our language, this converts äöå to aoa instead.
```powershell
Remove-BadStringCharacters("Hej är du hemma eller åker du bil?")

# OUTPUT
"Hej ar du hemma eller aker du bil?"
```

## Get-ValueWithinString
Find a value within a larger string, for example if you want to retrieve a a code within a large string set (Regex helpfunction)
```powershell
$String = "Every email is sent with this text, here is a code: 23498 please use this"
Get-ValueWithinString -InputString $String -Begin "code: " -End " please"

# OUTPUT
"23498"
```

## Convert-UTF8ToString
There are some cases when PowerShell will give you wierd UTF8 Data when retrieving API requests and Content-Type charset=utf8 is not working.<br>
This solves that problem, mostly used if you have some sort of non-english language.
```powershell
$String = "PowerlÃ¤nk AB"
Convert-UTF8ToString($String)

# OUTPUT
"Powerlänk AB"
```

## Get-ValidDate
Sometimes you retrieve wierd dates, this uses the powershell date conversion to convert the date to a valid datetime object and returns it.<br>
It does ignore the date if it is not parsable.
```powershell
$Date = "2023-01-22"
Get-ValidDate($Date)

# OUTPUT
"2023-01-22T00:00:00"
```

## Remove-SpecialCharacters
Removes all special characters, like . - #¤%"#¤&/, basically anything that is not a character or a number
```powershell
$String = "asidfar----srtjrstjrstjt....j"
Remove-SpecialCharacters($String)

# OUTPUT
"asidfarsrtjrstjrstjtj"
```