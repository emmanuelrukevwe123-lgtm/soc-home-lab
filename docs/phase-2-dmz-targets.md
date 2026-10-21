# Phase 2: DMZ targets, SSH hardening and host firewall

**Result:** two vulnerable web apps running in Docker on a hardened Ubuntu server, reachable only from Kali.

## Static IP

Ubuntu 26.04 was given 10.0.2.10 with netplan, and cloud-init's network config was disabled so it can't overwrite the setting at boot.

## Docker from the official signed repository

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
# Add /etc/apt/sources.list.d/docker.sources (Types, URIs, Suites, Components: stable, Signed-By)
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

The signing key lets apt verify every package really came from Docker, which is supply-chain security in practice.

**Bugs I hit:** `Suites:` was empty, and `Components: Stable` with a capital S gave "no installation candidate". Repo files are case-sensitive.

## Vulnerable targets

| App | How | Port |
| --- | --- | --- |
| OWASP Juice Shop | `docker run -d --name juice-shop --restart unless-stopped -p 3000:3000 bkimminich/juice-shop` | 3000 |
| DVWA | `git clone https://github.com/digininja/DVWA && docker compose up -d` | 4280 |

DVWA's `compose.yml` binds to `127.0.0.1:4280:80` by default (this machine only). I changed it to `4280:80` so Kali could reach it.

## SSH hardening

```bash
# On Kali
ssh-keygen -t ed25519
ssh-copy-id <user>@10.0.2.10

# On Ubuntu: /etc/ssh/sshd_config.d/01-hardening.conf
PasswordAuthentication no
PermitRootLogin no
```

The `01-` prefix matters. Files in `sshd_config.d/` load in name order and the first value set wins, so this file beats cloud-init's file.

## Host firewall (ufw)

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 10.0.1.101 to any port 22 proto tcp
sudo ufw enable
```

**Important:** Docker-published ports bypass ufw. pfSense is the control that actually protects Juice Shop and DVWA.

## Lessons

- Defence in depth: the network firewall, the host firewall and key-only SSH each cover a different failure.
- Least privilege: one machine may SSH in, with one method.

Evidence: [screenshots/phase-2](../screenshots/phase-2/)
