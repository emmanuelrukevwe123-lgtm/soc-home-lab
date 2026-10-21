# Networking fundamentals

What I've learnt so far, tied to my own lab. Status: **Used** = already in my lab · **Learning** = in progress · **Next** = coming up.

| Fundamental | Status | Where it shows up in my lab |
| --- | --- | --- |
| Network zones and segmentation | Used | LAN, DMZ and MGMT on separate VMware LAN segments |
| Stateful firewall rules | Used | pfSense rules per interface; ufw on Ubuntu |
| Aliases | Used | `Lab_Nets`, `Ubuntu_DMZ_Ports` |
| Private IPv4, /24 networks, default gateway | Used | 10.0.x.0/24, gateways 10.0.x.1 |
| Static IPs | Used | netplan on Ubuntu, installer on Wazuh |
| Outbound NAT | Used | pfSense WAN |
| Ports, ICMP, DNS | Used | 22, 443, 1514; ping rules; pfSense resolver |
| TCP/IP and OSI models, the handshake | Learning | tcpdump on port 22 |
| NTP | Learning | Wazuh clock incident |
| Subnetting beyond /24, DHCP, ARP, VLANs, routing tables | Next | |
| IDS/IPS, micro-segmentation, zero trust, IPv6, VPNs | Next | Suricata on pfSense; cloud security groups |

## OSI and TCP/IP

| OSI layer | TCP/IP layer | Unit | Protocols | Device | In my lab | Example attack |
| --- | --- | --- | --- | --- | --- | --- |
| 7 Application | Application | Data | HTTP, SSH, DNS | Proxy, WAF | Juice Shop, SSH | SQL injection, phishing |
| 6 Presentation | Application | Data | TLS, encoding | | HTTPS to Wazuh | SSL stripping |
| 5 Session | Application | Data | Session setup | | An SSH session | Session hijacking |
| 4 Transport | Transport | Segment / datagram | TCP, UDP | Firewall | Ports 22, 1514 | SYN flood, port scan |
| 3 Network | Internet | Packet | IP, ICMP | Router | 10.0.x.x, pfSense routing | IP spoofing |
| 2 Data link | Link | Frame | Ethernet, ARP | Switch | VMware LAN segments | ARP spoofing |
| 1 Physical | Link | Bits | Cables, Wi-Fi | NIC | Virtual NICs | Wiretapping |

Memory aid, layers 1 to 7: *Please Do Not Throw Sausage Pizza Away*.

**Encapsulation:** my SSH attempt becomes SSH data → + TCP header (port 56578 → 22) → + IP header (10.0.1.101 → 10.0.2.10) → + Ethernet header (MACs). MAC addresses change at every hop; IP addresses stay the same end to end unless NAT rewrites them.

**Why it matters:** the layer tells you which log to read. Port scans show in firewall logs (L4), SQL injection in web logs (L7), and ARP spoofing only in packet captures (L2).

## Subnetting

usable hosts = 2^(32 − prefix) − 2. The two subtracted are the network and broadcast addresses.

| Zone | Network | Gateway | Usable | Broadcast | Hosts |
| --- | --- | --- | --- | --- | --- |
| LAN | 10.0.1.0/24 | 10.0.1.1 | .1 to .254 | 10.0.1.255 | 254 |
| DMZ | 10.0.2.0/24 | 10.0.2.1 | .1 to .254 | 10.0.2.255 | 254 |
| MGMT | 10.0.3.0/24 | 10.0.3.1 | .1 to .254 | 10.0.3.255 | 254 |

| Prefix | Mask | Addresses | Usable |
| --- | --- | --- | --- |
| /32 | 255.255.255.255 | 1 | 1 host (single-host rule) |
| /30 | .252 | 4 | 2 |
| /29 | .248 | 8 | 6 |
| /28 | .240 | 16 | 14 |
| /27 | .224 | 32 | 30 |
| /26 | .192 | 64 | 62 |
| /25 | .128 | 128 | 126 |
| /24 | .0 | 256 | 254 |

