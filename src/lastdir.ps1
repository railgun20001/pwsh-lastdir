# 在交互式 Windows PowerShell 5.1 或 PowerShell 7 会话中恢复并记录最近的文件系统目录。
if ($global:PwshLastDirInstalled) { return }
$global:PwshLastDirInstalled = $true

$stateFile = if ($env:PWSH_LASTDIR_STATE_FILE) {
    $env:PWSH_LASTDIR_STATE_FILE
} else {
    Join-Path $HOME '.pwsh_lastdir'
}
$global:PwshLastDirStateFile = $stateFile

$location = Get-Location
if ($location.Provider.Name -eq 'FileSystem' -and $location.Path -eq $HOME -and
    [System.IO.File]::Exists($stateFile)) {
    try {
        $saved = [System.IO.File]::ReadAllText($stateFile).Trim()
        if ($saved -and [System.IO.Directory]::Exists($saved)) {
            Set-Location -LiteralPath $saved
        }
    } catch {
        # 目录记录不可读时，保持 PowerShell 的原始启动目录。
    }
}

$global:PwshLastDirOriginalPrompt = (Get-Command prompt).ScriptBlock
function global:prompt {
    $location = Get-Location
    if ($location.Provider.Name -eq 'FileSystem') {
        $path = $location.ProviderPath
        if ($global:PwshLastDirSavedPath -ne $path) {
            try {
                $stateFile = $global:PwshLastDirStateFile
                $directory = [System.IO.Path]::GetDirectoryName($stateFile)
                if ($directory) {
                    [System.IO.Directory]::CreateDirectory($directory) | Out-Null
                }
                $temporaryFile = "$stateFile.$PID.$([guid]::NewGuid().ToString('N')).tmp"
                $backupFile = "$temporaryFile.bak"
                try {
                    [System.IO.File]::WriteAllText($temporaryFile, $path)
                    # .NET Framework 没有 File.Move 的覆盖重载；用同目录替换保持写入完整。
                    if ([System.IO.File]::Exists($stateFile)) {
                        [System.IO.File]::Replace($temporaryFile, $stateFile, $backupFile)
                    } else {
                        [System.IO.File]::Move($temporaryFile, $stateFile)
                    }
                    $global:PwshLastDirSavedPath = $path
                } finally {
                    if ([System.IO.File]::Exists($temporaryFile)) {
                        [System.IO.File]::Delete($temporaryFile)
                    }
                    if ([System.IO.File]::Exists($backupFile)) {
                        [System.IO.File]::Delete($backupFile)
                    }
                }
            } catch {
                # 记录失败不影响交互式提示符。
            }
        }
    }
    & $global:PwshLastDirOriginalPrompt
}
