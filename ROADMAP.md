# Roadmap: sprints to Cloud Security

**Phase A · Cloud engineering (26 Oct 2026 → 28 Feb 2027):** comfortable building on **AWS** (primary) and **Azure** (second), from code.
**Phase B · Cloud security (Mar → Dec 2027):** secure, monitor and respond to incidents in the cloud: identity, data, network, posture, detection and incident response.
**Target by December 2027:** ready for Cloud Security Engineer / Cloud Detection & Response roles.
**Degree:** BSc Cybersecurity, graduating early 2028.
**Pace:** 20+ hours a week.

> **Sprints, not a contract.** Each sprint has one goal and a short "done when" list. If a sprint runs over, carry the leftovers into the next one or drop a nice-to-have. The only fixed things are the order (build skills before security skills) and the habit (every sprint ends with something pushed to GitHub).

## The big picture

```
Phase A: cloud engineering (2-week sprints)
  S1  26 Oct – 8 Nov    Launch: SOC wrap-up + a secure AWS account
  S2  9 – 22 Nov        IAM + VPC by hand
  S3  23 Nov – 6 Dec    EC2, S3 + secure static site (CloudFront + WAF)
  S4  7 – 20 Dec        Terraform: everything as code     → AWS Cloud Practitioner (optional)
  S5  21 Dec – 3 Jan    Holiday sprint (lighter): catch-up + exam study
  S6  4 – 17 Jan        Serverless + databases + Cognito login
  S7  18 – 31 Jan       Scaling, containers + observability (CloudTrail → Wazuh)
  S8  1 – 14 Feb        Azure sprint: rebuild the basics in Azure  → AZ-900 (optional)
  S9  15 – 28 Feb       Phase A capstone: 3-tier app on AWS from code → Solutions Architect Associate (early Mar)

Phase B: cloud security (monthly sprints)
  B1  Mar   Identity security            B6  Aug   Incident response + automation
  B2  Apr   Data protection              B7  Sep   Container + serverless security
  B3  May   Network + app security       B8  Oct   Azure security + Sentinel → AWS Security Specialty
            → Security+                  B9  Nov   Phase B capstone
  B4  Jun   Posture + DevSecOps (lighter) B10 Dec   Job sprint + buffer
  B5  Jul   Threat detection
```

## Your week (about 21 hours)

| Block | Hours | What |
| --- | --- | --- |
| Build sessions | 8 | 4 × 2 h hands-on in AWS/Azure or the home lab |
| Study | 5 | Guides, docs, course videos (about 1 h on 5 days) |
| Exam practice | 2 | Practice questions for the current cert |
| SOC thread | 3 | One LetsDefend alert a day (20 min) + TryHackMe SOC Level 1 |
| Write-up + push | 2 | Notes, screenshots (redacted), GitHub |
| Sprint review | 1 | Quiz and explain-back session with Claude |

**One full rest day a week.** At 20+ hours, burning out costs more time than resting.

## The sprint routine

1. **Day 1, plan (30 min):** read the sprint in this roadmap and in [Guide 4](notes/Cloud_Engineering_Sprint_Workbook.pdf); write the goal and "done when" list at the top of the progress log.
2. **Build → break → fix → write up**, in small sessions.
3. **Last day, review:** push the write-up, then a quiz/explain-back session. Three-line retro in the progress log: what worked, what didn't, what to change.
4. **Cost check:** `terraform destroy` or delete everything, then check the billing page.

## Cloud cost rules (every sprint)

1. Root account: MFA on, then never used. Daily work uses an admin user through IAM Identity Center.
2. **Budget alert at $5** (and a zero-spend alert) before building anything.
3. Build with **Terraform** from S4 onward, so one command removes everything.
4. Watch the expensive services: **NAT gateways, load balancers, RDS, EKS, WAF, Front Door**. Run them only during a session, then destroy.
5. Start free trials (GuardDuty, Security Hub, Macie, Sentinel) **in the month you'll use them**, not before.
6. Never commit access keys. No vulnerable apps in the cloud.

AWS gives new accounts up to $200 in credits on a 6-month free plan. **Azure for Students** gives free credit with your school email. Save it for S8 and B8. Check the current offers before signing up.

## Phase A · Cloud engineering (Nov 2026 – Feb 2027)

