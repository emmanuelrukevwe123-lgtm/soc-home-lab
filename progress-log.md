# Progress log

Newest first.

| Date | Session | What I did | Key lesson |
| --- | --- | --- | --- |
| 2026-10-22 | Session 4: brute-force detection | Reboot test passed (NTP); fixed the manager boot crash (45 s start timeout → systemd drop-in, 300 s); tightened MGMT rule to DNS 53; triggered rule 5712 (level 10) with a Bash loop | Find the root cause of recurring failures; correlation raises confidence; every rule has blind spots |
| 2026-10-22 | Session 3: DMZ time + alert hygiene | Ubuntu DMZ synced from pfSense via chrony (disabled the unreachable NTS pool); removed the duplicate auth.log source, so 1 attempt = 1 alert; corrected Case 001 | Check which service is running; deduplicate on PID + port; correct reports when evidence changes |
| 2026-10-22 | Session 2: NTP | pfSense as the lab time server; MGMT NTP rule; Wazuh synced via systemd-timesyncd (corrected −59 min 59.78 s) | Config section names are case-sensitive; a fix must survive a reboot |
| 2026-10-21 | Notes and portfolio | Wrote up networking fundamentals; created this repository | Documentation is part of the job |
| 2026-10-20 | Session 1: TCP/IP + first detection | Fixed agent collection, manager crash and SIEM clock skew; rule 5710 alerts visible | Trace the pipeline hop by hop; check the time on every machine |
| 2026-10-14 | Wazuh agent | Enrolled `ubuntu-dmz`; ran fake SSH logins; Ruleset Test disproved my decoder theory | Test before you fix |
| 2026-10-14 | Wazuh server | All-in-one install of Wazuh 4.14.8 in MGMT | Flags are case-sensitive (`-sO`, not `-s0`) |
| Week 2 | Phase 2 hardening | SSH key-only login, root login off, ufw allowing SSH from Kali only | Docker-published ports bypass ufw |
| Day 7 | Phase 2 targets | Docker, Juice Shop, DVWA in the DMZ | Repo files are case-sensitive; localhost binding means "this machine only" |
| Day 6 | Linux CLI | Folders, cat, permissions, processes | |
| Days 1–5 | Phase 1 network | pfSense, three zones, aliases, least-privilege rules, rule testing | Test every rule you write |

## Snapshots

| VM | Snapshot | State |
| --- | --- | --- |
| Ubuntu DMZ | `ubuntu-02-static-ip` | Static IP set |
| Ubuntu DMZ | `ubuntu-03-docker-apps` | Docker apps running |
| Ubuntu DMZ | `ubuntu-05-wazuh-agent` | Agent enrolled, reading auth.log |
| Wazuh | `wazuh-02-first-detection` | First detection working |
| Wazuh | `latest ntp sync` (22 Oct) | Synced from pfSense via timesyncd |
| pfSense | `ntp rules` (22 Oct) | NTP server on, MGMT and DMZ NTP rules |
