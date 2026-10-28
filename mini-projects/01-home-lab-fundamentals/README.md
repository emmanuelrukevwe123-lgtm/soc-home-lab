# Mini-project 01 · A fundamentals tour of my home lab

**Every topic in stages 1–4, learned on the machines I already run:** pfSense, Kali, the Ubuntu DMZ server (with Juice Shop and DVWA in Docker) and the Wazuh SIEM. Nothing new is installed except small tools (`jq`, `ipcalc`). I explore, measure, capture, attack (my own lab only), detect and write up.

**Time:** two days (about 4–5 hours each) · **Cost:** $0

| Machine | Address | Role in this tour |
| --- | --- | --- |
| pfSense | 10.0.1.1 / 10.0.2.1 / 10.0.3.1 | Router, firewall, NAT, DHCP, DNS, NTP |
| Kali | 10.0.1.101 (LAN) | Analyst and attacker |
| Ubuntu DMZ | 10.0.2.10 | Target server: SSH, Docker, Juice Shop :3000, DVWA :4280, Wazuh agent |
| Wazuh | 10.0.3.10 (MGMT) | SIEM: manager, indexer, dashboard |

| Day | Parts |
| --- | --- |
| **Day 1** | Part 1: how computers and systems work · Part 2: Linux and the command line |
| **Day 2** | Part 3: networking · Part 4: security fundamentals, attack and detect · write-up |

**Tip:** write each answer straight into `notes.md` in this folder as you go. That becomes your write-up.

## What this teaches, and where

| Stage | Topic | Section |
| --- | --- | --- |
| **1 · Systems** | CPU, RAM, storage | 1.1 |
| | Operating systems and kernels | 1.2 |
| | Processes | 1.3 |
| | File systems | 1.4 |
| | Users and permissions | 1.5 |
| **2 · Linux** | Files and folders | 2.1 |
| | Services (systemd) | 2.2 |
| | Logs | 2.3 |
| | Packages | 2.4 |
| | SSH | 2.5 |
| | Bash | 2.6 |
| **3 · Networking** | OSI and TCP/IP | 3.1 |
| | IP addresses and subnetting | 3.2 |
| | Ports, protocols, TCP vs UDP | 3.3 |
| | The TCP handshake | 3.4 |
| | Routing | 3.5 |
| | Firewalls | 3.6 |
| | NAT | 3.7 |
| | DHCP | 3.8 |
| | DNS | 3.9 |
| | HTTP vs HTTPS | 3.10 |
| **4 · Security** | CIA | 4.1 |
| | Least privilege, defence in depth | 4.2 |
| | Zero trust | 4.3 |
| | Risk and threat modelling (STRIDE) | 4.4 |
| | Cryptography: hashes, keys, certificates | 4.5 |
| | TLS | 4.6 |
| | Authentication | 4.7 |
| | Common attacks, and detecting them | 4.8 |

---

# DAY 1

## Part 1 · How computers and systems work

### 1.1 CPU, RAM, storage
Run on **Ubuntu** and on **Wazuh**, and compare with each VM's settings in VMware:
```bash
lscpu | grep -E 'Model name|^CPU\(s\)|Thread'   # CPU model, number of vCPUs
free -h                                         # RAM: total, used, available, swap
df -h /                                         # disk space on the root file system
lsblk                                           # disks and partitions
```
On **Wazuh**, find what uses the memory:
```bash
ps aux --sort=-%mem | head -6      # the indexer (Java) and the dashboard should be at the top
```
**Questions:**
- Do the numbers match what you set in VMware? (They should: the hypervisor gives each VM its slice of the ZBook.)
- Why does Wazuh need about 8 GB while Ubuntu runs fine on much less?
- What does "available" mean in `free -h`, compared with "free"?

