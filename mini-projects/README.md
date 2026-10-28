# Mini-projects: one every 1–2 days

Small, finished builds (2–5 hours each) that make the fundamentals stick: systems, Linux, networking, security, containers, cloud, DevOps and blue team. Each one ends with something pushed, a results table and "explain it back" questions. The larger portfolio projects (P1–P13 in my plan) continue alongside on project days.

| # | Mini-project | Fundamentals | Status |
| --- | --- | --- | --- |
| 01 | [Hardened, monitored web service](01-hardened-web-service/) (Docker + pfSense + Wazuh + CI) | Linux, containers, networking, security, DevOps, blue team | 🔄 28 Oct |
| 02 | Linux log detective: a Bash script that reports failed SSH logins, top source IPs and successes after failures | Linux, Bash, logs, blue team | Next |
| 03 | Subnet calculator + lab inventory: Python (`ipaddress`) plus nmap XML parsed into a Markdown asset list | Networking, Python | Planned |
| 04 | Build your own certificate authority with OpenSSL; HTTPS on mini-01; inspect the TLS handshake in Wireshark | Cryptography, PKI, TLS | Planned |
| 05 | Firewall rules as tests: an allow/deny matrix for the pfSense zones, checked by a script | Networking, security testing | Planned |
| 06 | Container image scanning with Trivy, then add it to CI | Containers, DevSecOps | Planned |
| 07 | DNS deep dive: `dig`, pfSense resolver logs, spotting suspicious lookups | Networking, blue team | Planned |
| 08 | AWS inventory script (Python + boto3): list resources in every region and flag risky ones | Cloud, Python, security | Planned |
| 09 | IAM policy lab: five policies tested with the IAM policy simulator | Cloud identity | Planned |
| 10 | Backup and restore drill for the Wazuh server, with a timed restore | Systems, resilience | Planned |
| 11 | Ansible: harden the Ubuntu server from code | DevOps, configuration management | Planned |
| 12 | Metrics with Prometheus and Grafana for mini-01 | Observability | Planned |

**Rules:** finish small, push the same day, redact screenshots, only test systems I own.
