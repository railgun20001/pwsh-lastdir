[CmdletBinding()]
param(
    [string] $ProfilePath = $PROFILE.CurrentUserCurrentHost,
    [string] $InstallRoot
)

$ErrorActionPreference = 'Stop'
$version = $PSVersionTable.PSVersion
if (-not (($version.Major -eq 5 -and $version.Minor -ge 1) -or $version.Major -ge 7)) {
    throw 'pwsh-lastdir requires Windows PowerShell 5.1 or PowerShell 7.'
}
if (-not $InstallRoot) {
    # 5.1 与 7 使用独立运行脚本，避免卸载其中一个时影响另一个。
    $subdirectory = if ($PSVersionTable.PSVersion.Major -eq 5) {
        'PwshLastDir/WindowsPowerShell'
    } else {
        'PwshLastDir'
    }
    $InstallRoot = Join-Path $env:LOCALAPPDATA $subdirectory
}

$source = Join-Path $PSScriptRoot 'src/lastdir.ps1'
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Runtime script not found: $source"
}

$begin = '# >>> pwsh-lastdir >>>'
$end = '# <<< pwsh-lastdir <<<'
$pattern = '(?ms)^' + [regex]::Escape($begin) + '\r?\n.*?^' + [regex]::Escape($end) + '\r?\n?'
$runtimePath = Join-Path $InstallRoot 'lastdir.ps1'
$quotedPath = "'" + $runtimePath.Replace("'", "''") + "'"
$block = "$begin`n. $quotedPath`n$end`n"

$profileDirectory = Split-Path -Parent $ProfilePath
if (-not $profileDirectory) { throw 'ProfilePath must contain a directory.' }
[System.IO.Directory]::CreateDirectory($profileDirectory) | Out-Null
[System.IO.Directory]::CreateDirectory($InstallRoot) | Out-Null

$existing = if (Test-Path -LiteralPath $ProfilePath -PathType Leaf) {
    [System.IO.File]::ReadAllText($ProfilePath)
} else { '' }
if (($existing.Contains($begin) -and -not $existing.Contains($end)) -or
    ($existing.Contains($end) -and -not $existing.Contains($begin))) {
    throw 'Profile contains an incomplete pwsh-lastdir block; fix it manually before installing.'
}

$clean = [regex]::Replace($existing, $pattern, '')
$separator = if ($clean.Length -gt 0 -and -not $clean.EndsWith("`n")) { "`n" } else { '' }
$updated = $clean + $separator + $block
Copy-Item -LiteralPath $source -Destination $runtimePath -Force
if ($updated -ne $existing) {
    if (Test-Path -LiteralPath $ProfilePath -PathType Leaf) {
        $backup = "$ProfilePath.bak.$(Get-Date -Format 'yyyyMMddHHmmssfff')"
        Copy-Item -LiteralPath $ProfilePath -Destination $backup
        Write-Output "Profile backup: $backup"
    }
    [System.IO.File]::WriteAllText($ProfilePath, $updated, [System.Text.UTF8Encoding]::new($false))
}
Write-Output "Installed pwsh-lastdir in: $ProfilePath"