### 1.2 Operating systems and kernels
```bash
uname -a                                        # on Ubuntu, Wazuh and Kali: Linux, and which kernel version?
cat /etc/os-release | head -3                   # which distribution and version?
docker exec <dvwa-container> uname -r           # on Ubuntu: the same kernel as the host (docker ps shows the name)
docker exec <dvwa-container> cat /etc/os-release | head -2   # but a different distribution
```
On **pfSense**: Diagnostics → Command Prompt → run `uname -a`. **FreeBSD**, not Linux.
**Lesson:** a VM has its own kernel; a **container shares the host's kernel** and only brings its own files and programs. pfSense shows that a whole different operating system family can run on the same hypervisor.

### 1.3 Processes
On **Wazuh**:
```bash
sudo /var/ossec/bin/wazuh-control status        # the manager's separate daemons
ps -ef | grep [w]azuh- | awk '{print $1, $2, $8}'   # user, PID, program for each
pstree -p | grep -E 'wazuh|java' | head         # who started whom
top                                              # live CPU and memory; press q to quit
```
Match each daemon to your **pipeline from Case 001**:
| Daemon | Job |
| --- | --- |
| `wazuh-remoted` | Receives events from agents (port 1514) |
| `wazuh-authd` | Enrols new agents (port 1515) |
| `wazuh-analysisd` | Decodes events and applies rules: where 5710, 5712 and 100100 run |
| `wazuh-modulesd` | Runs modules (vulnerability detection, cloud integrations) |
| `wazuh-db` | The manager's database of agents |
| `wazuh-logcollector` / `wazuh-syscheckd` | Collect the manager's own logs and file changes |
On **Ubuntu**: `docker top <dvwa-container>` shows the container's processes from the host's view.
**Question:** if `wazuh-analysisd` stopped, what would you still see and what would you lose?

### 1.4 File systems
```bash
df -hT                                  # on Ubuntu: file system types (ext4, tmpfs, overlay)
mount | grep -E ' / |overlay' | head    # how the root and Docker's layered file systems are mounted
sudo du -sh /var/ossec /var/lib/docker 2>/dev/null   # on Wazuh / Ubuntu: what uses space
df -i /                                 # inodes: a file system can also run out of "file slots"
```
**Lesson:** `ext4` is the disk's file system; `tmpfs` lives in RAM; Docker uses `overlay` to stack read-only image layers with a thin writable layer on top.
**Question:** why might a server with free disk space still fail to create files? (Hint: `df -i`.)

### 1.5 Users and permissions
On **Wazuh**:
```bash
ls -l /var/ossec/etc/ossec.conf         # owner, group and mode: who can read the SIEM's config?
id wazuh; getent passwd wazuh           # the service account: its shell is nologin. Why?
ls -l /var/ossec/etc/client.keys        # agent keys: who can read them?
```
On **Ubuntu**:
```bash
id                                      # your user, your groups (sudo? docker?)
ls -la ~/.ssh                           # authorized_keys permissions
sudo -l                                 # what you're allowed to run as root
getent group docker                     # who's in the docker group
```
Work out each mode: `r`=4, `w`=2, `x`=1 for owner, group and others. For example, `640` = owner read+write, group read, others nothing.
**Lesson:** services run as their own **low-privilege users** with no login shell. The `docker` group is effectively **root-equivalent**, because anyone in it can start a container that mounts the whole host. Treat membership as admin access.
**Question:** why is `client.keys` restricted, and what could someone do with it?

## Part 2 · Linux and the command line

### 2.1 Files and folders
| Path | Holds | Examples in your lab |
| --- | --- | --- |
| `/etc` | Configuration | `/etc/ssh/sshd_config.d/01-hardening.conf`, `/etc/chrony/sources.d/pfsense.sources`, `/etc/systemd/timesyncd.conf.d/pfsense.conf` |
| `/var/log` | Logs | `/var/log/auth.log`, `/var/log/syslog` |
| `/var/ossec` | Wazuh's own tree | `etc/ossec.conf`, `logs/alerts/alerts.json`, `etc/rules/local_rules.xml` |
| `/etc/systemd/system` | Your service overrides | `wazuh-manager.service.d/override.conf` |
| `/home/<you>` | Your files | `.ssh/`, scripts |
```bash
cat /etc/ssh/sshd_config.d/01-hardening.conf   # your SSH hardening from phase 2
ls -la /var/ossec/etc/rules/                    # where your custom rule 100100 lives (on Wazuh)
```

