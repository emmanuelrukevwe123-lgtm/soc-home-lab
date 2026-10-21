# Case 001: SSH attack alerts that were generated but invisible

**Date:** 14 and 20 October 2026
**Systems:** Ubuntu DMZ server (agent `ubuntu-dmz`), Wazuh 4.14.8 server
**Outcome:** Detection working end to end. Four stacked causes were found and fixed.

## Summary

I simulated SSH login attempts with an invalid user from Kali (10.0.1.101) against the DMZ server. Ubuntu logged every attempt, but no alert appeared in the Wazuh dashboard. I traced the log through every hop of the SIEM pipeline. The final root cause was the SIEM server's clock running 1 hour ahead, which stamped every alert in the future and hid it from time-based searches.

## Attack simulation

```bash
# From Kali, repeated 3 times
ssh fakeuser@10.0.2.10
```

Expected detection: Wazuh rule **5710**, "sshd: Attempt to login using a non-existent user". Level 5, MITRE **T1110.001** Password Guessing (tactic: Credential Access).

## The pipeline I investigated

```
auth.log → agent collects → agent sends (TCP 1514) → manager rules → alerts.json
        → Filebeat → indexer (daily index) → dashboard search
```

## Investigation timeline

| # | Hypothesis | Test | Result |
| --- | --- | --- | --- |
| 1 | Ubuntu 26.04 logs as `sshd-session`, so Wazuh's SSH decoder doesn't match | Pasted the raw log line into Wazuh's **Ruleset Test** | **Disproved.** The `sshd` decoder extracted `srcip` and `srcuser`, and rule 5710 fired. No custom rule needed. |
| 2 | The agent isn't reading the log file | `grep "auth.log" /var/ossec/logs/ossec.log` | **Confirmed.** The agent monitored journald only. Added a `<localfile>` entry for `/var/log/auth.log`. |
| 3 | The dashboard can't reach the manager ("Check API connection") | `systemctl is-active wazuh-manager` | **Confirmed.** The manager had crashed at boot. Restarted it and verified the API was listening on port 55000. |
| 4 | The agent isn't connected | Read `wazuh-agentd.state` | Ruled out: `status='connected'`, recent `last_ack`. |
| 5 | The manager isn't generating alerts | `grep fakeuser /var/ossec/logs/alerts/alerts.log` and `alerts.json` | Ruled out: alerts present (65 matching lines in alerts.json). |
| 6 | Filebeat can't ship to the indexer | `filebeat test output` | Ruled out: every stage OK. |
| 7 | The indexer isn't storing alerts | Dev Tools: `GET _cat/indices/wazuh-alerts-*?v` | Ruled out: today's index was green with 258 documents. |
| 8 | Alerts are stored under the wrong time | `timedatectl` on the Wazuh server | **Root cause.** The clock read 03:36 UTC when real UTC was 02:36. Every alert was stamped 1 hour in the future, so "Last 1 hour" never included them. |

## Root causes

1. **Collection gap:** the agent only read journald, not `/var/log/auth.log`.
2. **Service failure:** wazuh-manager failed at boot.
3. **Clock skew (main cause):** the Wazuh VM clock was exactly 1 hour ahead. Windows keeps the hardware clock in local time (Lagos, UTC+1), and the Linux VM read it as UTC.
4. **Why it never self-corrected:** NTP (UDP 123) is blocked by my own MGMT firewall rules, so the VM couldn't sync time.

## Fixes

```bash
# Agent (Ubuntu): also collect auth.log
<localfile>
  <log_format>syslog</log_format>
  <location>/var/log/auth.log</location>
</localfile>

# Wazuh server: correct the clock, restart the manager
sudo date -s "1 hour ago"
sudo systemctl restart wazuh-manager
```

**Verification:** new attempts from Kali appeared as rule 5710 alerts with `data.srcip: 10.0.1.101` and `data.srcuser: fakeuser`.

## Lessons learned

- **Test hypotheses before changing anything.** My first theory (a decoder gap) was wrong, and one Ruleset Test saved me from writing an unnecessary custom rule.
- **Trace the pipeline hop by hop.** Each check either cleared a hop or found the fault.
- **Time is a security control.** Skewed clocks break correlation, time-window rules and evidence. Kerberos fails beyond 5 minutes of skew, and PCI DSS 10.6 requires time sync.
- **UTC is not local time.** The clock "matched my phone", and that was exactly the problem.
- **Read the prompt.** Twice I ran server commands on the wrong machine. `user@hostname` tells you where you are.

## Follow-up actions

- [x] Make pfSense the lab's NTP server; Wazuh now syncs from it ([Phase 4.1](../docs/phase-4-ntp-time-sync.md)). DMZ server still to do.
- [ ] Remove duplicate alerts (journald and auth.log both report the same event)
- [ ] Make wazuh-manager wait for the indexer at boot

## Evidence

| Screenshot | Shows |
| --- | --- |
| [Ruleset Test](../screenshots/phase-3/07-ruleset-test-5710.png) | Rule 5710 matches the `sshd-session` line |
| [Agent connected + 7-day events](../screenshots/phase-3/08-agent-connected-events.png) | Agent connected; no events today |
| [Filebeat test](../screenshots/phase-3/09-filebeat-test.png) | Filebeat reaches the indexer |
| [Indexer indices](../screenshots/phase-3/10-indexer-indices.png) | Today's index holds 258 alerts |
| [Clock 1 hour ahead](../screenshots/phase-3/13-clock-ahead.png) | `timedatectl` reading 03:36 UTC at 02:36 real UTC |
| [Rule 5710](../screenshots/phase-3/11-rule-5710.png) | Rule definition, compliance and MITRE mapping |
