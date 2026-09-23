[CmdletBinding()]
param(
    [string] $ProfilePath = $PROFILE.CurrentUserCurrentHost,
    [string] $InstallRoot = (Join-Path $env:LOCALAPPDATA 'PwshLastDir'),
    [switch] $RemoveState
)

$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw 'pwsh-lastdir requires PowerShell 7 or later.'
}

$begin = '# >>> pwsh-lastdir >>>'
$end = '# <<< pwsh-lastdir <<<'
$pattern = '(?ms)^' + [regex]::Escape($begin) + '\r?\n.*?^' + [regex]::Escape($end) + '\r?\n?'
if (Test-Path -LiteralPath $ProfilePath -PathType Leaf) {
    $existing = [System.IO.File]::ReadAllText($ProfilePath)
    if (($existing.Contains($begin) -and -not $existing.Contains($end)) -or
        ($existing.Contains($end) -and -not $existing.Contains($begin))) {
        throw 'Profile contains an incomplete pwsh-lastdir block; fix it manually before uninstalling.'
    }
    $updated = [regex]::Replace($existing, $pattern, '')
    if ($updated -ne $existing) {
        $backup = "$ProfilePath.bak.$(Get-Date -Format 'yyyyMMddHHmmssfff')"
        Copy-Item -LiteralPath $ProfilePath -Destination $backup
        [System.IO.File]::WriteAllText($ProfilePath, $updated, [System.Text.UTF8Encoding]::new($false))
        Write-Output "Profile backup: $backup"
    }
}

$runtimePath = Join-Path $InstallRoot 'lastdir.ps1'
if (Test-Path -LiteralPath $runtimePath -PathType Leaf) {
    Remove-Item -LiteralPath $runtimePath
}
if ((Test-Path -LiteralPath $InstallRoot -PathType Container) -and
    -not (Get-ChildItem -LiteralPath $InstallRoot -Force | Select-Object -First 1)) {
    Remove-Item -LiteralPath $InstallRoot
}
if ($RemoveState) {
    $stateFile = if ($env:PWSH_LASTDIR_STATE_FILE) {
        $env:PWSH_LASTDIR_STATE_FILE
    } else {
        Join-Path $HOME '.pwsh_lastdir'
    }
    if (Test-Path -LiteralPath $stateFile -PathType Leaf) {
        Remove-Item -LiteralPath $stateFile
    }
}
Write-Output "Uninstalled pwsh-lastdir from: $ProfilePath"
