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

## Next

- [ ] Reboot test: Wazuh should come back synced with no manual fixes
- [ ] Same change for the Ubuntu DMZ server (check whether it uses chrony or timesyncd), plus a DMZ rule for UDP 123 to the DMZ address
- [ ] Tighten the MGMT "to this firewall" rule to port 53

Evidence: [screenshots/phase-4](../screenshots/phase-4/)
