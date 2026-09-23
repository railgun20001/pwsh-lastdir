param(
    [Parameter(Mandatory)] [string] $Case,
    [Parameter(Mandatory)] [string] $RuntimePath,
    [Parameter(Mandatory)] [string] $StatePath,
    [Parameter(Mandatory)] [string] $TargetPath
)

$ErrorActionPreference = 'Stop'
$env:PWSH_LASTDIR_STATE_FILE = $StatePath
function global:prompt { 'custom> ' }

switch ($Case) {
    'restore' {
        [System.IO.File]::WriteAllText($StatePath, $TargetPath)
        Set-Location -LiteralPath $HOME
        . $RuntimePath
        if ((Get-Location).Path -ne $TargetPath) { throw 'Saved directory was not restored.' }
        if ((prompt) -ne 'custom> ') { throw 'Original prompt was not preserved.' }
        if ([System.IO.File]::ReadAllText($StatePath) -ne $TargetPath) { throw 'Prompt did not save the directory.' }
    }
    'explicit' {
        [System.IO.File]::WriteAllText($StatePath, $HOME)
        Set-Location -LiteralPath $TargetPath
        . $RuntimePath
        if ((Get-Location).Path -ne $TargetPath) { throw 'Explicit starting directory was changed.' }
        prompt | Out-Null
        if ([System.IO.File]::ReadAllText($StatePath) -ne $TargetPath) { throw 'Explicit directory was not saved.' }
    }
    'missing' {
        [System.IO.File]::WriteAllText($StatePath, (Join-Path $TargetPath 'does-not-exist'))
        Set-Location -LiteralPath $HOME
        . $RuntimePath
        if ((Get-Location).Path -ne $HOME) { throw 'Invalid saved directory was restored.' }
    }
    default { throw "Unknown case: $Case" }
}
