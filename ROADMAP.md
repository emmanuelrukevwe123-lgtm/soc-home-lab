# Roadmap: cloud security + blue team (26 Oct 2026 → 25 Apr 2027)

Six months to job-ready cloud security, without dropping SOC analysis and incident response. AWS first, Azure second, 20+ hours a week.

**The two documents I follow:**

| Document | What it is |
| --- | --- |
| [1. The Roadmap (PDF)](plan/Cloud_Security_Roadmap_2026-2027.pdf) | Strategy: where I am, where I'm going, the three tracks, month-by-month goals, the 13 projects, certs, checkpoints |
| [2. The Plan (PDF)](plan/Cloud_Security_Plan_2026-2027.pdf) | Execution: what to do every week for 26 weeks, step-by-step project briefs, templates, checklists, interview questions |

## The three tracks

- **A · Cloud engineering:** AWS, networking, IAM, Terraform, serverless, Azure basics
- **B · Cloud security:** secure design, data protection, posture, cloud detection, cloud IR, DevSecOps
- **C · Blue team:** SOC triage, SIEM, detection engineering, Windows/AD, phishing, web attacks, incident response

## Months

| Month | Dates | Focus | Projects | Cert |
| --- | --- | --- | --- | --- |
| 1 | 26 Oct – 22 Nov | Foundations + secure baseline | P1 AWS account baseline · P2 Network threat detection | |
| 2 | 23 Nov – 20 Dec | Workloads, data + web defence | P3 Secure website (S3 + CloudFront + WAF) · P4 Web attack detection · P5 Phishing investigation | Cloud Practitioner (optional) |
| 3 | 21 Dec – 17 Jan | Identity + Windows | P6 Secure API with Cognito · P7 Windows/AD SOC lab | |
| 4 | 18 Jan – 14 Feb | Detection + posture | P8 Hybrid cloud SIEM (CloudTrail → Wazuh) · P9 Posture assessment | **Security+** |
| 5 | 15 Feb – 14 Mar | Incident response | P10 GuardDuty → Lambda auto-response · P11 Cloud incident simulations | |
| 6 | 15 Mar – 25 Apr | DevSecOps, Azure + capstone | P12 Secure IaC pipeline · P13 Sentinel multi-cloud SIEM · ★ Capstone | **AWS Solutions Architect – Associate** |

## Reference reading

[Networking](notes/Networking_Fundamentals_Study_Guide.pdf) · [Virtualization & Containers](notes/Virtualization_and_Containers_Study_Guide.pdf) · [Cloud Security Foundations](notes/Cloud_Security_Foundations_Study_Guide.pdf) · [The Theory Book](notes/Cloud_Security_Theory_Book.pdf)

Lab design: [docs/lab-v2.md](docs/lab-v2.md). Only systems I own are ever attacked.
