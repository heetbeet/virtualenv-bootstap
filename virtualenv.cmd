<# :
    @echo off
    setlocal

    set "_cmd=%~f0"
    set _arg1=%1
    set _args=%*

    powershell -nologo -nop -exec bypass "iex (Get-Content '%_cmd%' -Raw)"
    goto :EOF
#>

# Retrieve the value from the environment variable
$version = $env:_arg1 -replace '"', ''
$pattern = '^3\.\d+\.\d+$'

$url = "https://www.nuget.org/api/v2/package/python"
if ($version -match $pattern) {
    $url = "https://www.nuget.org/api/v2/package/python/$version"
}

$basePath = Resolve-Path -Path "$env:_cmd\..\.." -Relative
$fileName = $url.Split("/")[-1] + ".zip"
$dirName = $fileName -replace ".zip$", ""
$tempBase = Join-Path -Path $env:TEMP -ChildPath "virtualenv-python-bases/$dirName"

$zipPath = Join-Path -Path $tempBase -ChildPath $fileName
$pydirPath = Join-Path -Path $tempBase -ChildPath "python"
New-Item -Path $pydirPath -ItemType Directory -Force  | Out-Null

$pydirPath = Resolve-Path -Path $pydirPath -Relative

# Define the paths
$pythonExePath = Join-Path -Path $pydirPath -ChildPath "tools\python.exe"
$virtualenvExePath = Join-Path -Path $pydirPath -ChildPath "tools\Scripts\virtualenv.exe"

# Test if the environment is already set up
$pythonExists = Test-Path -Path $pythonExePath
$virtualenvExists = Test-Path -Path $virtualenvExePath

if ($pythonExists -and $virtualenvExists ) {
    # no work needed
} else {

    # Download the Python zip
    try {
        Invoke-WebRequest -Uri $url -OutFile $zipPath
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Error "Version link not available: $url"
            exit -1
        } else {
            throw $_.Exception
        }
    }

    # Extract the zip
    Expand-Archive -Path $zipPath -DestinationPath $pydirPath -Force 

    # Execute Python command to download and run get-pip.py
    Write-Output "First time is slow, running `pip install virtualenv`..."
    & $pythonExePath -m pip install virtualenv -q --no-warn-script-location
}


$argstring = $env:_args
if ($version -match $pattern) {
    $argstring = $argstring.Substring(($env:_arg1).Length)
}

# Run virtualenv with the collected args
& cmd /c "`"$pythonExePath`" -m virtualenv $argstring"
