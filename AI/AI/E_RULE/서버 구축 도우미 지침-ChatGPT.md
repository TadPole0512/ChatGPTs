# 🚧 Pre-Brief SOP for Accurate Server-Build Answers v1.0

> Purpose: A **Standard Operating Procedure (SOP)** that fixes what must be prepared in advance so that both AI and humans can give **precise, one-shot answers** to server-build questions.

---

## 🧭 A. Principles & Framing

* Overview

  * ▷ Background

    * Server builds have many variables (cloud/on-prem, network, security, OS, storage, availability), which makes **questions ambiguous**.
    * To get accurate answers, **standardize a “Pre-brief”** that is filled out **before** asking the question.
  * ▷ Goals

    * Prepare a **pre-brief template + decision tree + verification scripts** up front.
    * **Codify constraints and criteria** so that “different people still reach the same conclusion.”

> **Key takeaway:** A **pre-brief standard + decision tree + verification checklist** drives 80% of answer accuracy.

---

## 🗂 B. Pre-brief Template (copy-paste and fill)

* How to use

  * ▷ Preparation

    * → Always paste the following template **at the top of your question**.
  * ▷ Procedure

    * → Fill in the blanks → Mark unclear items as “TBD-<date>” → Write the question body.

```md
# [Server Pre-brief]

1) Purpose / Workload
- Use case: (Web/API/Batch/DB/Cache/ML serving, etc.)
- Scale: concurrent users X, RPS X, throughput X MB/s
- Availability: (single/HA/multi-AZ)  Target availability (e.g., 99.9%)

2) Platform / Deployment
- Runtime: (On-prem/VM/Container/K8s/Serverless)
- Cloud: (AWS/Azure/GCP)  Region: (ap-…)
- OS: (Ubuntu 22.04 / Rocky 9 / Windows Server 2022)  Arch: (x86/ARM)

3) Network / Security
- VPC/VNet: (CIDR)  Subnets: (public/private)  NAT: (Y/N)
- Port policy (ingress/egress): (list)
- Auth: (Local/AD/SSO/IMDSv2/SSM)  Key mgmt: (KMS/KeyVault/CloudKMS)

4) Data / Storage
- Type: (Block/File/Object/DB)  Capacity: X GB  IOPS/Throughput: X
- Backup: frequency X, retention X  RPO: X, RTO: X

5) Operations / Observability
- Monitoring: (CloudWatch/Prometheus/Datadog, etc.)
- Logging: (collection path/retention/PII masking)
- Patching/Vulnerabilities: (cadence/approval process)

6) Constraints / Policies
- Budget cap: X per month  Licensing: (e.g., Windows CAL)
- Compliance/Security baseline: (CIS level, encryption mandates, etc.)

7) Deliverables
- IaC: (Terraform/Ansible?)  Naming/Tagging: (rules)
- Docs: (diagram/runbook/checklist)

[Question] (List 1–3 concrete questions here)
```

> **Key takeaway:** Attaching a **Pre-brief** before asking dramatically boosts answer quality.

---

## 🌳 C. Architecture Decision Tree (three primary routes)

* Overview

  * ▷ Options

    * A) **Managed/PaaS first**: lower ops burden, faster time-to-value
    * B) **IaaS + IaC standard**: higher flexibility/portability
    * C) **On-prem/VM**: data sovereignty/special requirements
* Comparison

| Item                | Managed (PaaS)   | IaaS + IaC (EC2/VM)    | On-prem/VM              |
| ------------------- | ---------------- | ---------------------- | ----------------------- |
| Build speed         | Very fast        | Medium                 | Slow                    |
| Ops burden          | Minimal          | Moderate               | High                    |
| Customizing         | Limited          | High                   | Very high               |
| Cost predictability | Easy             | Medium                 | Hard (capex)            |
| Best fit            | Standard Web/API | Specialized middleware | Regulatory/dedicated HW |

> **Key takeaway:** “Prefer managed; if not feasible, IaaS+IaC; on-prem only when unavoidable.”

---

## 🧾 D. Naming, Tagging & Repo Layout Standards (fix these)

* How to use

  * ▷ Preparation

    * → Without naming/tagging, cost, security, and operations will crumble.
  * ▷ Rules

    * → `proj-env-role-region-seq` (e.g., `acme-prod-web-apne2-01`)
    * → Tags: `Project, Env, Owner, CostCenter, DataClass(PII/Non-PII), Backup(RPO/RTO)`
    * → Repository layout

```
infra/
 ├─ envs/
 │   ├─ prod/
 │   └─ dev/
 ├─ modules/
 │   ├─ network/
 │   ├─ compute/
 │   └─ observability/
 └─ runbooks/
```

