# Phase 1: Segmented network with pfSense

**Result:** three isolated zones with least-privilege rules, tested from each side.

## What I built

1. Installed pfSense CE with four interfaces: WAN (em0, VMware NAT), LAN (em1), DMZ (em2) and MGMT (em3).
2. Gave each zone its own /24 and gateway: 10.0.1.1, 10.0.2.1, 10.0.3.1.
3. Created aliases so rules read like policy (see [architecture](architecture.md#firewall-aliases)).
4. Replaced pfSense's default "allow LAN to any" rule with per-zone rules ending in a logged block of `Lab_Nets`.
5. Left outbound NAT on automatic so all zones can reach the internet for updates.

## Testing

| Test | Expected | Result |
| --- | --- | --- |
| Kali → internet | Works | Works |
| DMZ → pfSense web GUI | Blocked | **Initially reachable.** The DMZ DNS rule had port "any". Fixed it to port 53, then the connection timed out. |
| DMZ → LAN | Blocked and logged | Blocked |
| MGMT → gateway ping | Fails (no ICMP rule) | Fails, as designed |

## Concepts

- **Stateful, first-match rules:** read top to bottom, the first match wins, and replies are allowed automatically.
- **Rules apply where traffic enters:** traffic from Kali is judged by the LAN tab, and traffic from Ubuntu by the DMZ tab.
- **Default deny:** anything not explicitly allowed is dropped.
- **Aliases:** one place to change an IP or port group, used by many rules.

## Lesson

Write a test for every rule you write. The DMZ → GUI leak would have stayed hidden without one.

Evidence: [screenshots/phase-1](../screenshots/phase-1/)
