<# :
    @echo off
    set "_cmd=%~f0"
    powershell -nologo -nop -exec bypass "iex (Get-Content '%_cmd%' -Raw)"
    goto :EOF
#>

function Remove-FromUserPath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $dir
    )

    $dir = [io.path]::GetFullPath($dir)
    $path = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
    if (";$path;".Contains(";$dir;")) {
        $path=((";$path;").replace(";$dir;", ";")).Trim(';')
        [Environment]::SetEnvironmentVariable("PATH", $path, [EnvironmentVariableTarget]::User)
		Write-Host "Removed $dir from PATH"
        return
    }
    Write-Host "$dir is not in PATH"
}

Remove-FromUserPath "$env:_cmd/.."
