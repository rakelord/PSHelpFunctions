# PSHelpFunctions
Functions to make things easier to remember, conversions and other helpful stuff!

# Installation
```powershell
Install-Module -Name PSHelpFunctions
```

# Available functions
## Remove-BadStringCharacters
Removes bad character so it is easier to use within script, for example I am swedish and we have äöå alot in our language, this converts äöå to aoa instead.
## Get-ValueWithinString
Find a value within a larger string, for example if you want to retrieve a a code within a large string set (Regex helpfunction)
## Convert-UTF8ToString
There are some cases when PowerShell will give you wierd UTF8 Data when retrieving API requests and Content-Type charset=utf8 is not working.<br>
This solves that problem, mostly used if you have some sort of non-english language.
## Get-ValidDate
Sometimes you retrieve wierd dates, this uses the powershell date conversion to convert the date to a valid datetime object and returns it.<br>
It does ignore the date if it is not parsable.