### 2.2 Services (systemd)
On **Wazuh**:
```bash
systemctl status wazuh-manager wazuh-indexer wazuh-dashboard --no-pager | grep -E '●|Active'
systemctl cat wazuh-manager | tail -8          # your drop-in: After=wazuh-indexer, TimeoutStartSec=300
systemctl show -p TimeoutStartUSec wazuh-manager
systemctl list-dependencies wazuh-manager | head
```
On **Ubuntu**: `systemctl status ssh docker chrony wazuh-agent --no-pager | grep -E '●|Active'`
**Lesson:** systemd starts services in order, restarts them if configured, and lets you override settings without editing the vendor's file. That's what your boot-timeout fix used.

### 2.3 Logs
```bash
# Ubuntu: the logs the Wazuh agent reads
sudo journalctl -u ssh --since today --no-pager | tail -10
sudo tail -5 /var/log/auth.log
# Wazuh: the SIEM's own health log and its alerts
sudo tail -20 /var/ossec/logs/ossec.log
sudo apt install -y jq
sudo tail -1 /var/ossec/logs/alerts/alerts.json | jq '{time: .timestamp, rule: .rule.id, level: .rule.level, desc: .rule.description, agent: .agent.name}'
sudo jq -r '.rule.id' /var/ossec/logs/alerts/alerts.json | sort | uniq -c | sort -rn | head   # your top rules today
```
**Lesson:** a log line is evidence: *who, what, when, where, result*. `jq` reads JSON logs the way SIEMs store them.

### 2.4 Packages
```bash
apt policy wazuh-manager | head -3     # on Wazuh: installed version vs available
apt policy wazuh-agent | head -3       # on Ubuntu
sudo apt update && apt list --upgradable 2>/dev/null | head -20
systemctl status unattended-upgrades --no-pager | head -3   # automatic security updates on?
docker images                          # on Ubuntu: container images are packages too (and get old)
```
**Lesson:** most compromises use known, already-fixed vulnerabilities, so patching is a core security control. **Wazuh's manager, indexer and dashboard must be upgraded together** (and agents no newer than the manager), so never upgrade one part alone. Read Wazuh's upgrade guide first.

### 2.5 SSH
From **Kali**:
```bash
ssh -v <ubuntu-user>@10.0.2.10 exit 2>&1 | grep -E 'Connecting|kex|Server host key|Authenticat'
# read: the connection, the key exchange, the server's host key, then which authentication methods were offered
ssh-keygen -lf ~/.ssh/known_hosts 2>/dev/null | head -3   # fingerprints of servers you trust
ssh <ubuntu-user>@10.0.2.10 'hostname; uptime; who'       # run commands remotely
```
On **Ubuntu**: `sudo sshd -T | grep -E 'passwordauthentication|permitrootlogin|pubkeyauthentication'`, then `sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`. Does it match the fingerprint Kali stored?
**Lesson:** two keys protect SSH. The **host key** proves the server is real (stopping impersonation); **your key** proves you are you (no password to guess).

### 2.6 Bash
You've already used a `for` loop for the SSH tests. Now write `alert-summary.sh` on Wazuh, which prints the top 5 rules and the top 5 source IPs from today's alerts:
```bash
#!/usr/bin/env bash
set -euo pipefail                       # stop on errors, unset variables and failed pipes
FILE="${1:-/var/ossec/logs/alerts/alerts.json}"
echo "== Top rules =="
jq -r '"\(.rule.id) \(.rule.description)"' "$FILE" | sort | uniq -c | sort -rn | head -5
echo "== Top source IPs =="
jq -r '.data.srcip // empty' "$FILE" | sort | uniq -c | sort -rn | head -5
```
Run it with `sudo bash alert-summary.sh`. Then explain each line in `notes.md`, especially `set -euo pipefail`, `${1:-default}` and `// empty`.

