# Roadmap: from home lab to Cloud Security Engineer

**Goal:** Cloud Security Engineer, entering through a SOC or cloud SOC role.
**Primary cloud:** Microsoft Azure (Sentinel, Defender for Cloud, Entra ID). **Second cloud:** AWS.
**Pace assumed:** 15–20 hours a week. Months are counted from October 2026.

## Why this route

Cloud Security Engineers are usually hired from people who can already **detect and respond**, and who understand **networks, Linux and identity**. So the route builds those first, on hardware I own, then moves the same skills into the cloud:

```
Foundations → SOC skills (on-prem lab) → Virtualization & containers
           → Azure foundations → Cloud security engineering → Cloud detection & response
           → AWS (second cloud) → Specialisation (Kubernetes, DevSecOps, AI security)
```

## Stages

| Stage | Months | Focus | Lab phases | Cert | Status |
| --- | --- | --- | --- | --- | --- |
| **0. Foundations** | Done | Networking, Linux, security basics, segmented lab, SIEM | 1–4 | | ✅ Done |
| **1. SOC core** | 0–4 | Detection engineering on Linux, network and web logs, Windows and Active Directory | 5–6 | **CompTIA Security+** | 🔄 In progress |
| **2. Virtualization & containers** | 1–3 (alongside stage 1) | Hypervisors, virtual networking, Docker security, Kubernetes basics | 7 | | Next |
| **3. Azure foundations** | 3–6 | Cloud models, compute, storage, VNets, databases, queues, secure account setup | 8 | **AZ-900** | Planned |
| **4. Cloud security engineering** | 5–9 | IAM (Entra ID, RBAC, PIM), data security (Key Vault, encryption), secure network design, Terraform, Azure Policy, Defender for Cloud | 9 | **AZ-500** | Planned |
| **5. Cloud detection & response** | 8–12 | Log Analytics, Sentinel, KQL, hybrid SIEM, cloud incident response, automation | 10–11 | **SC-200** | Planned |
| **6. AWS** | 12–18 | VPC, IAM, S3, CloudTrail, GuardDuty, Security Hub; multi-cloud | 12 | AWS SAA → **AWS Security Specialty** | Planned |
| **7. Specialise** | 18+ | Kubernetes security, DevSecOps pipelines, AI security | 13 | CKS or similar (optional) | Planned |

## Career milestones

| When | Milestone |
| --- | --- |
| Month 3–4 | Start applying for SOC analyst roles (local, remote-friendly and international) |
| Month 4–8 | **First security role** (SOC analyst or junior security analyst) |
| Year 1–2 | Cloud SOC, detection engineering or junior cloud security work |
| Year 2–3 | **Cloud Security Engineer** |

Timelines are estimates. The job search runs in parallel with learning, not after it.

## What every stage produces

Every lab session follows the same loop and leaves evidence in this repo:

1. **Build** the component.
2. **Generate** activity (normal and malicious, in my own isolated lab only).
3. **Detect** it, and tune out noise.
4. **Investigate**, then **write it up** as a case study.
5. **Push** the notes, rules, code and redacted screenshots.

## Study guides

| Guide | Covers | Stage |
| --- | --- | --- |
| [1. Networking Fundamentals](notes/Networking_Fundamentals_Study_Guide.pdf) | OSI/TCP-IP, subnetting, ports, firewalls, NAT, DNS, DHCP, NTP, segmentation | 0–1 |
| [2. Virtualization & Containers](notes/Virtualization_and_Containers_Study_Guide.pdf) | Hypervisors, virtual hardware and networking, snapshots, Docker, container security, Kubernetes basics | 2 |
| [3. Cloud & Cloud Security Foundations](notes/Cloud_Security_Foundations_Study_Guide.pdf) | Service and deployment models, shared responsibility, compute, storage, VNets/VPCs, IAM, data security, monitoring, cloud IR (Azure first, AWS mapped) | 3–6 |

## The lab

See **[Lab v2: hybrid on-prem + cloud](docs/lab-v2.md)** for the full design and every phase, including what's already done.
