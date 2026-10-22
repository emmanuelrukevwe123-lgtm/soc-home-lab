# Phase 4.1: Lab time sync with NTP through pfSense

**Result:** the Wazuh SIEM now syncs its clock from pfSense automatically. This is the permanent fix for the clock skew in [Case 001](../case-studies/001-invisible-ssh-alerts.md).

## Design

```
Internet NTP pool (stratum 2) → pfSense (stratum 3) → Wazuh 10.0.3.10 (stratum 4)
```

One internal time source syncs from the internet, and every lab machine syncs from it. That gives one consistent time, one narrow firewall rule per zone, and no servers reaching the internet just for time.

## Steps

1. **pfSense is synced:** Status → NTP shows an *Active Peer* (stratum 2) plus candidates. NTP compares several sources and ignores outliers.
2. **pfSense serves time** on its LAN, DMZ and MGMT interfaces (Services → NTP).
3. **Firewall rule** at the top of the MGMT tab: Pass · UDP · MGMT subnets → MGMT address · port 123 (NTP).
4. **Wazuh points at pfSense** using a systemd-timesyncd drop-in file:

```bash
printf '[Time]\nNTP=10.0.3.1\n' | sudo tee /etc/systemd/timesyncd.conf.d/pfsense.conf
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd
timedatectl timesync-status
```

## Result

| Field | Value |
| --- | --- |
| Server | 10.0.3.1 |
| Stratum | 3 |
| Offset corrected | −59 min 59.78 s |
| Delay | 2.2 ms |
| System clock synchronized | **yes** (the first time on this VM) |

## Findings along the way

- **The real block was different from my first assumption.** An existing MGMT rule already allowed MGMT to reach pfSense on any port. Wazuh couldn't sync because it was using `ntp.ubuntu.com` on the internet over UDP, and MGMT only allows TCP out. Fixing the design (sync from pfSense) solved it either way.
- **Over-broad rule:** that MGMT rule allowed every port to pfSense, including the web GUI and SSH. Action: tighten it to DNS (53) only.
- **Section names are case-sensitive.** `[TIME]` was silently ignored, so the service kept using its default server. `[Time]` worked. The evidence was `Server: ntp.ubuntu.com` and `Packet count: 0`.
- **Heredocs need a new line after each line of text.** Typed on one line, the shell waits for `EOF` forever.

## The Ubuntu DMZ server: chrony

Ubuntu 26.04 uses **chrony**, not systemd-timesyncd: `systemctl is-active chrony systemd-timesyncd` printed `active` then `inactive`. Never assume; check.

1. DMZ rule at the top of the DMZ tab: Pass · UDP · DMZ subnets → DMZ address · port 123.
2. Added pfSense as a source: `echo "server 10.0.2.1 iburst prefer" | sudo tee /etc/chrony/sources.d/pfsense.sources`, then `sudo chronyc reload sources`.
3. **Problem:** pfSense (`_gateway`) was reachable (Reach 177) but never selected (`~` in `chronyc sources`). `sudo chronyc selectdata` showed Auth **N** with state **W** (waiting), while Ubuntu's default sources were **NTS** (authenticated) servers marked `prefer`. Those need TCP 4460 out, which the DMZ blocks.
4. **Fix:** the design says lab servers sync only from pfSense, so the Ubuntu NTS pool was disabled reversibly: `sudo mv .../ubuntu-ntp-pools.sources .../ubuntu-ntp-pools.sources.disabled`, then `chronyc reload sources` and `sudo chronyc makestep`.
5. **Result:** `^* _gateway`, Reach 377, Reference ID `0A000201` (10.0.2.1 in hex), stratum 4, leap status Normal, and an offset of 0.89 s corrected.

**Trade-off:** NTS (Network Time Security) authenticates time so it can't be spoofed. Inside this isolated lab, plain NTP from pfSense is acceptable. In production, run NTS internally or allow TCP 4460 out.

## Next

- [x] Reboot test passed: Wazuh came back synced (offset +885 µs) with no manual fixes
- [x] Ubuntu DMZ server synced (see above)
- [x] MGMT "to this firewall" rule tightened to DNS (53); `dig` still resolves

Evidence: [screenshots/phase-4](../screenshots/phase-4/)
