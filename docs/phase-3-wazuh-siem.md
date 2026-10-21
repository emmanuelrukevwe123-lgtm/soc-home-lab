# Phase 3: Wazuh SIEM and first detection

**Result:** Wazuh 4.14.8 in the management zone, with an agent on the DMZ server and SSH attacks from Kali detected as rule 5710.

## Server

- Ubuntu Server 24.04.5 (Wazuh doesn't list 26.04 as supported yet), 8 GB RAM, 4 CPUs, 50 GB disk, static IP 10.0.3.10 on the MGMT segment.
- All-in-one install:

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

- Dashboard at `https://10.0.3.10`, reached from Kali (the LAN rule allows 443 to Wazuh).

**Mistakes I hit:** `curl -s0` (zero) printed the script instead of saving it, because the flag is a capital letter O. Typos like `system` and `wwazuh-indexer` made services look "inactive". Lesson: use Tab completion.

## How Wazuh fits together

| Component | Job | Port |
| --- | --- | --- |
| Agent | Collects logs on the monitored host | Sends to 1514; enrols on 1515 |
| Manager | Decodes logs, runs rules, writes alerts.json, serves an API | 1514, 1515, API 55000 |
| Filebeat | Ships alerts.json to the indexer | Talks to 9200 |
| Indexer | Stores alerts, one index per day | 9200 |
| Dashboard | The web interface | 443 |

## Agent on the DMZ server

Installed from the dashboard's "Deploy new agent" wizard:

```bash
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.8-1_amd64.deb
sudo WAZUH_MANAGER='10.0.3.10' WAZUH_AGENT_NAME='ubuntu-dmz' dpkg -i ./wazuh-agent_4.14.8-1_amd64.deb
sudo systemctl daemon-reload && sudo systemctl enable --now wazuh-agent
```

Then I added `/var/log/auth.log` to the agent's collection (see Case 001).

## First detection

```bash
ssh fakeuser@10.0.2.10   # from Kali, 3 times
```

| Field | Value |
| --- | --- |
| Rule | 5710: sshd: Attempt to login using a non-existent user |
| Level | 5 |
| Source IP | 10.0.1.101 |
| User | fakeuser |
| MITRE | T1110.001 Password Guessing (Credential Access) |
| Compliance | PCI DSS 10.2.4, 10.2.5; NIST 800-53 AU.14, AC.7; GDPR IV_35.7.d |

Getting this to show took a full investigation: [Case 001](../case-studies/001-invisible-ssh-alerts.md).

## Rule vs alert

A **rule** is the detection logic. Rule 5710's parent is 5700 (SSH messages), and it matches `illegal user|invalid user`. An **alert** is one event that matched it, carrying the evidence: who, from where, and when.

Evidence: [screenshots/phase-3](../screenshots/phase-3/)
