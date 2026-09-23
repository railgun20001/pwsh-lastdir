[CmdletBinding()]
param([string] $PwshPath = (Get-Command pwsh).Source)

$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion.ToString() -ne '7.6.6') {
    throw "Run tests with PowerShell 7.6.6; current version: $($PSVersionTable.PSVersion)"
}

$root = Split-Path -Parent $PSScriptRoot
$scratch = Join-Path ([System.IO.Path]::GetTempPath()) ("pwsh-lastdir-test-" + [guid]::NewGuid().ToString('N'))
[System.IO.Directory]::CreateDirectory($scratch) | Out-Null
try {
    $profilePath = Join-Path $scratch 'profile.ps1'
    $installRoot = Join-Path $scratch 'install'
    $target = Join-Path $scratch 'target'
    $statePath = Join-Path $scratch 'state.txt'
    [System.IO.Directory]::CreateDirectory($target) | Out-Null
    [System.IO.File]::WriteAllText($profilePath, "# Existing user configuration`n")

    & (Join-Path $root 'install.ps1') -ProfilePath $profilePath -InstallRoot $installRoot | Out-Null
    $first = [System.IO.File]::ReadAllText($profilePath)
    if (-not $first.Contains('# Existing user configuration') -or
        -not $first.Contains('# >>> pwsh-lastdir >>>') -or
        -not (Test-Path -LiteralPath (Join-Path $installRoot 'lastdir.ps1'))) {
        throw 'Installation did not preserve the profile and copy the runtime.'
    }
    & (Join-Path $root 'install.ps1') -ProfilePath $profilePath -InstallRoot $installRoot | Out-Null
    if ([System.IO.File]::ReadAllText($profilePath) -ne $first) {
        throw 'Repeated installation changed the profile.'
    }

    foreach ($case in @('restore', 'explicit', 'missing')) {
        & $PwshPath -NoProfile -File (Join-Path $PSScriptRoot 'runtime-case.ps1') `
            -Case $case -RuntimePath (Join-Path $installRoot 'lastdir.ps1') `
            -StatePath $statePath -TargetPath $target
        if ($LASTEXITCODE -ne 0) { throw "Runtime case failed: $case" }
    }

    & (Join-Path $root 'uninstall.ps1') -ProfilePath $profilePath -InstallRoot $installRoot | Out-Null
    $after = [System.IO.File]::ReadAllText($profilePath)
    if ($after -ne "# Existing user configuration`n" -or
        (Test-Path -LiteralPath (Join-Path $installRoot 'lastdir.ps1')) -or
        -not (Test-Path -LiteralPath $statePath)) {
        throw 'Uninstallation did not restore the profile and remove the runtime.'
    }
    $env:PWSH_LASTDIR_STATE_FILE = $statePath
    & (Join-Path $root 'uninstall.ps1') -ProfilePath $profilePath -InstallRoot $installRoot -RemoveState | Out-Null
    if (Test-Path -LiteralPath $statePath) { throw 'RemoveState did not delete the state file.' }
    Write-Output 'PASS: install, reinstall, restore, explicit directory, invalid directory, uninstall, RemoveState.'
} finally {
    Remove-Item Env:PWSH_LASTDIR_STATE_FILE -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $scratch -Recurse -Force
}
