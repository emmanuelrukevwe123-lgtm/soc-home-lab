# Lab architecture

Four VMs on VMware Workstation Pro. pfSense connects three isolated VMware LAN segments, so every conversation between zones must pass through its firewall rules.

## Why three zones

| Zone | Full name | Purpose | Trust |
| --- | --- | --- | --- |
| LAN | Local Area Network | The user and analyst network (Kali) | Medium |
| DMZ | Demilitarised Zone | Buffer zone for exposed services (the vulnerable web apps) | Low |
| MGMT | Management | Tools that watch and control everything (the SIEM) | Highest |

A VMware "LAN segment" is a private virtual switch: only the VMs attached to it can talk on it. The three segments act like three separate physical switches, and pfSense is the only device plugged into all three.

## Machines

| Machine | Zone | IP | Role |
| --- | --- | --- | --- |
| pfSense CE | All (router) | Gateways 10.0.1.1, 10.0.2.1, 10.0.3.1 | Firewall, router, NAT, DNS resolver |
| Kali Linux | LAN | 10.0.1.101 | Attacker and analyst workstation |
| Ubuntu 26.04 | DMZ | 10.0.2.10 (static) | Target server: Docker apps, Wazuh agent |
| Ubuntu 24.04.5 + Wazuh 4.14.8 | MGMT | 10.0.3.10 (static) | SIEM: indexer, manager, dashboard |
| Windows Server 2022 | Planned for MGMT | 10.0.3.20 | Future Active Directory domain controller |

## Firewall aliases

| Alias | Contents |
| --- | --- |
| `Lab_Nets` | 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24 |
| `Ubuntu_DMZ` | 10.0.2.10 |
| `Wazuh` | 10.0.3.10 |
| `Ubuntu_DMZ_Ports` | 22, 80, 443, 3000, 4280 |
| `Web_Ports` | 80, 443 |
| `Wazuh_Agent_Ports` | 1514, 1515 |

## Firewall rules (first match wins, default deny)

**LAN**
1. Allow DNS to pfSense
2. Allow to `Ubuntu_DMZ` on `Ubuntu_DMZ_Ports`
3. Allow to `Wazuh` on `Wazuh_Agent_Ports` and 443
4. Block `Lab_Nets` (logged)
5. Allow any (internet only, since lab networks are already blocked above)

**DMZ**
1. Allow DNS (53) to pfSense
2. Allow ICMP to the DMZ gateway
3. Allow to `Wazuh` on `Wazuh_Agent_Ports`
4. Allow to `!Lab_Nets` on `Web_Ports` (internet updates only)
5. Block `Lab_Nets` (logged)

**MGMT**
1. Allow DNS to pfSense
2. Allow to `!Lab_Nets` on `Web_Ports`
3. Allow SSH to `Ubuntu_DMZ`
4. Block `Lab_Nets`

## Why stateful rules make the DMZ work

pfSense tracks each allowed connection in a state table, so replies are allowed automatically. Kali can open a connection to Ubuntu, and Ubuntu can answer, but Ubuntu can never *start* a connection into the LAN. If the DMZ server is compromised, the attacker is contained.

## Host-level controls on the DMZ server

- SSH: key-based login only (`PasswordAuthentication no`), root login disabled, in `/etc/ssh/sshd_config.d/01-hardening.conf`.
- ufw: deny all incoming, allow SSH only from 10.0.1.101.
- Note: Docker-published ports bypass ufw, so pfSense is the real control for the web apps.

## Time sync

pfSense is the lab's NTP server. Wazuh (systemd-timesyncd) and the Ubuntu DMZ server (chrony) sync from it through UDP 123 rules on the MGMT and DMZ tabs. See [Phase 4.1](phase-4-ntp-time-sync.md).

## Known gaps (tracked)

- Plain NTP is unauthenticated. That's acceptable in this isolated lab; production would use NTS.