| Sprint | Goal | Done when | Guides |
| --- | --- | --- | --- |
| **S1** · 26 Oct – 8 Nov | **Launch.** Finish the SOC essentials and set up a secure AWS account | pfSense logs in Wazuh + a scan-detection alert (Case 004); AWS account with root MFA, Identity Center admin user, budget alerts and CloudTrail; AWS CLI works from Kali | G1 subnetting refresher; G3 ch. 1–5; G4 S1 |
| **S2** · 9 – 22 Nov | **IAM + VPC by hand** | A custom VPC (2 public + 2 private subnets, route tables, internet gateway) built in the console and then with the CLI; an IAM role and a policy you wrote in JSON, explained line by line | G3 ch. 8, 10; G4 S2 |
| **S3** · 23 Nov – 6 Dec | **Compute + storage.** Video project 1 | EC2 in a private subnet reached with Session Manager (no SSH, no public IP); **secure static site: private S3 + CloudFront + WAF**; write-up | G3 ch. 6–7; G4 S3 |
| **S4** · 7 – 20 Dec | **Terraform: everything as code** | S2–S3 rebuilt in Terraform in `infra/aws/`, with modules, variables and remote state; `plan` → `apply` → `destroy` in one session. *Optional: AWS Cloud Practitioner (about 18 Dec)* | G3 ch. 12; G4 S4 |
| **S5** · 21 Dec – 3 Jan | **Holiday sprint (lighter, about 10 h a week)** | Catch up on anything unfinished; Solutions Architect study; tidy GitHub | G4 S5 |
| **S6** · 4 – 17 Jan | **Serverless + databases.** Video project 2 | Lambda + API Gateway + DynamoDB API in Terraform; RDS in a private subnet; **secure login with Cognito** (MFA on) in front of the API | G3 ch. 9; G4 S6 |
| **S7** · 18 – 31 Jan | **Scaling, containers + observability** | Load balancer + Auto Scaling group; a Docker image pushed to ECR and run on ECS Fargate; CloudWatch alarms; **CloudTrail → Wazuh**, with one detection fired from your own AWS activity (Case 005) | G2 ch. 8–10; G3 ch. 13; G4 S7 |
| **S8** · 1 – 14 Feb | **Azure sprint** | Azure for Students set up safely; Entra ID users and groups; VNet + NSG + VM + Storage built with Terraform (`azurerm`); an AWS ↔ Azure comparison note. *Optional: AZ-900* | G3 (Azure columns); G4 S8 |
| **S9** · 15 – 28 Feb | **Phase A capstone** | **3-tier web app on AWS from Terraform**: VPC, load balancer, app tier, private database, IAM roles, logging, an architecture diagram and a write-up. **Book Solutions Architect – Associate for early March** | G4 S9 |

**Phase A checkpoint, end of Feb:** you can design, build and destroy a 3-tier AWS app from code, explain every component and its security settings, and build the basics in Azure.

## Phase B · Cloud security (Mar – Dec 2027)

| Sprint | Goal | Key work | Done when |
| --- | --- | --- | --- |
| **B1 · Mar** | **Identity security** | IAM policy conditions, permission boundaries, IAM Access Analyzer; AWS Organizations + SCPs (multi-account); Identity Center; Entra ID Conditional Access and PIM (concepts plus trial) | A multi-account setup with SCPs; Access Analyzer findings fixed; write-up. *Security+ study begins.* |
| **B2 · Apr** | **Data protection** | KMS (keys, key policies, rotation), S3 security (Block Public Access, bucket policies, Object Lock), Secrets Manager, Macie, TLS with ACM; Azure Key Vault | Encrypted S3 + RDS with your own KMS keys; secrets out of code; Macie finding on test data |
| **B3 · May** | **Network + app security** | Security group / NACL design, VPC endpoints, VPC Flow Logs, WAF managed rules and rate limiting, Shield basics | Flow logs analysed; WAF blocks a test attack on your own site. **Security+ exam (end of May).** Start applying for junior cloud / SOC roles. |
| **B4 · Jun** *(lighter)* | **Posture + DevSecOps** | AWS Config rules, Security Hub + CIS benchmark, Prowler scan; Checkov in GitHub Actions on your Terraform; policy as code | The pipeline blocks an insecure Terraform change; Prowler report fixed down to accepted risks |
| **B5 · Jul** | **Threat detection** | CloudTrail deep dive, GuardDuty, Athena queries on logs, CloudWatch metric filters; Wazuh AWS detections as code | 5 cloud detections, each tested (true and false positive) and documented in `detections/aws/` |
| **B6 · Aug** | **Incident response + automation.** Video project 3 | IR playbooks; **GuardDuty → EventBridge → Lambda auto-response**; simulations: leaked access key, public bucket, compromised EC2 (isolate, snapshot, investigate); Detective | 3 incident write-ups (Cases) + one working auto-response |
| **B7 · Sep** | **Container + serverless security** | ECR image scanning, ECS task roles, Kubernetes security concepts (k3s at home), Lambda permissions and secrets | Hardened container deployment; image scan in the pipeline. *AWS Security Specialty study intense.* |
| **B8 · Oct** | **Azure security + Sentinel** | Defender for Cloud, Microsoft Sentinel (free trial) with the **AWS connector** (multi-cloud SIEM), KQL versions of your detections | Sentinel showing AWS + Azure events; 3 KQL rules. **AWS Certified Security – Specialty exam.** |
| **B9 · Nov** | **Phase B capstone** | Secure multi-account landing zone + 3-tier app + central logging + detections + auto-response; one simulated incident investigated end to end | Capstone repo + write-up + diagram + a short demo video |
| **B10 · Dec** | **Job sprint + buffer** | Portfolio polish, CV, LinkedIn posts, interview practice, applications; catch up on anything that slipped | Applications going out; interview bank complete |