**End of day 1:** push `notes.md`, the script and your screenshots.

---

# DAY 2

## Part 3 · Networking

### 3.1 OSI and TCP/IP: one SSH login, every layer
When Kali runs `ssh <user>@10.0.2.10`:
| TCP/IP layer | OSI layers | What happens |
| --- | --- | --- |
| Application | 7 · 6 · 5 | The SSH protocol: key exchange, encryption, authentication |
| Transport | 4 | TCP, destination port 22, a random source port |
| Internet | 3 | IP from 10.0.1.101 to 10.0.2.10, routed by pfSense |
| Link | 2 · 1 | Ethernet frames between MAC addresses on each VMware network |
Fill in the same table for: **a Wazuh agent sending an event** and **Ubuntu asking pfSense for the time (NTP)**.

### 3.2 IP addresses and subnetting
On each machine: `ip -br a` and `ip route`.
For **LAN, DMZ and MGMT** fill in: network address · subnet mask · broadcast · first and last usable · usable hosts · gateway.
Check with `ipcalc 10.0.2.10/24` (`sudo apt install ipcalc`).
**Question:** if you split 10.0.2.0/24 into four equal subnets, what are they? (Hint: /26.)

### 3.3 Ports, protocols, TCP vs UDP
```bash
sudo ss -tulpn     # on Ubuntu and on Wazuh: every listening port, TCP (t) and UDP (u), with the program
```
Fill in from what you find:
| Port | Protocol | Program | Machine | Purpose |
| --- | --- | --- | --- | --- |
| 22 | TCP | sshd | Ubuntu | Remote admin |
| 1514 / 1515 | TCP | wazuh-remoted / authd | Wazuh | Agent events / enrolment |
| 443 | TCP | dashboard | Wazuh | Web UI |
| 9200 | TCP | indexer | Wazuh | Database API (should listen on localhost only) |
| 55000 | TCP | Wazuh API | Wazuh | Management API |
| 3000 / 4280 | TCP | docker-proxy | Ubuntu | Juice Shop / DVWA |
| 123 | UDP | (pfSense) | pfSense | NTP |
**Question:** why does NTP use UDP while SSH uses TCP?

### 3.4 The TCP handshake, live
On **Ubuntu**: `sudo tcpdump -ni any 'tcp port 22 and host 10.0.1.101' -c 10`
On **Kali**: `ssh <user>@10.0.2.10 exit`
Find `[S]` (SYN), `[S.]` (SYN-ACK), `[.]` (ACK), then data, then `[F.]` (FIN). Now compare with UDP on Ubuntu: `sudo tcpdump -ni any udp port 123 -c 4` while running `sudo chronyc makestep`. **No handshake at all: just a request and a reply.**

### 3.5 Routing
```bash
traceroute -n 10.0.2.10      # from Kali: pfSense, then Ubuntu
traceroute -n 10.0.3.10      # from Kali to Wazuh: does your firewall allow it?
traceroute -n 1.1.1.1        # from Ubuntu (sudo apt install traceroute if missing): pfSense, then VMware NAT, then your home network, then the internet
```
On pfSense: **Diagnostics → Routes**. Find the directly connected networks and the default route.
**Lesson:** a device on one subnet reaches another subnet through a **router** (its default gateway). pfSense is that router for all three zones, which is why it's also the best place to filter.

### 3.6 Firewalls
1. **Read your rules** on each pfSense tab (LAN, DMZ, MGMT) and write each one in plain English: "*Kali may reach the DMZ server on SSH*".
2. **Test them** from Kali. Predict each result *before* you run it:
```bash
nmap -Pn -p 22,3000,4280,3306,8080 10.0.2.10   # which are open, which filtered?
nmap -Pn -p 443,22,9200,55000 10.0.3.10        # what can Kali reach on the SIEM?
```
3. **Host firewall:** on Ubuntu, `sudo ufw status numbered`. Juice Shop (3000) isn't in ufw, yet Kali can reach it: **Docker's own iptables rules bypass ufw**, so pfSense is the control that really protects the containers.
4. **The state table:** pfSense → **Diagnostics → States**. Filter for `10.0.1.101` while an SSH session is open. That's the *stateful* firewall remembering your connection so replies are allowed back.
5. **filtered vs closed:** a port blocked by pfSense shows *filtered* (no reply at all); a port the host itself rejects shows *closed* (the host replied "nothing here"). Find one of each.

