# pwsh-lastdir

在新开的 PowerShell 窗口中继续使用最近的工作目录。 / Resume your most recent working directory in a new PowerShell window.

## 中文

### 功能

- 每次出现交互式提示符时，将当前文件系统目录保存到 `~/.pwsh_lastdir`。
- 新会话从用户主目录启动时，自动进入上次保存且仍然存在的目录。
- 若终端已指定其他启动目录，保持该目录不变。
- 保留原有的 PowerShell 提示符；安装和卸载均会备份发生改动的 profile。

**支持 Windows PowerShell 5.1（`powershell.exe`）和 PowerShell 7（`pwsh`），不提供 cmd 支持。** 两种 shell 共用一份目录记录，最后一次显示提示符的窗口会更新它。若显式指定的启动目录恰好是用户主目录，仍会触发恢复。

已在 Windows 上使用 **Windows PowerShell 5.1** 和 **PowerShell 7.6.6** 验证。安装不需要管理员权限，也不会自动下载其他程序。

### 安装

```powershell
git clone https://github.com/railgun20001/pwsh-lastdir.git
cd pwsh-lastdir
# 安装到 PowerShell 7
pwsh -NoProfile -File ./install.ps1
# 安装到 Windows PowerShell 5.1
powershell.exe -NoProfile -File ./install.ps1
```

按需运行对应命令；若两种 shell 都使用，就分别运行两条安装命令。重新打开相应窗口后生效。PowerShell 7 使用 `%LOCALAPPDATA%/PwshLastDir/lastdir.ps1`，Windows PowerShell 5.1 使用 `%LOCALAPPDATA%/PwshLastDir/WindowsPowerShell/lastdir.ps1`。两者写入各自当前用户的 ConsoleHost profile，共用 `~/.pwsh_lastdir`。重复安装不会重复添加加载代码；修改已有 profile 前会在同目录生成带时间戳的备份。

若 profile 已有自己编写的同类目录恢复代码，请先手动移除旧代码，以免两个提示符钩子同时工作。

### 卸载

```powershell
pwsh -NoProfile -File ./uninstall.ps1
powershell.exe -NoProfile -File ./uninstall.ps1
```

按需运行对应命令以分别卸载。卸载会移除该 shell 的加载代码和运行脚本，保留两者共用的 `~/.pwsh_lastdir`。若两种 shell 均已卸载，还要删除目录记录，可额外执行其中一条：

```powershell
pwsh -NoProfile -File ./uninstall.ps1 -RemoveState
```

如果安装时使用了自定义 `-ProfilePath` 或 `-InstallRoot`，卸载时需传入相同参数。卸载后重新打开窗口即可停止使用。

### 测试

```powershell
pwsh -NoProfile -File ./tests/test.ps1
```

也可运行 `powershell.exe -NoProfile -File ./tests/test.ps1` 验证 Windows PowerShell 5.1。测试使用临时 profile 和目录，不修改真实的 PowerShell 配置。

## English

### Features

- Saves the current filesystem directory to `~/.pwsh_lastdir` whenever the interactive prompt appears.
- Restores the saved directory when a new session starts in your home directory, provided that directory still exists.
- Leaves an explicitly selected starting directory unchanged when it differs from your home directory.
- Preserves your existing prompt. The installer and uninstaller back up a profile before changing it.

**Supports Windows PowerShell 5.1 (`powershell.exe`) and PowerShell 7 (`pwsh`). cmd is not supported.** Both shells share one state file; the last window to display a prompt updates it. A session explicitly started in the home directory will also restore the saved directory.

Tested on Windows with **Windows PowerShell 5.1** and **PowerShell 7.6.6**. Installation needs no administrator privileges and downloads no dependencies.

### Install

```powershell
git clone https://github.com/railgun20001/pwsh-lastdir.git
cd pwsh-lastdir
# Install for PowerShell 7
pwsh -NoProfile -File ./install.ps1
# Install for Windows PowerShell 5.1
powershell.exe -NoProfile -File ./install.ps1
```

Run the command for each shell you use, then open a new window. PowerShell 7 stores its runtime at `%LOCALAPPDATA%/PwshLastDir/lastdir.ps1`; Windows PowerShell 5.1 uses `%LOCALAPPDATA%/PwshLastDir/WindowsPowerShell/lastdir.ps1`. Each installer adds a marked block to that shell's current-user ConsoleHost profile. Both share `~/.pwsh_lastdir`. Running the installer again updates the runtime without adding a second block. An existing profile receives a timestamped backup before it changes.

If your profile already contains a custom directory restore hook, remove that old code first to avoid running both prompt hooks.

### Uninstall

```powershell
pwsh -NoProfile -File ./uninstall.ps1
powershell.exe -NoProfile -File ./uninstall.ps1
```

Run the relevant command to uninstall each shell separately. The shared directory state file is retained for a possible reinstall. After uninstalling both shells, you can delete it too:

```powershell
pwsh -NoProfile -File ./uninstall.ps1 -RemoveState
```

If you installed with a custom `-ProfilePath` or `-InstallRoot`, pass the same values when uninstalling. Open a new window for the change to take effect.

### Test

```powershell
pwsh -NoProfile -File ./tests/test.ps1
```

You can also run `powershell.exe -NoProfile -File ./tests/test.ps1` for Windows PowerShell 5.1. Tests use temporary profiles and directories. They do not modify your actual PowerShell configuration.

## License

[MIT](LICENSE)
