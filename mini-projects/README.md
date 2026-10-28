# Mini-projects: one every 1–2 days

Small, finished builds (2–5 hours each) that make the fundamentals stick: systems, Linux, networking, security, containers, cloud, DevOps and blue team. Each one ends with something pushed, a results table and "explain it back" questions. The larger portfolio projects (P1–P13 in my plan) continue alongside on project days.

| # | Mini-project | Fundamentals | Status |
| --- | --- | --- | --- |
| 01 | [Fundamentals tour of my home lab](01-home-lab-fundamentals/): every topic in stages 1–4, learned on the machines I already run · **2 days** | Systems, Linux, networking, security fundamentals | 🔄 28–29 Oct |
| 02 | Linux log detective: a Bash script that reports failed SSH logins, top source IPs and successes after failures | Linux, Bash, logs, blue team | Next |
| 03 | Subnet calculator + lab inventory: Python (`ipaddress`) plus nmap XML parsed into a Markdown asset list | Networking, Python | Planned |
| 04 | Linux hardening audit with Lynis: score the Ubuntu server, fix the top findings, re-score | Linux, systems, security | Planned |
| 05 | Firewall rules as tests: an allow/deny matrix for the pfSense zones, checked by a script | Networking, security testing | Planned |
| 06 | Container image scanning with Trivy, then add it to CI | Containers, DevSecOps | Planned |
| 07 | DNS deep dive: `dig`, pfSense resolver logs, spotting suspicious lookups | Networking, blue team | Planned |
| 08 | AWS inventory script (Python + boto3): list resources in every region and flag risky ones | Cloud, Python, security | Planned |
| 09 | IAM policy lab: five policies tested with the IAM policy simulator | Cloud identity | Planned |
| 10 | Backup and restore drill for the Wazuh server, with a timed restore | Systems, resilience | Planned |
| 11 | Ansible: harden the Ubuntu server from code | DevOps, configuration management | Planned |
| 12 | Metrics with Prometheus and Grafana for the lab servers | Observability | Planned |

**Rules:** finish small, push the same day, redact screenshots, only test systems I own.

## Extensions (optional, later)

| # | Extension | Fundamentals |
| --- | --- | --- |
| E1 | [Hardened, monitored web service](e1-hardened-web-service/): Docker, HTTPS from my own CA, login, pfSense, Wazuh, CI | Containers, TLS, DevOps |
