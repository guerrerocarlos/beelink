# 001 - Tailscale And SSH Keys

This document records the Tailscale and SSH setup for the fresh `UbuntuClean` WSL2 distro.

## Current State

- Tailscale package: `1.96.4`
- Tailscale node name: `beelink`
- Tailscale IPv4: `100.92.158.40`
- Tailscale service: `tailscaled`, active under systemd
- SSH service: `ssh`, active under systemd
- SSH listen port: `22`
- Linux login user: `gnu`

## Installed Packages

Tailscale was installed from the official Tailscale Ubuntu 24.04 `noble` repository:

```bash
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg \
  | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list \
  | sudo tee /etc/apt/sources.list.d/tailscale.list >/dev/null
sudo apt-get update
sudo apt-get install -y tailscale
```

OpenSSH server was installed with:

```bash
sudo apt-get install -y openssh-server
sudo systemctl enable --now ssh
```

## Tailscale Login

Tailscale was brought up with:

```bash
sudo tailscale up --hostname=beelink --operator=gnu
```

The `--operator=gnu` setting allows the normal `gnu` user to run Tailscale client commands.

## Verification Commands

Check Tailscale:

```bash
tailscale status
tailscale ip -4
systemctl status tailscaled --no-pager
```

Check SSH:

```bash
systemctl status ssh --no-pager
ss -ltnp | grep ':22'
```

Expected SSH listener:

```text
0.0.0.0:22
[::]:22
```

## Login From Another Tailscale Machine

Use the Tailscale IPv4 address:

```bash
ssh gnu@100.92.158.40
```

If MagicDNS is working:

```bash
ssh gnu@beelink
```

## SSH Keys

The `gnu` user already has an SSH folder:

```text
/home/gnu/.ssh
```

Important files:

```text
/home/gnu/.ssh/authorized_keys
/home/gnu/.ssh/id_ed25519
/home/gnu/.ssh/id_ed25519.pub
```

The presence of `authorized_keys` means key-based SSH may already work from existing trusted machines.

To add a new client machine, get the public key on that client:

```bash
cat ~/.ssh/id_ed25519.pub
```

Then append that public key to:

```text
/home/gnu/.ssh/authorized_keys
```

Recommended permissions:

```bash
chmod 700 /home/gnu/.ssh
chmod 600 /home/gnu/.ssh/authorized_keys
chmod 600 /home/gnu/.ssh/id_ed25519
chmod 644 /home/gnu/.ssh/id_ed25519.pub
```

## Replacing The Old Beelink Node

The fresh WSL distro was configured to advertise itself as `beelink`.

If Tailscale keeps the previous node, the admin console may show both devices or rename the new one to `beelink-1`. In that case:

1. Open the Tailscale admin console.
2. Delete or expire the old `beelink` node.
3. Rename this new Linux node to `beelink` if needed.

Do not delete local WSL state just to rename a node; node naming is managed by the Tailscale control plane.
