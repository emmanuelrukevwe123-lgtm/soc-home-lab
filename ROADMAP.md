# Roadmap: 15 months to Cloud Detection & Response

**Target (by December 2027):** working in, or fully ready for, **Cloud Detection & Response (CDR)**: a cloud SOC analyst, cloud detection engineer or cloud incident responder role, on the way to Cloud Security Engineer.
**Window:** November 2026 → December 2027 (about 15 months).
**Primary cloud:** Azure (Sentinel, Defender for Cloud, Entra ID). **AWS:** concepts only for now; hands-on after the target.
**Degree:** BSc Cybersecurity, graduating early 2028. The CDR target lands just before graduation, so I finish with a degree, certs, a portfolio and (ideally) work experience at the same time.

> **This is a guide, not a contract.** Dates are aims. If a quarter slips, push the next one back or drop a "nice to have". The only fixed things are the order (foundations before cloud) and the habit (a little progress every week, written up).

## How the 15 months fit together

```
Nov 2026 ─ Feb 2027   Q1  SOC core on-prem          → Security+
Mar 2027 ─ May 2027   Q2  Windows/AD + Azure basics → AZ-900   → start applying for SOC roles
Jun 2027 ─ Aug 2027   Q3  Cloud security in Azure   → SC-200 (study)
Sep 2027 ─ Dec 2027   Q4  Cloud detection & response → SC-200 ✔ → apply for cloud SOC / CDR roles
```

**Why SC-200 before AZ-500:** SC-200 (Security Operations Analyst) is the cert closest to detection and response: Sentinel, Defender and KQL. AZ-500 (cloud security engineering) is the next step *after* the target, and the start of 2028 if 2027 runs long.

## Pace

- **Aim:** about 12–15 hours a week, typically 2 lab sessions, 2–3 study sessions and 1 practice session (TryHackMe or LetsDefend).
- **Busy week:** do one thing, even 30 minutes of a guide. Consistency beats intensity.
- **Built-in slack:** December 2026 and June 2027 are lighter months on purpose, for catching up, holidays or exam retakes.

## Quarter by quarter

### Q1 · Nov 2026 – Feb 2027 · SOC core (on-prem)
| Must have | Nice to have |
| --- | --- |
| pfSense logs → Wazuh; network scan detection | Username-enumeration rule |
| Failures-then-success SSH rule | Web attack detection from DVWA/Juice Shop logs |
| Windows Server + Windows 11 in a new CORP zone, Sysmon, Wazuh agents | A second Linux distro (Rocky) |
| Guides 1 and 2 finished, with quick checks | Linux+ study |
| **Security+ (aim: February)** | |

**Done enough when:** 5+ case studies on GitHub, Windows logs flowing into Wazuh, and Security+ booked or passed.

### Q2 · Mar – May 2027 · Windows/AD detections + Azure foundations
| Must have | Nice to have |
| --- | --- |
| AD detections: failed logons (4625), new accounts (4720), group changes, suspicious PowerShell | Wazuh vulnerability detection and SCA report |
| Free Azure account, secured (MFA, budget alerts, separate admin) | Backup and tested restore |
| Guide 3 Part A (cloud foundations) | Monthly security report template |
| First Terraform: a VNet with subnets and NSGs, built and destroyed (Terraform is the core Cloud Security Engineer skill, so keep using it every quarter) | |
| **AZ-900 (aim: April)** | |
| **Start applying for SOC analyst roles (from March)** | |

**Done enough when:** you can build and destroy a small Azure network from code, explain the shared responsibility model, and have applications going out.

### Q3 · Jun – Aug 2027 · Cloud security in Azure
| Must have | Nice to have |
| --- | --- |
| Hub-and-spoke landing zone with Terraform (Bastion, private endpoints, no public IPs) | App Service and Azure SQL behind private endpoints |
| Entra ID: users, groups, RBAC least privilege, managed identities | Conditional Access and PIM (trial licences) |
| Key Vault; encryption at rest and in transit | Azure Policy denying public storage |
| Defender for Cloud: review and fix recommendations | |
| Guide 3 Part B (cloud security) | |
| **SC-200 study begins** (Microsoft Learn path) | |

