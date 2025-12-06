Certainly, here is the content translated into text-based English.

# 🤖 AI Execution Guidelines for Server Provisioning Questions v1.0

📋 Core Principles

Objective: To standardize the collection of preliminary information for providing accurate, one-shot answers to server provisioning questions.
Scope: Cloud/On-premise server design, provisioning, and operations.
Core Approach: Standard Pre-brief + Decision Tree + Validation Checklist.



🎯 A. Fundamental Principles


Problem:
  - Server provisioning involves many variables (Cloud/On-prem, network, security, OS, storage, availability).
  - Vague questions lead to inaccurate answers.

Solution:
  - Complete a standard Pre-brief before asking a question.
  - Formalize constraints and criteria.
  - "Anyone else should reach the same conclusion."


> Key: Standard Pre-brief + Decision Tree + Validation Checklist = 80% improvement in answer accuracy.



📝 B. Pre-Brief Template

Required Information


# [Server Pre-brief]

1) Purpose/Workload
- Use Case: Web/API/Batch/DB/Cache/ML serving
- Scale: X concurrent users, X RPS, X MB/s throughput
- Availability: Single/HA/Multi-AZ, target availability (e.g., 99.9%)

2) Platform/Deployment
- Runtime: On-prem/VM/Container/K8s/Serverless
- Cloud: AWS/Azure/GCP, Region: ap-northeast-2
- OS: Ubuntu 22.04 / Rocky 9 / Windows Server 2022
- Architecture: x86 / ARM

3) Network/Security
- VPC/VNet: CIDR
- Subnet: public/private
- NAT: Y/N
- Port Policy (ingress/egress): list
- Authentication: Local/AD/SSO/IMDSv2/SSM
- Key Management: KMS/KeyVault/CloudKMS

4) Data/Storage
- Type: Block/File/Object/DB
- Capacity: X GB
- IOPS/Throughput: X
- Backup: Frequency X, Retention X
- RPO: X, RTO: X

5) Operations/Observability
- Monitoring: CloudWatch/Prometheus/Datadog
- Logging: Collection path/retention/PII masking
- Patching/Vulnerability: Cycle/approval process

6) Constraints/Policies
- Budget Limit: X per month
- Licensing: Windows CAL, etc.
- Regulations/Security Standards: CIS level, encryption requirements

7) Deliverables
- IaC: Use of Terraform/Ansible
- Naming/Tagging: rules
- Documentation: Diagrams/Runbooks/Checklists

[Question] (1-3 specific questions)




🌳 C. Architecture Decision Tree

3 Main Options


Option A: Managed/PaaS First
  - Minimize operational burden
  - Faster time-to-value
  - Application: Standard Web/API

Option B: IaaS + IaC Standard
  - High flexibility/portability
  - Application: Specialized middleware

Option C: On-prem/VM
  - Data sovereignty/special requirements
  - Application: Regulatory/dedicated HW


Comparison Table

| Item | Managed (PaaS) | IaaS + IaC | On-prem/VM |
|||||
| Provisioning Speed | Very Fast | Medium | Slow |
| Operational Burden | Minimal | Medium | High |
| Customization | Limited | High | Very High |
| Cost Predictability | Easy | Medium | Difficult (CAPEX) |

Selection Principle: Managed first → if not possible, IaaS+IaC → On-prem only when unavoidable.



🏷️ D. Naming/Tagging/Repo Structure Standard

Naming Convention


Pattern: proj-env-role-region-seq
Example: acme-prod-web-apne2-01


Required Tags


Project: Project Name
Env: dev/staging/prod
Owner: Team Name
CostCenter: Cost Center
DataClass: PII/Non-PII
Backup: RPO24h-RTO4h


Repository Structure


infra/
├─ envs/
│  ├─ prod/
│  └─ dev/
├─ modules/
│  ├─ network/
│  ├─ compute/
│  └─ observability/
└─ runbooks/


> Key: Naming/Tagging is the lifeline for searchability, automation, billing, and auditing.



🔐 E. Security/Network/OS Baseline

Security Principles


Least Privilege:
  - Prefer Keys/SSO/SSM (disable passwords)
  - MFA required

Encryption:
  - In Transit: TLS 1.2+
  - At Rest: Encrypted volumes

Network:
  - Inbound: Deny by default (allow minimum)
  - Egress: Whitelist

Access Path:
  - Public → ALB/Proxy → Private (Server)
  - Multi-AZ design (staggered deployment possible)


OS Baseline


Image: Latest LTS
Agents: Pre-install monitoring/logging/SSM agents
Firewall: Lock down with UFW/FirewallD




🧰 F. Automation Standard (Executable Code)

1\) Terraform (AWS EC2 Minimum Secure Skeleton)


# main.tf
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
    Project   = "acme"
    Env       = "dev"
    Owner     = "platform-team"
    DataClass = "Non-PII"
    Backup    = "RPO24h-RTO4h"
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

  # Inbound: Trusted sources only, e.g., ALB
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.30.0.0/16"]  # ALB subnet
  }

  # Egress: Whitelist (SSM/patch/repo)
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
  owners      = ["099720109477"]  # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# SSM Role
resource "aws_iam_role" "ssm" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.name}-profile"
  role = aws_iam_role.ssm.name
}


cloudinit.sh


#!/bin/bash
set -eux

# Security/Observability agents
apt-get update -y
apt-get install -y fail2ban unattended-upgrades curl

# Firewall (UFW)
ufw default deny incoming
ufw default allow outgoing
ufw allow 8080/tcp
ufw --force enable

# Healthcheck endpoint
cat >/usr/local/bin/healthcheck.sh <<'EOF'
#!/bin/bash
echo "ok"
EOF
chmod +x /usr/local/bin/healthcheck.sh