### 3.7 NAT
```bash
curl -s https://ifconfig.me; echo     # from Ubuntu: the public address the internet sees
ip -br a                               # versus its private 10.0.2.10
```
pfSense → **Firewall → NAT → Outbound**: find the automatic rules that translate your three zones.
**Lesson:** private ranges (10.x, 172.16–31.x, 192.168.x) can't travel on the internet. pfSense rewrites the source address on the way out and remembers the mapping so replies find their way back. Your traffic is translated more than once: pfSense, then VMware, then your home router.

### 3.8 DHCP
pfSense → **Services → DHCP Server** (which interfaces hand out addresses?) and **Status → DHCP Leases** (who got one?).
On Kali: `ip -br a`, then `nmcli dev show | grep -iE 'ip4.address|gateway|dns'`.
**Lesson:** DHCP's four steps are **D**iscover → **O**ffer → **R**equest → **A**cknowledge (DORA), and it gives a client its address, gateway and DNS server. Servers (Ubuntu, Wazuh) use **static** addresses so their address never changes: agents and firewall rules depend on it.

### 3.9 DNS
1. From Kali: `dig google.com`. Which server answered (the `SERVER:` line)? It should be pfSense.
2. pfSense → **Services → DNS Resolver → Host Overrides → Add:** `juice` · `lab` · `10.0.2.10`, and `siem` · `lab` · `10.0.3.10`. Save and apply.
3. From Kali:
```bash
dig juice.lab +short          # → 10.0.2.10
dig siem.lab +short           # → 10.0.3.10
curl -sI http://juice.lab:3000 | head -3
```
4. On Ubuntu: `resolvectl status | grep -A2 'DNS Servers'`. Who does the server ask?
**Lesson:** DNS turns names into addresses. Attackers abuse it too (fake domains, data hidden in lookups), which is why DNS logs are valuable to a SOC.

### 3.10 HTTP vs HTTPS (the most important capture of the day)
**Wireshark on Kali**, capture on the LAN interface:
1. Open **Juice Shop** (`http://juice.lab:3000`) and log in with a made-up email and password.
2. Stop the capture, filter `http`, find the `POST /rest/user/login`, then **Follow → HTTP Stream**. **Your email and password are readable in plain text.**
3. Capture again while you open the **Wazuh dashboard** (`https://siem.lab`), then filter `tls`. You see a handshake (`Client Hello`, `Server Hello`, `Certificate`) and then only encrypted `Application Data`.
**Lesson:** HTTP sends everything in the clear, so anyone on the path can read it. HTTPS (TLS) encrypts it. That's why every login page must use HTTPS.

## Part 4 · Security fundamentals and the security mindset

### 4.1 CIA in your lab
| Control you already have | C | I | A |
| --- | --- | --- | --- |
| pfSense zones and rules | ✓ | ✓ | |
| SSH keys only, root login off | ✓ | ✓ | |
| HTTPS on the Wazuh dashboard | ✓ | ✓ | |
| Wazuh monitoring and alerts | detects threats to all three | | |
| NTP from pfSense | | ✓ (trustworthy timestamps) | |
| VM snapshots | | ✓ | ✓ |
| The boot-timeout fix | | | ✓ |
**Question:** what's the **weakest** letter in your lab right now, and what would fix it?

### 4.2 Least privilege and defence in depth
Draw (or list) every layer between an attacker on the LAN and **root on the Ubuntu server**: pfSense rules → ufw → SSH (keys only, no root) → user permissions → sudo → Wazuh watching. Then the same for an attacker who **breaks into DVWA**: which layers still stand? (Container user, Docker isolation, the DMZ rules that stop the DMZ starting connections to the LAN.)
**Least privilege check:** pick three of your pfSense rules. Is each as narrow as it could be (one source, one destination, one port)?

