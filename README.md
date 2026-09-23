# pwsh-lastdir

在新开的 PowerShell 7 窗口中继续使用最近的工作目录。 / Resume your most recent working directory in a new PowerShell 7 window.

## 中文

### 功能

- 每次出现交互式提示符时，将当前文件系统目录保存到 `~/.pwsh_lastdir`。
- 新会话从用户主目录启动时，自动进入上次保存且仍然存在的目录。
- 若终端已指定其他启动目录，保持该目录不变。
- 保留原有的 PowerShell 提示符；安装和卸载均会备份发生改动的 profile。

**仅支持 PowerShell 7（`pwsh`），不提供 cmd 支持。** 不支持 Windows PowerShell 5.1。多个窗口共用一份目录记录，最后一次显示提示符的窗口会更新它。若显式指定的启动目录恰好是用户主目录，仍会触发恢复。

已在 Windows 上使用 **PowerShell 7.6.6** 验证。安装不需要管理员权限，也不会自动下载其他程序。

### 安装

```powershell
git clone https://github.com/railgun20001/pwsh-lastdir.git
cd pwsh-lastdir
pwsh -NoProfile -File ./install.ps1
```

关闭并重新打开 pwsh 窗口后生效。安装脚本将运行脚本复制到当前用户的 `%LOCALAPPDATA%/PwshLastDir/lastdir.ps1`，并在当前用户的 pwsh ConsoleHost profile 中添加带标记的加载代码。重复运行安装脚本可更新运行脚本，不会重复添加代码。安装前若 profile 已存在，发生修改时会在同目录生成带时间戳的备份。

若 profile 已有自己编写的同类目录恢复代码，请先手动移除旧代码，以免两个提示符钩子同时工作。

### 卸载

```powershell
pwsh -NoProfile -File ./uninstall.ps1
```

卸载会移除加载代码和复制的运行脚本，保留 `~/.pwsh_lastdir`，以便以后重新安装。若还要删除目录记录：

```powershell
pwsh -NoProfile -File ./uninstall.ps1 -RemoveState
```

如果安装时使用了自定义 `-ProfilePath` 或 `-InstallRoot`，卸载时需传入相同参数。卸载后重新打开窗口即可停止使用。

### 测试

```powershell
pwsh -NoProfile -File ./tests/test.ps1
```

测试要求 PowerShell 7.6.6，使用临时 profile 和目录，不修改真实的 PowerShell 配置。

## English

### Features

- Saves the current filesystem directory to `~/.pwsh_lastdir` whenever the interactive prompt appears.
- Restores the saved directory when a new session starts in your home directory, provided that directory still exists.
- Leaves an explicitly selected starting directory unchanged when it differs from your home directory.
- Preserves your existing prompt. The installer and uninstaller back up a profile before changing it.

**PowerShell 7 (`pwsh`) only. cmd is not supported.** Windows PowerShell 5.1 is not supported. All windows share one state file; the last window to display a prompt updates it. A session explicitly started in the home directory will also restore the saved directory.

Tested on Windows with **PowerShell 7.6.6**. Installation needs no administrator privileges and downloads no dependencies.

### Install

```powershell
git clone https://github.com/railgun20001/pwsh-lastdir.git
cd pwsh-lastdir
pwsh -NoProfile -File ./install.ps1
```

Open a new pwsh window to activate it. The installer copies the runtime to `%LOCALAPPDATA%/PwshLastDir/lastdir.ps1` and adds a marked loader block to the current user's pwsh ConsoleHost profile. Run the installer again to update the runtime without adding a second block. When an existing profile changes, a timestamped backup is written next to it.

If your profile already contains a custom directory restore hook, remove that old code first to avoid running both prompt hooks.

### Uninstall

```powershell
pwsh -NoProfile -File ./uninstall.ps1
```

The directory state file is retained for a possible reinstall. To delete it as well:

```powershell
pwsh -NoProfile -File ./uninstall.ps1 -RemoveState
```

If you installed with a custom `-ProfilePath` or `-InstallRoot`, pass the same values when uninstalling. Open a new window for the change to take effect.

### Test

```powershell
pwsh -NoProfile -File ./tests/test.ps1
```

The test suite requires PowerShell 7.6.6 and uses temporary profiles and directories. It does not modify your actual PowerShell configuration.

## License

[MIT](LICENSE)