## The SOC thread (runs alongside, about 3 h a week)

| When | SOC work |
| --- | --- |
| Nov – Feb | TryHackMe SOC Level 1; one LetsDefend alert a day; S1 wraps up Lab Phase 5 |
| Mar – Jun | Windows Server + Windows 11 in a new CORP zone (weekends); Sysmon; Windows detections (4625, 4720) |
| Jul – Dec | The SOC thread merges into cloud detection and response (B5, B6, B8) |

## Certs at a glance

| Cert | Aim | Why |
| --- | --- | --- |
| AWS Cloud Practitioner | Dec 2026 *(optional)* | Quick confidence boost; skip it if Solutions Architect study is on track |
| AZ-900 | Feb 2027 *(optional)* | Azure basics |
| **AWS Solutions Architect – Associate** | **Early Mar 2027** | Proves you're "comfortable building on AWS", the Phase A goal |
| **CompTIA Security+** | **May 2027** | The common HR filter for security roles |
| **AWS Certified Security – Specialty** | **Oct 2027** | The cloud security cert for the Phase B goal |
| AZ-500 or SC-200 | 2028 | Second cloud's security cert |

Check current exam versions and prices on the official sites before booking.

## Job search runs in parallel

| When | Action |
| --- | --- |
| From May 2027 | Apply for junior cloud, cloud support and SOC roles (Nigeria, remote, international). Post your sprint write-ups on LinkedIn. |
| Mid-2027 | **Aim:** first role in tech or security. Part-time, contract or internship experience counts. |
| From Oct 2027 | Apply for cloud security / cloud detection and response roles with the capstone and AWS Security Specialty |
| Early 2028 | Graduate, then apply internationally |

If a job arrives early, **take it**. Real experience is worth more than any sprint.

## The startup alongside (light touch)

Kept in a separate private plan. Phase A and B skills (cloud, identity, email security, monitoring) are the service skills. If time is tight, the career path comes first.

## Study guides

| Guide | Covers | Used in |
| --- | --- | --- |
| [1. Networking Fundamentals](notes/Networking_Fundamentals_Study_Guide.pdf) | OSI/TCP-IP, subnetting, ports, firewalls, NAT, DNS, DHCP, NTP | S1–S2 (refresher) |
| [2. Virtualization & Containers](notes/Virtualization_and_Containers_Study_Guide.pdf) | Hypervisors, snapshots, Docker, container security, Kubernetes | S3, S7, B7 |
| [3. Cloud & Cloud Security Foundations](notes/Cloud_Security_Foundations_Study_Guide.pdf) | Concepts with AWS and Azure side by side; Part C for small organisations | All sprints (chapter map inside) |
| [4. Cloud Engineering Sprint Workbook](notes/Cloud_Engineering_Sprint_Workbook.pdf) | **Step-by-step tasks for every Phase A sprint, plus the Phase B outline** | All sprints |

## The lab

Full design and phases: **[Lab v2: hybrid on-prem + cloud](docs/lab-v2.md)**.