### 4.3 Zero trust
Today, anything on the LAN can try to reach the Wazuh dashboard. Zero trust says **network location isn't proof of trust: verify every request** (strong login, MFA, device checks).
**Write down:** three changes that would move your lab towards zero trust (e.g. only Kali may reach the dashboard; MFA on the dashboard; per-service rules instead of "LAN to anything").

### 4.4 Risk and threat modelling (STRIDE)
For the **Ubuntu DMZ server**, fill in one realistic threat per row, the control you already have, and a risk score = likelihood (1–5) × impact (1–5):
| Threat | Example in your lab | Existing control | Score |
| --- | --- | --- | --- |
| **S**poofing | A fake server answering as 10.0.2.10 | _ | _ |
| **T**ampering | Website files or logs changed | _ | _ |
| **R**epudiation | "I didn't run that command" | _ | _ |
| **I**nformation disclosure | Passwords read on the network (see 3.10) | _ | _ |
| **D**enial of service | Juice Shop flooded | _ | _ |
| **E**levation of privilege | A DVWA bug leads to root | _ | _ |
**Your top risk, and your next fix:** _

### 4.5 Cryptography: hashes, keys, certificates
```bash
# Hashes: fingerprints of data
echo "hello" | sha256sum; echo "hellp" | sha256sum        # one letter, completely different hash
sha256sum /etc/ssh/sshd_config                             # record it: Wazuh's file integrity monitoring does this for you

# How Linux stores your password (on Ubuntu)
sudo grep "^$USER:" /etc/shadow | cut -d: -f2 | cut -c1-12; echo
# $y$ = yescrypt: a slow, salted password hash. The salt makes identical passwords look different.

# SSH host keys: asymmetric key pairs
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub     # the public key's fingerprint

# Wazuh's certificates (on Wazuh): its own certificate authority
sudo ls /etc/wazuh-dashboard/certs/
sudo openssl x509 -in /etc/wazuh-dashboard/certs/root-ca.pem -noout -subject -issuer -dates
sudo openssl x509 -in /etc/wazuh-dashboard/certs/dashboard.pem -noout -subject -issuer -dates -ext subjectAltName
sudo openssl verify -CAfile /etc/wazuh-dashboard/certs/root-ca.pem /etc/wazuh-dashboard/certs/dashboard.pem
```
**Lesson:** a **hash** proves data wasn't changed (integrity). A **key pair** proves identity: what the private key signs, the public key verifies. A **certificate** is a public key plus a name, signed by a CA. Wazuh's installer made its own CA, which is why your browser warned you the first time.
**Question:** why is a slow, salted hash (yescrypt) better for passwords than fast SHA-256?

### 4.6 TLS
From Kali:
```bash
openssl s_client -connect 10.0.3.10:443 -brief </dev/null 2>&1 | head -8
# read: Protocol version, Ciphersuite, Peer certificate, and the verification result
```
**Questions:**
- Which TLS version and cipher suite were used?
- Why does verification fail from Kali? (Kali doesn't trust Wazuh's private CA. Browsers show the same thing as a warning.)
- What three things does TLS give you? (Confidentiality, integrity, and authentication of the server.)

### 4.7 Authentication
Compare the ways you prove who you are in your lab:
| Where | Method | Factor | Weakness |
| --- | --- | --- | --- |
| SSH to Ubuntu | Private key | Something you have | If the key file is stolen and has no passphrase |
| Wazuh dashboard | Password over HTTPS | Something you know | No MFA; guessable if weak |
| Juice Shop | Password over **HTTP** | Something you know | Readable on the network (3.10) |
| Wazuh agents | Enrolment key in `client.keys` | Something you have | Stolen keys let a fake agent send events |
**Question:** where would MFA make the biggest difference, and why?