> **Key takeaway:** Good **names & tags** are the lifeline of discoverability, automation, billing, and audit.

---

## 🔐 E. Security, Network & OS Baseline (non-negotiables)

* Overview

  * ▷ Security baseline

    * → Principles: **least privilege, encryption, closed inbound, whitelist egress**
    * → Admin access: keys/SSO/SSM preferred (disable passwords), MFA required
  * ▷ Network

    * → Public → ALB/Proxy → Private (servers); design **multi-AZ** even if deferred
  * ▷ OS

    * → Latest LTS image, **agents preinstalled** (monitoring/log/SSM), lock down UFW/FirewallD

> **Key takeaway:** Locking down **access paths, encryption, and egress** prevents half of incidents.

---

## 🧰 F. Automation Standards (Terraform/Ansible/PowerShell) — **fully runnable**

### 1) Terraform (minimal safe AWS EC2 skeleton)

```hcl
# infra/envs/dev/main.tf
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}
provider "aws" { region = "ap-northeast-2" }

variable "name" { default = "acme-dev-web-apne2-01" }
locals {
  tags = {
    Project     = "acme"
    Env         = "dev"
    Owner       = "platform-team"
    DataClass   = "Non-PII"
    Backup      = "RPO24h-RTO4h"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.20.0.0/16"
  tags = merge(local.tags, { Name = "${var.name}-vpc" })
}

resource "aws_subnet" "priv_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "ap-northeast-2a"
  tags = merge(local.tags, { Name = "${var.name}-priv-a" })
}

resource "aws_security_group" "web" {
  name        = "${var.name}-sg"
  description = "Least inbound, egress whitelist"
  vpc_id      = aws_vpc.main.id

  # Inbound: only trusted sources such as ALB
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.30.0.0/16"] # e.g., ALB subnet CIDR
  }

  # Egress: whitelist SSM/patch/repos, start wide then tighten
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${var.name}-sg" })
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.priv_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name
  user_data              = file("${path.module}/cloudinit.sh")
  tags                   = merge(local.tags, { Name = var.name })
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter { name = "name" values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] }
}

resource "aws_iam_role" "ssm" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}
data "aws_iam_policy_document" "ec2_assume" {
  statement { actions = ["sts:AssumeRole"]; principals { type = "Service"; identifiers = ["ec2.amazonaws.com"] } }
}
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ssm" { name = "${var.name}-profile"; role = aws_iam_role.ssm.name }
```

`cloudinit.sh` (example):

```bash
#!/bin/bash
set -eux
# Security/observability agents
apt-get update -y
apt-get install -y fail2ban unattended-upgrades curl
# Firewall (UFW)
ufw default deny incoming
ufw default allow outgoing
ufw allow 8080/tcp
ufw --force enable
# Health check endpoint
cat >/usr/local/bin/healthcheck.sh <<'EOF'
#!/bin/bash
echo "ok"
EOF
chmod +x /usr/local/bin/healthcheck.sh
```

### 2) Ansible (minimal Linux hardening set)

```yaml
# hardening.yml
- hosts: web
  become: yes
  vars:
    ssh_port: 22
  tasks:
    - name: Update packages
      apt: update_cache=yes upgrade=dist

    - name: Disable unnecessary services
      service: name={{ item }} enabled=no state=stopped
      loop: [telnet, rsh, rexec]  # adjust to your env

    - name: UFW rule
      ufw:
        rule: allow
        port: "8080"
        proto: tcp
    - ufw: state=enabled

    - name: SSH hardening
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PasswordAuthentication'
        line: 'PasswordAuthentication no'
      notify: Restart sshd
  handlers:
    - name: Restart sshd
      service: name=sshd state=restarted
```

### 3) PowerShell (Windows Server basic verification)

```powershell
# Verify-WinServer.ps1
$Errors = @()

Write-Host "OS/Patch status"
Get-ComputerInfo | Select-Object OsName,OsVersion,WindowsInstallDateFromRegistry
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5

Write-Host "`nFirewall status"
Get-NetFirewallProfile | Format-Table Name, Enabled
if ((Get-NetFirewallProfile | Where Enabled -eq 'False').Count -gt 0) { $Errors += "Firewall disabled" }

Write-Host "`nRequired port check (8080)"
if (-not (Get-NetFirewallRule | Where DisplayName -like "*8080*")) { $Errors += "No 8080 rule" }

Write-Host "`nDisk/Memory"
Get-PhysicalMemory | Measure-Object -Property capacity -Sum | % { "{0:N2} GB" -f ($_.Sum/1GB) }
Get-Volume | Select DriveLetter, FileSystemLabel, SizeRemaining, Size

