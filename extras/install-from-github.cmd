<# :
    @echo off
    powershell -nologo -nop -exec bypass "iex (Get-Content '%~f0' -Raw)"
    set "PATH=%LOCALAPPDATA%\virtualenv-bootstrap;%PATH%"
    goto :EOF
#>

echo ''
echo '____    ____ __  ______   __________  __    __     ___      __       _______  __   __ ____    ____ '
echo '\   \  /   /|  ||   _  \ |          ||  |  |  |   /   \    |  |     |   ____||  \ |  |\   \  /   / '
echo ' \   \/   / |  ||  |_)  |''---.  .---''|  |  |  |  /  .  \   |  |     |  |__   |   \|  | \   \/   /  '
echo '  \      /  |  ||      /     |  |    |  |  |  | /  /_\  \  |  |     |   __|  |       |  \      /   '
echo '   \    /   |  ||  |\  ''----.|  |    |  `--''  |/  _____  \ |  ''----.|  |____ |  |\   |   \    /    '
echo '    \__/    |__|| _| \______||__|     \______//__/     \__\|_______||_______||__| \__|    \__/     '
echo ''
echo '                               -- Bootstrap Installer --                                           '
echo ''

$basePath = "$env:LOCALAPPDATA\virtualenv-bootstrap"

Remove-Item -Path "$basePath\*" -Recurse -ErrorAction SilentlyContinue

$latestTagUrl = "https://api.github.com/repos/heetbeet/virtualenv-bootstrap/releases/latest"
$latestTag = (Invoke-RestMethod -Uri $latestTagUrl).tag_name

$downloadUrl = "https://github.com/heetbeet/virtualenv-bootstrap/archive/refs/tags/$latestTag.zip"
$assetsPath = Join-Path -Path $basePath -ChildPath "assets"
$zipPath = Join-Path -Path $assetsPath -ChildPath "$latestTag.zip"

# Ensure the assets directory exists
New-Item -Path $assetsPath -ItemType Directory -Force | Out-Null

echo "Download $downloadUrl"
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

echo "Setup $basePath"
Expand-Archive -Path $zipPath -DestinationPath $assetsPath -Force
$extractedPath = Join-Path -Path $assetsPath -ChildPath "virtualenv-bootstrap-$latestTag"
Copy-Item -Path "$extractedPath\*" -Destination $basePath -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $extractedPath -Recurse -Force -ErrorAction SilentlyContinue

$cmdPath = Join-Path -Path $basePath -ChildPath "extras\add-directory-to-user-path.cmd"
& $cmdPath

# Add uninstall registry entry
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\virtualenv-bootstrap"
$uninstallCommand = 'cmd /c "powershell -c "& {echo \"\"; echo \"Uninstalling Virtualenv Bootstrap\"; echo \"\"; & $env:LOCALAPPDATA/virtualenv-bootstrap/extras/remove-directory-from-user-path.cmd; Remove-Item -Path ''' + $regPath.replace('\', '\\') + ''' -Force; Remove-Item -Path $env:LOCALAPPDATA/virtualenv-bootstrap -Recurse -ErrorAction SilentlyContinue; 5..0 | ForEach-Object {Write-Host \"`rExit in $_\" -NoNewline; Start-Sleep 1}}""'
$cmdIconPath = "$env:SystemRoot\System32\cmd.exe"

# Create the registry entry for the uninstaller
New-Item -Path $regPath -Force | Out-Null
New-ItemProperty -Path $regPath -Name "DisplayName" -Value "virtualenv-bootstrap" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $regPath -Name "UninstallString" -Value $uninstallCommand -PropertyType String -Force | Out-Null
New-ItemProperty -Path $regPath -Name "DisplayIcon" -Value $cmdIconPath -PropertyType String -Force | Out-Null

echo ''
3..0 | ForEach-Object {Write-Host "`rExit in $_" -NoNewline; Start-Sleep 1}
Write-Host "`r" -NoNewline