### 4.8 Common attacks, and detecting them (your own lab only)
For each attack: **run it from Kali or Ubuntu → find it in Wazuh → note the rule ID and level, or "not detected" (a blind spot).**

| # | Attack (in your lab) | How | Detected? |
| --- | --- | --- | --- |
| 1 | SSH password guessing | `for i in $(seq 1 10); do ssh -o BatchMode=yes fake$i@10.0.2.10; done` | Expect 5710, then 5712 / 100100 |
| 2 | Network scan | `nmap -Pn -sS -p 1-1000 10.0.2.10` | Probably **not yet**: pfSense logs aren't in Wazuh (P2 fixes this) |
| 3 | SQL injection login bypass on Juice Shop | In the browser, log in with email `' OR 1=1--` and any password | Probably **not**: no web logs in Wazuh (P4 fixes this) |
| 4 | Failed sudo (insider) | On Ubuntu: `sudo -k; sudo ls`, then type a wrong password 3 times | Look for a PAM/sudo failure rule |
| 5 | New local user (persistence) | On Ubuntu: `sudo useradd -M labtest`, then `sudo userdel labtest` | Look for "new user added" |
| 6 | Config tampering (file integrity) | On Ubuntu, add `<directories realtime="yes">/home/<you>/fim-test</directories>` inside `<syscheck>` in `/var/ossec/etc/ossec.conf`, restart the agent, then create and edit a file in that folder | Look for file added / modified |

**For the blind spots (2 and 3):** write one paragraph each: what evidence would you need, which log source would provide it, and which project in your plan adds it.

---

## Results summary (fill in)

| Section | Key finding |
| --- | --- |
| 1.1 | VM resources match VMware? What uses Wazuh's RAM? |
| 1.2 | Container kernel = host kernel? pfSense OS? |
| 1.3 | Wazuh daemons mapped to the pipeline |
| 1.5 | Permissions on `ossec.conf`, `client.keys`; docker group members |
| 2.2 | Your drop-in visible in `systemctl cat` |
| 2.4 | Pending updates? unattended-upgrades on? |
| 2.5 | Host key fingerprint matches? |
| 3.2 | Subnet table for three zones |
| 3.4 | Handshake seen (TCP) vs none (UDP) |
| 3.6 | Predicted vs actual nmap results |
| 3.7 | Public IP vs private IP |
| 3.9 | `juice.lab` and `siem.lab` resolve |
| 3.10 | Password visible over HTTP, encrypted over HTTPS |
| 4.4 | Top STRIDE risk + next fix |
| 4.6 | TLS version and cipher on the dashboard |
| 4.8 | Six attacks: detected / blind spot |

## Screenshots (redact usernames, hostnames and passwords)

`01-free-lscpu.png` · `02-kernel-host-vs-container.png` · `03-wazuh-daemons.png` · `04-permissions.png` · `05-systemctl-cat-dropin.png` · `06-jq-alerts.png` · `07-ssh-verbose.png` · `08-tcpdump-handshake.png` · `09-nmap-predicted-vs-actual.png` · `10-pfsense-states.png` · `11-dig-host-override.png` · `12-wireshark-http-password.png` · `13-wireshark-tls.png` · `14-tls-brief.png` · `15-wazuh-attack-alerts.png`

## Explain it back (in your own words)

1. Why does a container show the same kernel version as its host, and why does that matter for security?
2. Which Wazuh daemon applies your rules, and what happens to alerts if it stops?
3. Why is membership of the `docker` group effectively root access?
4. What did your systemd drop-in change, and why didn't you edit the original service file?
5. Why does SSH use TCP but NTP use UDP?
6. What's the difference between *filtered* and *closed*, and which device produced each?
7. What does NAT do to a packet leaving the DMZ, and how do replies find their way back?
8. Why could you read the Juice Shop password in Wireshark but not the Wazuh dashboard traffic?
9. Why are passwords stored as slow, salted hashes rather than encrypted?
10. Which attack in 4.8 was a blind spot, and how would you close it?
