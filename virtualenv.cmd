<# :
    @echo off
    setlocal

    set "_cmd=%~f0"
    set _arg1=%1
    set _arg2=%2
    set _args=%*

    powershell -nologo -nop -exec bypass "iex (Get-Content '%_cmd%' -Raw)"
    goto :EOF
#>

# The first arg is allowed to be a x.y.z version number to dispatch a specefic version of Python
$version = $env:_arg1 -replace '"', ''
$pattern = '^3\.\d+\.\d+$'

# If the first or second argument is --python then the rest of the args is passed to python (not virtualenv)
$runpython_arg1 = (($env:_arg1 -replace '"', '') -eq '--python')
$runpython_arg2 = (($env:_arg2 -replace '"', '') -eq '--python')

$url = "https://www.nuget.org/api/v2/package/python"
if ($version -match $pattern) {
    $url = "https://www.nuget.org/api/v2/package/python/$version"
}

$fileName = $url.Split("/")[-1] + ".zip"
$dirName = $fileName -replace ".zip$", ""
$tempBase = Join-Path -Path $env:TEMP -ChildPath "virtualenv-python-bases/$dirName"

$zipPath = Join-Path -Path $tempBase -ChildPath $fileName
$pydirPath = Join-Path -Path $tempBase -ChildPath "python"
New-Item -Path $pydirPath -ItemType Directory -Force  | Out-Null

# Define the paths
$pydirPath = Resolve-Path -Path $pydirPath -Relative
$pythonExePath = Join-Path -Path $pydirPath -ChildPath "tools\python.exe"
$virtualenvExePath = Join-Path -Path $pydirPath -ChildPath "tools\Scripts\virtualenv.exe"

# Test if the environment is already set up
$pythonExists = Test-Path -Path $pythonExePath
$virtualenvExists = Test-Path -Path $virtualenvExePath

if ($pythonExists -and $virtualenvExists ) {
    # no work needed
} else {
    Write-Output "Downloading '$($url)' and running 'pip install virtualenv'..."

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

    # Extract python and pip install virtualenv
    Expand-Archive -Path $zipPath -DestinationPath $pydirPath -Force 
    & $pythonExePath -m pip install virtualenv -q --no-warn-script-location
}

# Skip the argstring all the way past the <version> section
$argstring = $env:_args
if ($version -match $pattern) {
    $argstring = $argstring.Substring(($env:_arg1).Length)
}

# Run python else virtualenv with the collected args
if ($runpython_arg1) {
    # Skip the argstring all the way past the --python section
    $argstring = ($argstring -replace '^\s+', '').Substring(($env:_arg1 -replace '^\s+', '').Length)
    & cmd /c "`"$pythonExePath`" $argstring"

} elseif ($runpython_arg2) {
    # Skip the argstring all the way past the --python section
    $argstring = ($argstring -replace '^\s+', '').Substring(($env:_arg2 -replace '^\s+', '').Length)
    & cmd /c "`"$pythonExePath`" $argstring"

} else  {
    # Run virtualenv with the collected args
    & cmd /c "`"$pythonExePath`" -m virtualenv $argstring"
}