**Done enough when:** a secure Azure environment exists as code in the repo, with a short write-up of each control and why it's there.

### Q4 · Sep – Dec 2027 · Cloud Detection & Response (the target)
| Must have | Nice to have |
| --- | --- |
| Log Analytics + **Microsoft Sentinel**, with Entra ID, Azure Activity and Defender connectors | A Sentinel playbook (Logic App) that auto-responds |
| **Hybrid SIEM:** on-prem Ubuntu onboarded with Azure Arc into Sentinel | A KQL detections repo with tests |
| KQL versions of your Wazuh rules (5712, 100100) plus sign-in detections | AWS concepts: CloudTrail, GuardDuty (from Guide 3) |
| Cloud incident simulations: leaked credential, exposed storage, compromised VM | |
| **Capstone case study:** one incident investigated end to end across on-prem and Azure | |
| **SC-200 (aim: October/November)** | |
| **Apply for cloud SOC / detection / CDR roles** | |

**Done enough when:** Sentinel watches both environments, you've worked three simulated cloud incidents with write-ups, and SC-200 is passed.

## Certs at a glance

| Cert | Aim | Why |
| --- | --- | --- |
| CompTIA Security+ | Feb 2027 | The widely recognised HR filter for first security roles |
| AZ-900 | Apr 2027 | A quick, cheap Azure foundation; confidence |
| **SC-200** | Oct–Nov 2027 | **The CDR cert**: Sentinel, Defender, KQL |
| AZ-500 | 2028 | Next step toward Cloud Security Engineer |
| AWS certs | 2028 | Second cloud, after the target |

Check exam versions and prices on the official sites before booking.

## Job search runs in parallel

| When | Action |
| --- | --- |
| From Mar 2027 | Apply for SOC analyst roles (local, remote-friendly, international). Keep posting on LinkedIn. |
| Mid-2027 | **Aim:** first security role. Even part-time, contract or internship experience counts. |
| From Oct 2027 | Apply for cloud SOC, detection engineering and CDR roles, using the capstone and SC-200 |
| Early 2028 | Graduate. Apply for international roles (UK and Europe) that sponsor visas, as a graduate with certs, a portfolio and experience |
| 2028 | AZ-500 + AWS; move toward **Cloud Security Engineer** (Terraform, policy as code, posture management) |

If a SOC job arrives early, **take it**. The plan slows down, but real experience is worth more than any quarter of lab work.

## The startup alongside (light touch)

Kept in a separate private plan. The lab already builds the service skills (monitoring, reporting, email security, backups). Suggested touchpoints: free assessments in Q2, one pilot in Q3. If time is tight, the career path comes first.

## Every session leaves evidence

Build → generate activity (my own lab only) → detect → investigate → write up → push to GitHub.

## Study guides

| Guide | Covers | Quarter |
| --- | --- | --- |
| [1. Networking Fundamentals](notes/Networking_Fundamentals_Study_Guide.pdf) | OSI/TCP-IP, subnetting, ports, firewalls, NAT, DNS, DHCP, NTP, segmentation | Q1 |
| [2. Virtualization & Containers](notes/Virtualization_and_Containers_Study_Guide.pdf) | Hypervisors, virtual networking, snapshots and backups, Docker, container security, Kubernetes | Q1 |
| [3. Cloud & Cloud Security Foundations](notes/Cloud_Security_Foundations_Study_Guide.pdf) | Part A (Q2), Part B (Q3), Part C (alongside, for the startup) | Q2–Q4 |

## The lab

Full design and phases: **[Lab v2: hybrid on-prem + cloud](docs/lab-v2.md)**. Phase-to-quarter map:

| Quarter | Lab phases |
| --- | --- |
| Q1 | 5 (finish), 6 (start), 7 (light) |
| Q2 | 6 (finish), 8 (start) |
| Q3 | 8–9 |
| Q4 | 10–11, capstone |
| 2028 | 12 (AWS), 13 (AI security) |