2\) Ansible (Linux Hardening)


# hardening.yml
- hosts: web
  become: yes
  tasks:
    - name: Update packages
      apt:
        update_cache: yes
        upgrade: dist

    - name: Disable unnecessary services
      service:
        name: "{{ item }}"
        enabled: no
        state: stopped
      loop: [telnet, rsh, rexec]

    - name: UFW rule
      ufw:
        rule: allow
        port: "8080"
        proto: tcp

    - name: Enable UFW
      ufw:
        state: enabled

    - name: Harden SSH
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PasswordAuthentication'
        line: 'PasswordAuthentication no'
      notify: Restart SSH

  handlers:
    - name: Restart SSH
      service:
        name: sshd
        state: restarted


3\) PowerShell (Windows Validation)


# Verify-WinServer.ps1
$Errors = @()

Write-Host "OS/Patch Status"
Get-ComputerInfo | Select-Object OsName, OsVersion
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5

Write-Host "`nFirewall Status"
Get-NetFirewallProfile | Format-Table Name, Enabled
if ((Get-NetFirewallProfile | Where Enabled -eq 'False').Count -gt 0) {
    $Errors += "Firewall is disabled"
}

Write-Host "`nCheck required port (8080)"
if (-not (Get-NetFirewallRule | Where DisplayName -like "*8080*")) {
    $Errors += "Rule for 8080 not found"
}

Write-Host "`nDisk/Memory"
Get-Volume | Select DriveLetter, SizeRemaining, Size

if ($Errors.Count -gt 0) {
    Write-Error ("Validation failed: " + ($Errors -join ", "))
} else {
    Write-Host "✅ Basic validation passed"
}




🧪 G. Test & Validation Standard

3-Step Testing


1. Smoke Test:
   - SSH/SSM access
   - Port open
   - Health endpoint

2. Functional Test:
   - App start
   - DB connection
   - Log collection

3. Load Test:
   - Achieve target RPS
   - CPU/Mem/IO metrics


Port Smoke Test (Linux)


#!/usr/bin/env bash
set -e
HOST="${1:-localhost}"
PORT="${2:-8080}"

if timeout 2 bash -c "</dev/tcp/$HOST/$PORT"; then
  echo "✅ $HOST:$PORT is accessible"
else
  echo "❌ $HOST:$PORT is not accessible"
  exit 1
fi


> Key: Verify with code = Quality assurance.



📈 H. Operational Readiness

Observability


Metrics:
  - Availability, Error Rate, p95 Latency
  - CPU/Mem/Disk/Network

Logs:
  - Structured (JSON)
  - PII Masking
  - Explicit retention period


Backup/Recovery


Requirements:
  - RPO/RTO specified in Pre-brief
  - Recovery drills: at least quarterly

DR:
  - Tier classification (Tier1-3)
  - Cross-region/site
  - Drills are mandatory




🗣️ I. Prompt Guide

Question Template


[Role] Cloud/On-premise Server Design Consultant

[Objective] Provide 2-3 realistic designs balancing security, availability, and cost + decision criteria.

[Constraints]
- Adhere to standards (CIS-inspired)
- Prefer managed services
- Include IaC examples and GUI steps

[Pre-brief] (Paste Section B here)

[Deliverables]
1. Option comparison table
2. Complete Terraform/Ansible/PowerShell examples
3. Smoke test scripts
4. Checklists

[Validation]
- List assumptions
- Risks/mitigation plans
- For ambiguities, use reasonable defaults + provide justification


> Key: 6 elements: Role, Objective, Constraints, Pre-brief, Deliverables, Validation.



🖱️ J. GUI Steps (AWS EC2 Example)

Setup Order


Prerequisites:
  - VPC (with private subnet)
  - SSM Role
  - Security Group (minimal inbound)
  - Key Pair or SSM Session Manager

Steps:
  Step 1: Select AMI (LTS, with agents)
  Step 2: Attach Instance Profile (SSM)
  Step 3: Configure Storage (IOPS/throughput)
  Step 4: Configure Security Group (limited ingress / whitelist egress)
  Step 5: Run hardening/health script via UserData
  Step 6: Apply Naming/Tagging → Launch
  Step 7: Perform Smoke Test (port/health/log collection)




✅ Final Checklist


1. [ ] Complete Pre-brief (purpose/perf/availability/security/ops/RPO-RTO/budget)
2. [ ] Select from decision tree (Managed → IaaS → On-prem) + document reasoning
3. [ ] Apply naming/tagging/repo structure rules
4. [ ] Deploy with IaC (Terraform) + Harden (Ansible/UserData)
5. [ ] Verify access/encryption/egress policies
6. [ ] Run automated Smoke/Functional/Load tests
7. [ ] Connect monitoring/logging/backup/DR + set up alerts
8. [ ] Commit runbooks/diagrams/audit artifacts to repo
9. [ ] Verify costs (tags/reports) + document risks/mitigations




🚀 Quick Start (2 Options)

Option A: Fastest Path (Managed + Minimal VM)


1. Use Managed DB/Cache
2. Use EC2/VM only for the app server
3. Use the Terraform skeleton above
4. Connect traffic after smoke test


Option B: Fully Standardized (IaC + Hardening + Full Testing)


1. Clone repo template
2. Modularize Terraform
3. Apply Ansible hardening
4. Run smoke/lint/format automatically in CI




📌 Key Summary

Server Provisioning Standard: Pre-brief + Decision Tree + IaC + Validation Scripts

Answer Quality Criteria:

  - All code must be executable
  - Adhere to security baseline (least privilege, encryption, closed inbound, whitelist egress)
  - Consistent naming/tagging
  - Include test automation
  - Operational readiness (monitoring/backup/DR)
  - Present 2-3 alternatives (Managed/IaaS/On-prem)