if ($Errors.Count -gt 0) { Write-Error ("Verification failed: " + ($Errors -join ", ")) } else { Write-Host "✅ Basic verification passed" }
```

> **Key takeaway:** Automated **provisioning (IaC) + hardening (Ansible) + verification (PowerShell/scripts)** ensures accuracy and reproducibility.

---

## 🧪 G. Test & Verification Standard (Smoke → Functional → Load)

* How to use

  * ▷ Preparation

    * → “Tests are first-class”: include **scripts/checklists in the repo**.
  * ▷ Procedure

    * → 1) **Smoke**: SSH/SSM, ports, health endpoint
    * → 2) **Functional**: app start/DB connection/log ingestion
    * → 3) **Load**: hit target RPS/CPU/Mem/IO figures

### Simple port smoke (Linux)

```bash
#!/usr/bin/env bash
set -e
HOST="${1:-localhost}"; PORT="${2:-8080}"
if timeout 2 bash -c "</dev/tcp/$HOST/$PORT"; then
  echo "✅ $HOST:$PORT reachable"
else
  echo "❌ $HOST:$PORT not reachable"; exit 1
fi
```

> **Key takeaway:** **Verification as code** equals quality—checklists alone aren’t enough.

---

## 📈 H. Operations Readiness (Observability / Backup / DR)

* Overview

  * ▷ Observability

    * → Metrics: **availability, error rate, p95 latency, CPU/Mem/Disk/Network**
    * → Logs: structured (JSON), PII masking, explicit retention
  * ▷ Backup/Restore

    * → Make **RPO/RTO** explicit in the pre-brief; **recovery drills** at least quarterly
  * ▷ DR

    * → Tiering (Tier1–3), cross-region/site; **practice is mandatory**

> **Key takeaway:** Operations = **seeing** (monitoring) + **reverting** (backup/DR).

---

## 🗣 I. Prompting Guide (server-build specific)

* How to use

  * ▷ Preparation

    * → Always attach **Section B. Pre-brief**.
  * ▷ Template

```md
[Role] You are a consultant for cloud/on-prem server design.
[Goal] Provide 2–3 realistic designs balancing security/availability/cost, plus decision criteria.
[Constraints] Follow standards (CIS intent), prefer managed services, include IaC examples and GUI steps.
[Pre-brief] (paste Section B here)
[Deliverables] 1) Option comparison table 2) Complete Terraform/Ansible/PowerShell examples 3) Smoke test scripts 4) Checklist
[Verification] List assumptions and risks/mitigations. For unknowns, propose reasonable defaults with rationale.
```

> **Key takeaway:** The six elements **Role·Goal·Constraints·Pre-brief·Deliverables·Verification** lock in answer quality.

---

## 🖱 J. GUI Steps (e.g., AWS EC2) — condensed

* ▷ Preparation

  * → VPC (private subnets), SSM role, SG (minimal inbound), key pair or SSM Session Manager
* ▷ Procedure

  * → Step 1: Choose AMI (LTS, with agents)
  * → Step 2: Attach instance profile (SSM)
  * → Step 3: Configure storage (IOPS/Throughput)
  * → Step 4: Security group (restrict ingress / whitelist egress)
  * → Step 5: Run hardening/health scripts via UserData
  * → Step 6: Apply naming/tagging → launch
  * → Step 7: Smoke tests (ports/health/log ingestion)

> **Key takeaway:** Even console clicks become consistent when you follow a **pre-agreed standard**.

---

## ✅ Final Checklist

1. **Write the Pre-brief** (purpose/perf/availability/security/ops/RPO·RTO/budget)
2. **Pick from the decision tree** (Managed → IaaS → On-prem) and document rationale
3. Apply **naming/tagging/repo layout** rules
4. **Deploy IaC** (Terraform) + **harden** (Ansible/UserData)
5. Confirm **access/encryption/egress** policies
6. Run **smoke/functional/load** tests via automation
7. Wire up **monitoring/logs/backup/DR** and alerts
8. Commit **runbooks/diagrams/audit artifacts** to the repo
9. **Validate cost** (tags/reports) and document **risks/mitigations**

---

## 🎯 Quick Start (two options)

* **Option A — Easiest (Managed + minimal VM)**

  1. Use managed DB/cache  2) App server only on EC2/VM  3) Use the Terraform skeleton above  4) Run smoke tests then direct traffic
* **Option B — Full standardization (IaC + hardening + full test set)**

  1. Clone the repo template  2) Modularize Terraform  3) Apply Ansible hardening  4) CI runs smoke/lint/format automatically

> **Key takeaway:** Ship a small win first, then **cement the standard in the repository**.