- **Block-size shortcut:** 256 − the last mask octet. For /26 that's 64, so subnets start at .0, .64, .128 and .192.
- **Private ranges:** 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16. 169.254.x.x means DHCP failed.
- **Cloud:** AWS and Azure reserve 5 addresses per subnet, so a /24 gives 251 usable.

## TCP, UDP and ports

| | TCP | UDP |
| --- | --- | --- |
| Connection | Three-way handshake | None |
| Delivery | Guaranteed, ordered | Best effort |
| Used by | SSH, HTTPS, Wazuh agent | DNS, DHCP, NTP |

- **Handshake:** SYN → SYN-ACK → ACK. **Teardown:** FIN / ACK. **RST:** abort, or the port is closed.
- tcpdump flags: `[S]` SYN, `[S.]` SYN-ACK, `[.]` ACK, `[P.]` data, `[F.]` FIN, `[R]` RST.
- A burst of SYNs to many ports means a port scan (T1046). An nmap `-sS` scan is "half-open": it never sends the final ACK.

| Port | Service | Port | Service |
| --- | --- | --- | --- |
| 22 | SSH | 1514/1515 | Wazuh agent |
| 53 | DNS | 3000 / 4280 | Juice Shop / DVWA |
| 80/443 | HTTP/HTTPS | 9200 | Wazuh indexer |
| 123 | NTP | 55000 | Wazuh API |
| 88 / 389 / 445 / 3389 | Kerberos / LDAP / SMB / RDP | | |

## Devices, ARP and NAT

| Device | Layer | Decides by | In my lab |
| --- | --- | --- | --- |
| Switch | 2 | MAC address | VMware LAN segments |
| Router | 3 | IP address, routing table | pfSense |
| Stateful firewall | 3–4 | IPs, ports, connection state | pfSense, ufw |
| WAF | 7 | Web requests | Planned in front of Juice Shop |

- **Stateful:** the firewall keeps a state table of allowed connections (5-tuple), so replies are automatic. Only the direction that *starts* a connection needs a rule. That's why the DMZ can reply but never initiate.
- **pfSense:** rules apply where traffic enters, first match wins, and anything unmatched is denied by default.
- **Cloud:** AWS security groups and Azure NSGs are stateful; AWS network ACLs are stateless.
- **ARP** maps IP → MAC (`ip neigh`). ARP spoofing creates a man-in-the-middle.
- **NAT:** outbound NAT rewrites 10.0.x.x to the WAN address. NAT hides addresses but is not a security control.

## DNS, DHCP and NTP

- **DNS (53):** cache → resolver (pfSense / Unbound) → root → .com → authoritative. Records: A, AAAA, CNAME, MX, TXT, PTR, NS. Attacks: spoofing, tunnelling, typosquatting. Tools: `dig`, `dig -x`.
- **DHCP (67/68):** DORA (Discover, Offer, Request, Acknowledge). Servers use static IPs. Attacks: rogue DHCP server, starvation. Lease logs map an IP to a machine.
- **NTP (UDP 123):** stratum hierarchy. A security control for correlation, time-window rules, evidence and Kerberos. My MGMT zone blocks it, which caused [Case 001](../case-studies/001-invisible-ssh-alerts.md).

## Segmentation

- **Trust levels:** internet (untrusted) < DMZ (low) < users (medium) < servers and MGMT (high).
- **North-south** traffic goes in and out of the network. **East-west** traffic moves between internal zones, and that's where lateral movement (TA0008) happens.
- **Where devices go:** edge firewall + IPS at the internet boundary → WAF in front of web apps in the DMZ → internal firewall before trusted zones → EDR on every host → SIEM and jump host in MGMT.
- **Micro-segmentation** applies policy per workload. My ufw rule (SSH only from Kali) is an example. In the cloud, a security group attached to each VM is the normal model.
- **Zero trust:** verify identity, device and context on every request. Never trust a connection because of where it comes from.

## Troubleshooting bottom-up

`ip -br a` → `ip route` → `ping` the gateway → `dig` → `ss -tlnp` / `nc -zv` → firewall logs → `curl -I` / `systemctl status`.
