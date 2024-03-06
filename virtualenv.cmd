<# :
    @echo off
    setlocal

    set "_cmd=%~f0"
    set "_arg1=%~1"
    set "_arg2=%~2"
    set "_arg3=%~3"
    set "_arg4=%~4"
    set "_arg5=%~5"
    set "_arg6=%~6"
    set "_arg7=%~7"
    set "_arg8=%~8"
    set "_arg9=%~9"

    powershell -nologo -nop -exec bypass "iex (Get-Content '%_cmd%' -Raw)"
    goto :EOF
#>

# Retrieve the value from the environment variable
$version = $env:_arg1
$pattern = '^3\.\d+\.\d+$'

$url = "https://www.python.org/ftp/python/3.11.8/python-3.11.8-embed-amd64.zip"
if ($version -match $pattern) {
    $url = "https://www.python.org/ftp/python/$version/python-$version-embed-amd64.zip"
}

$basePath = Resolve-Path -Path "$env:_cmd\..\.." -Relative
$fileName = $url.Split("/")[-1]
$dirName = $fileName -replace ".zip$", ""
$tempBase = Join-Path -Path $env:TEMP -ChildPath "virtualenv-python-bases/$dirName"

$zipPath = Join-Path -Path $tempBase -ChildPath $fileName
$pydirPath = Join-Path -Path $tempBase -ChildPath "python"
New-Item -Path $pydirPath -ItemType Directory -Force  | Out-Null

$pydirPath = Resolve-Path -Path $pydirPath -Relative

# Define the paths
$pythonExePath = Join-Path -Path $pydirPath -ChildPath "python.exe"
$virtualenvExePath = Join-Path -Path $pydirPath -ChildPath "Scripts\virtualenv.exe"
$pipExePath = Join-Path -Path $pydirPath -ChildPath "Scripts\pip.exe"

# Test if the environment is already set up
$pythonExists = Test-Path -Path $pythonExePath
$virtualenvExists = Test-Path -Path $virtualenvExePath
$pipExists = Test-Path -Path $pipExePath

if ($pythonExists -and $virtualenvExists -and $pipExists) {
	# no work needed
} else {
    # If virtualenv is not found, proceed with download and setup
	try {
		$response = Invoke-WebRequest -Uri $url -Method Head -ErrorAction Stop
	} catch {
		if ($_.Exception.Response.StatusCode -eq 404) {
			Write-Error "Version link not available: $url"
			exit -1
		} else {
			throw $_.Exception
		}
	}

    # Download the Python embedded zip
    Invoke-WebRequest -Uri $url -OutFile $zipPath

    # Extract the zip
    Expand-Archive -Path $zipPath -DestinationPath $pydirPath -Force 

    # Find the _pth file and append the required lines to operate as a normal Python installation
    $pypthPath = Get-ChildItem -Path $pydirPath -Filter "python*._pth"
    $pypthContent = "Lib/site-packages", "import site"
    $pypthContent | Add-Content -Path $pypthPath.FullName

    # Execute Python command to download and run get-pip.py
	Write-Output "First time is slow, running `get-pip.py` and `pip install virtualenv`..."
    & $pythonExePath -c "import urllib.request; import sys; sys.argv.extend(['-q', '--no-warn-script-location']); exec(urllib.request.urlopen('https://bootstrap.pypa.io/get-pip.py').read().decode('utf-8'))"
    & $pythonExePath -m pip install virtualenv -q --no-warn-script-location
}

# Create an array from the cmd arguments, bypass the version arg, and pop the empty ones
# Cannot find a good way to transfer the args from cmd to powershell
if ($version -match $pattern) {
	$argArray = @("$env:_arg2", "$env:_arg3", "$env:_arg4", "$env:_arg5", "$env:_arg6", "$env:_arg7", "$env:_arg8", "$env:_arg9")
} else {
	$argArray = @("$env:_arg1", "$env:_arg2", "$env:_arg3", "$env:_arg4", "$env:_arg5", "$env:_arg6", "$env:_arg7", "$env:_arg8", "$env:_arg9")
}
while ($argArray.Count -gt 0 -and $argArray[-1] -eq "") {
    if ($argArray.Count - 1 -eq 0) { $argArray = @() }
    else { $argArray = $argArray[0..($argArray.Count - 2)] }
}

# Run virtualenv with the collected args
& $pythonExePath -m virtualenv @argArray
