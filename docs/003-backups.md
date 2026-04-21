# 003 - WSL Image Backups

This document records how the fresh `UbuntuClean` WSL2 distro is backed up and restored.

## Current Backup

A reusable VHDX backup was created after the base machine setup was completed.

Windows backup path:

```text
C:\Users\bee\Documents\Codex\backups\wsl\UbuntuClean-20260421-090029.vhdx
```

Backup size at creation:

```text
3172990976 bytes
```

This backup includes:

- Ubuntu 24.04 WSL2 base distro
- Linux user `gnu`
- `/home/gnu/captures/raw`
- `/home/gnu/captures/processed`
- `/home/gnu/bin`
- `/home/gnu/beelink` machine docs
- Codex CLI and auth setup
- Bubblewrap
- Tailscale package and local state
- OpenSSH server

## Export Command

Before exporting, shut down WSL cleanly:

```powershell
wsl --shutdown
```

Export as VHDX:

```powershell
wsl --export UbuntuClean C:\Users\bee\Documents\Codex\backups\wsl\UbuntuClean-20260421-090029.vhdx --format vhd
```

If export fails with `ERROR_SHARING_VIOLATION`, wait a few seconds after `wsl --shutdown` and retry.

## Verify Backup

```powershell
Get-Item C:\Users\bee\Documents\Codex\backups\wsl\UbuntuClean-20260421-090029.vhdx |
  Select-Object FullName,Length,LastWriteTime
```

## Restore As A New Distro

Use a new distro name and install location to avoid overwriting anything existing:

```powershell
mkdir C:\WSL\UbuntuCleanRestored
wsl --import UbuntuCleanRestored C:\WSL\UbuntuCleanRestored C:\Users\bee\Documents\Codex\backups\wsl\UbuntuClean-20260421-090029.vhdx --vhd
wsl --manage UbuntuCleanRestored --set-default-user gnu
wsl -d UbuntuCleanRestored
```

Optionally make it the default distro:

```powershell
wsl --set-default UbuntuCleanRestored
```

## Restore In Place Is Not The First Choice

Prefer importing the backup under a new distro name first. Confirm it boots and contains the expected files before deleting or unregistering any existing distro.

Avoid this command until the replacement has been verified:

```powershell
wsl --unregister UbuntuClean
```

That command deletes the distro root filesystem.

## Tailscale Note

Restoring this VHDX may clone Tailscale machine identity/state. If the restored distro is meant to replace the existing `beelink` node, log in normally and clean up duplicate nodes in the Tailscale admin console if needed.

Useful checks after restore:

```bash
tailscale status
tailscale ip -4
systemctl status tailscaled --no-pager
systemctl status ssh --no-pager
codex --version
codex login status
```
