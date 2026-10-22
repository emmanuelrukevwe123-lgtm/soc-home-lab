# Case 003: A custom rule that catches low-and-slow SSH guessing

**Date:** 22 October 2026
**Type:** Detection engineering (find a gap, write a rule, prove it)
**Outcome:** The built-in brute-force rule (5712) was evaded by a slowed-down attack. My custom rule (100100) caught it at level 10.

## 1. Hypothesis: the gap

Built-in rule 5712 fires on **8 invalid-user attempts from the same IP within 120 s** ([Case 002](002-ssh-brute-force-detection.md)). An attacker who knows this can stay under it by:

- **Slowing down:** never 8 within any 2-minute window.
- **Spreading out:** a few attempts from each of many IPs (`same_source_ip` ignores them), as in password spraying (T1110.003).

## 2. The rule

[`detections/wazuh/local_rules.xml`](../detections/wazuh/local_rules.xml)

```xml
<rule id="100100" level="10" frequency="12" timeframe="300" ignore="120">
  <if_matched_sid>5710</if_matched_sid>
  <description>sshd: low-and-slow or distributed SSH guessing - 12+ invalid-user attempts in 5 minutes (any source)</description>
  <mitre><id>T1110</id></mitre>
</rule>
```

| Design choice | Why |
| --- | --- |
| A 5-minute window (vs 2) | Catches attackers who pace their attempts |
| No `same_source_ip` | Catches attempts spread across many IPs |
| Threshold 12 (vs 8) | The longer window needs a higher bar, so normal mistakes don't trigger it |
| `ignore="120"` | One attack produces one alert, not a flood |
| ID 100100 | The custom range (100000+) never clashes with Wazuh's built-in rules |

## 3. True-positive test: a low-and-slow attack

```bash
# 7 attempts, pause just over 5712's 120 s window, 7 more
for i in $(seq 1 7); do ssh -o BatchMode=yes -o ConnectTimeout=5 fakeuser@10.0.2.10; done; \
echo "Pausing 130 seconds..."; sleep 130; \
for i in $(seq 1 7); do ssh -o BatchMode=yes -o ConnectTimeout=5 fakeuser@10.0.2.10; done
```

| Search (last 15 min) | Result |
| --- | --- |
| `rule.id:5710` | 13 alerts in two bursts (16:44:29 and 16:46:41) |
| `rule.id:5712` (built-in) | **No results: evaded** |
| `rule.id:100100` (custom) | **1 alert, level 10** at 16:46:41, `data.srcip 10.0.1.101`, `previous_output` listing the attempts |

**Note:** 14 attempts were sent but 13 were logged. *Open question:* one connection probably never reached the login stage. To check, count the `Permission denied` lines on Kali.

## 4. False-positive test: normal mistakes

Three invalid-user attempts (a user mistyping), sent more than 5 minutes after the attack. **Expected and observed:** 3 new 5710 alerts, and no new 100100 or 5712 alert. *(To be confirmed with a screenshot.)*

## 5. Limitations and next steps

- **Lab limitation:** both bursts came from one IP, so this proves the *slow* evasion. The *distributed* case (many IPs) still needs testing from a second attacking machine.
- **Tuning:** in production, a busy server might see 12 honest failures in 5 minutes. Baseline normal failure rates before deploying, then tune the threshold or limit it to sensitive servers.
- **Next rule ideas:** many *different* usernames from one source (username enumeration), and a successful login shortly after many failures (likely compromise).

## Lessons

- Detection engineering is a loop: **hypothesis → rule → true-positive test → false-positive test → document.**
- Reading a rule's conditions reveals how attackers evade it.
- Every threshold trades missed attacks against false alarms. State the trade-off.

## Evidence

| Screenshot | Shows |
| --- | --- |
| [Rule loaded](../screenshots/phase-5/04-rule-100100-loaded.png) | 100100 in `local_rules.xml`, level 10 |
| [Two bursts](../screenshots/phase-5/05-low-and-slow-two-bursts.png) | 5710 alerts at 16:44 and 16:46 |
| [5712 evaded](../screenshots/phase-5/06-rule-5712-evaded.png) | No built-in brute-force alert |
| [100100 fired](../screenshots/phase-5/07-rule-100100-fired.png) | The custom rule at level 10 |
| [Alert detail](../screenshots/phase-5/08-rule-100100-alert-detail.png) | Source IP, frequency 12, `previous_output` |
