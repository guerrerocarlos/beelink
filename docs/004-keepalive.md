# 004 - Keepalive And Auto Start

This document records how `UbuntuClean` is kept available for Tailscale SSH and VS Code Remote SSH.

## Goal

The distro should be reachable after normal Windows restarts and should not disappear just because no interactive WSL shell is open.

## Current State

- WSL distro: `UbuntuClean`
- WSL keepalive service: `beelink-keepalive.service`
- Tailscale service: `tailscaled.service`
- SSH service: `ssh.service`
- Windows startup task: `Beelink UbuntuClean Boot`
- Windows launcher script: `C:\Users\bee\Documents\Codex\scripts\start-ubuntu-clean.cmd`

Verified state:

```text
UbuntuClean: running
beelink-keepalive: active
tailscaled: active
ssh: active
tailscale IPv4: 100.92.158.40
```

## Important Correction

The Windows launcher must run a long-lived WSL command.

This is not enough:

```cmd
wsl.exe -d UbuntuClean --exec /bin/true
```

That command wakes the distro, but WSL may idle out again after the command exits.

Use this instead:

```cmd
C:\Windows\System32\wsl.exe -d UbuntuClean --exec /usr/bin/sleep infinity
```

This keeps a Windows `wsl.exe` process attached to the distro, which keeps `UbuntuClean` running.

## WSL Keepalive Service

Service path:

```text
/etc/systemd/system/beelink-keepalive.service
```

The service runs:

```bash
/usr/bin/sleep infinity
```

This service is useful after WSL starts, but it does not by itself prevent the WSL VM from idling out once the launching Windows-side `wsl.exe` process exits. The Windows launcher below is the more important piece for always-on behavior.

Check status:

```bash
systemctl status beelink-keepalive --no-pager
systemctl is-active beelink-keepalive tailscaled ssh
```

Restart manually:

```bash
sudo systemctl restart beelink-keepalive tailscaled ssh
```

## Windows Boot Task

Task name:

```text
Beelink UbuntuClean Boot
```

Schedule:

```text
At system startup
```

Run as user:

```text
bee
```

Task command:

```text
C:\Users\bee\Documents\Codex\scripts\start-ubuntu-clean.cmd
```

Launcher script contents:

```cmd
@echo off
C:\Windows\System32\wsl.exe -d UbuntuClean --exec /usr/bin/sleep infinity
```

The launcher keeps one long-running WSL process alive. Once WSL starts, systemd also starts:

```text
beelink-keepalive.service
tailscaled.service
ssh.service
```

## Create The Boot Task

This requires Administrator PowerShell and the Windows password for `beelink\bee`.

Create the launcher:

```powershell
$script = 'C:\Users\bee\Documents\Codex\scripts\start-ubuntu-clean.cmd'

@'
@echo off
C:\Windows\System32\wsl.exe -d UbuntuClean --exec /usr/bin/sleep infinity
'@ | Set-Content -Path $script -Encoding ASCII
```

Create the task:

```powershell
schtasks /Create /F `
  /TN "Beelink UbuntuClean Boot" `
  /SC ONSTART `
  /DELAY 0001:00 `
  /RU "beelink\bee" `
  /RP * `
  /TR "`"$script`""
```

## Verify The Task

Query:

```powershell
schtasks /Query /TN "Beelink UbuntuClean Boot" /V /FO LIST
```

Run manually:

```powershell
schtasks /Run /TN "Beelink UbuntuClean Boot"
```

Expected task details:

```text
Schedule Type: At system start up
Scheduled Task State: Enabled
Last Result: 0
Task To Run: C:\Users\bee\Documents\Codex\scripts\start-ubuntu-clean.cmd
```

## Verify After Reboot Or Idle

From Windows:

```powershell
wsl -l -v
wsl -d UbuntuClean -- systemctl is-active beelink-keepalive tailscaled ssh
wsl -d UbuntuClean -- tailscale ip -4
```

Expected:

```text
UbuntuClean    Running    2
active
active
active
100.92.158.40
```

Check the Windows-side keepalive process:

```powershell
Get-CimInstance Win32_Process -Filter "name = 'wsl.exe'" |
  Select-Object ProcessId,CommandLine
```

Expected command line:

```text
C:\Windows\System32\wsl.exe -d UbuntuClean --exec /usr/bin/sleep infinity
```

From another Tailscale machine:

```bash
ssh gnu@beelink
```

or:

```bash
ssh gnu@100.92.158.40
```

## Notes

The task runs as the Windows user that owns the WSL distro. This matters because WSL distributions are per-user. Running the task as `SYSTEM` is not expected to see this user's `UbuntuClean` distro.

If multiple keepalive launcher processes are started manually during testing, they are harmless but redundant. After a normal host boot, the scheduled task should start one.
