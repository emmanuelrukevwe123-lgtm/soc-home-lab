# Case 002: Detecting an SSH brute-force attack with a correlation rule

**Date:** 22 October 2026
**Systems:** Kali (attacker, 10.0.1.101) → Ubuntu DMZ server (agent `ubuntu-dmz`) → Wazuh 4.14.8
**Outcome:** 10 failed logins produced 10 low-severity alerts and **one level-10 brute-force alert**. A detection gap was identified, and a past false positive was confirmed and traced to duplicate logs.

## Summary

A single failed login is noise; many failures from one source in a short window is an attack. Wazuh models this with two kinds of rule:

| Type | Rule | Fires on | Level |
| --- | --- | --- | --- |
| Atomic | 5710: sshd: Attempt to login using a non-existent user | One event | 5 |
| Correlation (frequency) | 5712: sshd: brute force trying to get access to the system. Non-existent user. | A pattern of 5710 events | **10** |

## Reading the rule before testing it

| Field | Value | Meaning |
| --- | --- | --- |
| `if_matched_sid` | 5710 | Counts alerts from rule 5710 |
| `frequency` | 8 | Needs 8 of them… |
| `timeframe` | 120 | …within 120 seconds… |
| `same_source_ip` | true | …from the same source IP |
| `ignore` | 60 | After firing, stays quiet for 60 s to avoid flooding the queue |
| MITRE | T1110 Brute Force (Credential Access) | |

## Simulation

```bash
# From Kali: 10 SSH attempts with a non-existent user, no prompts
for i in $(seq 1 10); do ssh -o BatchMode=yes -o ConnectTimeout=5 fakeuser@10.0.2.10; done
```

The server only accepts key authentication, so every attempt is refused (`Permission denied (publickey)`), but each one is logged by sshd and collected by the agent from journald.

## Result

| Search | Result |
| --- | --- |
| `rule.id:5710` | About 10 alerts at level 5, one per attempt |
| `rule.id:5712` | **1 alert at level 10**: `data.srcip: 10.0.1.101`, `rule.firedtimes: 1` |

The 5712 alert carries `previous_output`, the individual attempts that made up the pattern, so an analyst sees the whole attack in one place.

## Why two rules instead of one high-severity rule?

**Alert fatigue.** Single failed logins happen constantly (typos, expired passwords, old scripts). Making each one high severity would bury analysts. The atomic rule stays low severity for context and hunting. The correlation rule raises a high-severity alert only when the *pattern* appears, which gives much higher confidence that it's malicious.

## Findings

1. **Detection gap: distributed attacks.** `same_source_ip: true` means an attacker who spreads attempts across many IPs, staying under 8 per IP, would not trigger 5712. The same goes for **password spraying** (T1110.003): one password against many accounts, slowly. *Follow-up:* write and test a custom rule that counts failures per target account or across sources.
2. **Confirmed false positive caused by duplicate logs.** A second 5712 alert fired at 01:13 the previous night, during the duplicate-log testing (Case 001 correction). Only a few attempts were made then. Its `previous_output` showed **the same attempts in both log formats**, journald (`Oct 22 00:13:49 …`) and auth.log (`2026-10-22T00:13:49.27…`). Each attempt was counted twice, which pushed the count past the threshold of 8 and fired a brute-force alert that a real count would not have triggered. **Root cause:** a duplicate log source. **Fix:** the duplicate was removed in Session 3, and the test in this case (10 attempts → 1 correct 5712) was run afterwards. **Lesson:** duplicate log sources don't just add noise; they inflate correlation counts and create false positives.

## Triage playbook (first five minutes on a 5712 alert)

1. **Source IP:** internal or external? Internal means a compromised host or an insider, so investigate that machine as well.
2. **Reputation:** for external IPs, check AbuseIPDB or VirusTotal and the firewall logs for other activity.
3. **Usernames tried:** non-existent names mean guessing; real account names mean the attacker has done reconnaissance.
4. **Success?** Search for a successful login from the same IP after the failures. **That's the most important question.** A success after failures is a likely compromise and needs immediate escalation.
5. **Scope:** what else did this IP touch (other hosts, ports, web apps) in the same time window?
6. **Target value:** how critical is the attacked server?
7. **Act and document:** record findings in the ticket. Recommend containment (block the IP at the firewall) or monitoring, and escalate according to severity.

## Lessons

- Read and understand a rule before testing it.
- Severity should reflect confidence; correlation raises confidence.
- Every rule has blind spots. Reading `same_source_ip` revealed one.

## Evidence

| Screenshot | Shows |
| --- | --- |
| [Rule 5712 definition](../screenshots/phase-5/01-rule-5712-definition.png) | Frequency 8, timeframe 120, same source IP |
| [Ten 5710 alerts](../screenshots/phase-5/02-ten-5710-alerts.png) | One low-severity alert per attempt |
| [The 5712 alert](../screenshots/phase-5/03-rule-5712-alert-level10.png) | Level 10, source 10.0.1.101, `previous_output` |
