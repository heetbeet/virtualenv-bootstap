<# :
    @echo off
    set "_cmd=%~f0"
    powershell -nologo -nop -exec bypass "iex (Get-Content '%_cmd%' -Raw)"
    goto :EOF
#>

function Add-ToUserPath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $dir
    )

    $dir = [io.path]::GetFullPath($dir)
    $path = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
	
	$path=((";$path;").replace(";$dir;", ";")).Trim(';')
	$path = "$dir;$path"
	
    [Environment]::SetEnvironmentVariable("PATH", "$path", [EnvironmentVariableTarget]::User)
	Write-Host "Added $dir to PATH"
}


Add-ToUserPath "$env:_cmd/../.."

