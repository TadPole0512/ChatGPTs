# 🚧 서버 구축용 “정확한 답변” 사전 지침 v1.0

> 목적: 서버 구축 질문을 했을 때 AI/사람 모두가 **한 번에 정확히 답할 수 있도록** 사전에 무엇을 정리·고정해야 하는지에 대한 **표준 운영 지침(SOP)**

---

## 🧭 A. 원칙 & 프레이밍

* Overview

  * ▷ 배경

    * 서버 구축은 변수(클라우드/온프렘, 네트워크, 보안, OS, 스토리지, 가용성)로 인해 **질문이 모호**해지기 쉽다
    * 정확한 답을 위해선 **질문 이전에 “고정 정보(Pre-brief)”를 표준화**해야 한다
  * ▷ 목표

    * **사전 브리핑 템플릿 + 결정 트리 + 검증 스크립트**를 미리 준비
    * “누가 답해도 같은 결론”이 나오게 **제약과 기준을 명문화**

> **핵심 한줄:** “사전 브리핑 표준 + 결정 트리 + 검증 체크리스트”가 정확도의 80%를 결정한다.

---

## 🗂 B. 사전 브리핑 템플릿 (복붙해서 쓰면 됨)

* How to use

  * ▷ 준비

    * → 아래 템플릿을 **항상 질문 맨 위**에 붙여넣기
  * ▷ 절차

    * → 빈칸 채우기 → 불명확 항목은 “TBD-날짜”로 표기 → 질문 본문 작성

```md
# [사전 브리핑/Server Pre-brief]

1) 목적/워크로드
- 용도: (웹/API/배치/DB/캐시/ML 서빙 등)
- 규모: 동시접속 X, RPS X, 처리량 X MB/s
- 가용성: (싱글/이중화/멀티AZ)  목표가용성(예: 99.9%)

2) 플랫폼/배치
- 배치: (온프렘/VM/컨테이너/K8s/서버리스)
- 클라우드: (AWS/Azure/GCP)  리전: (ap-…)
- OS: (Ubuntu 22.04 / Rocky 9 / Windows 2022)  아키: (x86/ARM)

3) 네트워크/보안
- VPC/VNet: (CIDR)  서브넷: (공/사)  NAT: (Y/N)
- 포트 정책(인바운드/아웃바운드): (리스트)
- 인증: (로컬/AD/SSO/IMDSv2/SSM)  키관리: (KMS/KeyVault/CloudKMS)

4) 데이터/스토리지
- 타입: (블록/파일/오브젝트/DB)  용량: X GB  IOPS/스루풋: X
- 백업: 주기 X, 보존 X  RPO: X, RTO: X

5) 운영/관측
- 모니터링: (CloudWatch/Prometheus/Datadog 등)
- 로깅: (수집 경로/보존기간/PII 마스킹)
- 패치/취약점: (주기/승인 절차)

6) 제약/정책
- 예산 상한: X원/월  라이선스: (예: Windows CAL)
- 규제/보안 기준: (CIS 레벨, 암호화 의무 등)

7) 산출물 형식
- IaC: (Terraform/Ansible 여부)  네이밍 규칙/태깅: (정의)
- 문서: (다이어그램/런북/체크리스트)

[질문] (여기에 구체 질문 1~3개로 끝내기)
```

> **핵심 한줄:** 질문 전에 “Pre-brief”를 붙이면 정답 품질이 급상승한다.

---

## 🌳 C. 아키텍처 결정 트리 (3가지 기본 루트)

* Overview

  * ▷ 선택지

    * A) **매니지드/PaaS 우선**: 운영 부담↓, 속도↑
    * B) **IaaS + IaC 표준**: 유연성/이식성↑
    * C) **온프렘/VM**: 데이터 주권/특수요건
* 비교표

| 항목     | 매니지드(PaaS) | IaaS+IaC(EC2/VM) | 온프렘/VM    |
| ------ | ---------- | ---------------- | --------- |
| 구축속도   | 매우 빠름      | 보통               | 느림        |
| 운영부담   | 최소         | 중간               | 큼         |
| 커스터마이즈 | 제한         | 높음               | 매우 높음     |
| 비용예측   | 쉬움         | 보통               | 어려움(초기투자) |
| 권장 상황  | 표준 웹/API   | 특수 미들웨어          | 규제/전용 HW  |

> **핵심 한줄:** “가능하면 매니지드, 불가하면 IaaS+IaC, 불가피하면 온프렘.”

---

## 🧾 D. 네이밍·태그·디렉터리 표준 (틀 고정)

* How to use

  * ▷ 준비

    * → 네이밍/태깅이 없으면 비용/보안/운영이 무너진다
  * ▷ 규칙

    * → `proj-env-role-region-seq` (예: `acme-prod-web-apne2-01`)
    * → 태그: `Project, Env, Owner, CostCenter, DataClass(PII/Non-PII), Backup(RPO/RTO)`
    * → 저장소 레이아웃

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

> **핵심 한줄:** “이름·태그가 곧 검색성, 자동화성, 청구/감사의 생명줄.”

---

## 🔐 E. 보안·네트워크·OS 베이스라인 (필수 고정치)

* Overview

  * ▷ 보안 고정

    * → 기본 원칙: **최소권한, 암호화, 폐쇄형 인바운드, 아웃바운드 화이트리스트**
    * → 관리접속: 키/SSO/SSM 우선(패스워드 비활성), MFA 필수
  * ▷ 네트워크

    * → 퍼블릭→ALB/Proxy→프라이빗(서버) 구조, 보류 시라도 **멀티AZ** 설계
  * ▷ OS

    * → 최신 LTS 이미지, **에이전트(모니터링/로그/SSM) 사전 탑재**, UFW/FirewallD 규칙 고정

> **핵심 한줄:** “접속 경로·암호화·아웃바운드 규제”만 잡아도 사고 절반이 사라진다.

---

## 🧰 F. 자동화 표준 (Terraform/Ansible/PowerShell) — **완전 실행 예시**

### 1) Terraform (AWS EC2 최소 안전 스켈레톤)

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

  # 인바운드: ALB 등 신뢰 소스만
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.30.0.0/16"] # 예: ALB 서브넷 CIDR
  }

  # 아웃바운드: SSM/패치/리포지토리 등 화이트리스트
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 시작은 전체 -> 점진적 축소 권장
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

`cloudinit.sh`(예시):

```bash
#!/bin/bash
set -eux
# 보안/관측 에이전트
apt-get update -y
apt-get install -y fail2ban unattended-upgrades curl
# 방화벽 (UFW)
ufw default deny incoming
ufw default allow outgoing
ufw allow 8080/tcp
ufw --force enable
# 헬스체크 엔드포인트
cat >/usr/local/bin/healthcheck.sh <<'EOF'
#!/bin/bash
echo "ok"
EOF
chmod +x /usr/local/bin/healthcheck.sh
```

### 2) Ansible (리눅스 하드닝 최소 세트)

```yaml
# hardening.yml
- hosts: web
  become: yes
  vars:
    ssh_port: 22
  tasks:
    - name: 패키지 최신화
      apt: update_cache=yes upgrade=dist

    - name: 비필요 서비스 비활성
      service: name={{ item }} enabled=no state=stopped
      loop: [telnet, rsh, rexec]  # 환경에 맞게 조정

    - name: UFW 규칙
      ufw:
        rule: allow
        port: "8080"
        proto: tcp
    - ufw: state=enabled

    - name: SSH 보안
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PasswordAuthentication'
        line: 'PasswordAuthentication no'
      notify: Restart sshd
  handlers:
    - name: Restart sshd
      service: name=sshd state=restarted
```

### 3) PowerShell (Windows Server 기본 검증)

```powershell
# Verify-WinServer.ps1
$Errors = @()

Write-Host "OS/패치 상태"
Get-ComputerInfo | Select-Object OsName,OsVersion,WindowsInstallDateFromRegistry
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5

Write-Host "`n방화벽 상태"
Get-NetFirewallProfile | Format-Table Name, Enabled
if ((Get-NetFirewallProfile | Where Enabled -eq 'False').Count -gt 0) { $Errors += "방화벽 꺼짐" }

Write-Host "`n필수 포트 확인 (8080)"
if (-not (Get-NetFirewallRule | Where DisplayName -like "*8080*")) { $Errors += "8080 규칙 없음" }

Write-Host "`n디스크/메모리"
Get-PhysicalMemory | Measure-Object -Property capacity -Sum | % { "{0:N2} GB" -f ($_.Sum/1GB) }
Get-Volume | Select DriveLetter, FileSystemLabel, SizeRemaining, Size

if ($Errors.Count -gt 0) { Write-Error ("검증 실패: " + ($Errors -join ", ")) } else { Write-Host "✅ 기본 검증 통과" }
```

> **핵심 한줄:** 자동화된 **생성( IaC ) + 강화(Ansible) + 검증(PowerShell/스크립트)**이 정확성과 재현성을 보장한다.

---

## 🧪 G. 검증/테스트 표준 (Smoke → 기능 → 부하)

* How to use

  * ▷ 준비

    * → “테스트는 기본 제공”이 원칙: **스크립트/체크리스트를 저장소에 포함**
  * ▷ 절차

    * → 1) **Smoke**: SSH/SSM, 포트, 헬스엔드포인트
    * → 2) **기능**: 앱 기동/DB 접속/로그 수집
    * → 3) **부하**: 목표 RPS/CPU/메모리/IO 수치 달성

### 간단 포트 스모크(리눅스)

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

> **핵심 한줄:** “코드로 검증”이 곧 품질—체크리스트만으론 부족하다.

---

## 📈 H. 운영 준비(Observability/Backup/DR)

* Overview

  * ▷ 관측

    * → 메트릭: **가용성, 오류율, p95 지연, CPU/메모리/디스크/네트워크**
    * → 로그: 구조화(JSON), 개인정보 마스킹, 보존기간 명시
  * ▷ 백업/복구

    * → **RPO/RTO** 수치화를 브리핑에 필수 기재, **복구 리허설** 분기 1회
  * ▷ DR

    * → 등급(Tier1~3) 정의, 교차 리전/센터, **연습**으로만 성립

> **핵심 한줄:** 운영은 “보는 눈(모니터링) + 되돌리는 손(백업/DR)”로 완성된다.

---

## 🗣 I. AI에 정확히 묻는 프롬프트 지침 (서버 구축 전용)

* How to use

  * ▷ 준비

    * → 항상 **B. 사전 브리핑**을 동봉
  * ▷ 템플릿

```md
[역할] 당신은 클라우드/온프렘 서버 설계 컨설턴트다.
[목표] 보안/가용성/비용 균형의 현실적 설계안 2~3개 + 결정 기준 제시.
[제약] 표준 준수(CIS 취지), 매니지드 우선, IaC 코드 예시 포함, GUI 절차도 제공.
[사전 브리핑] (B 섹션 붙여넣기)
[산출물] 1) 결정안 비교표 2) Terraform/Ansible/PowerShell 완전 예시 3) 스모크 테스트 스크립트 4) 체크리스트
[검증] 가정 목록과 리스크/완화책을 명시. 모호한 값은 합리적 디폴트와 근거 제시.
```

> **핵심 한줄:** “역할·목표·제약·브리핑·산출물·검증” 6요소가 답변 품질을 고정한다.

---

## 🖱 J. GUI 절차(예: AWS EC2) — 요약 단계

* ▷ 준비

  * → VPC(사설서브넷), SSM 역할, SG(인바운드 최소), 키 페어 또는 SSM Session Manager
* ▷ 절차

  * → Step 1: AMI 선택(LTS, 에이전트 포함)
  * → Step 2: 인스턴스 프로파일(SSM) 연결
  * → Step 3: 스토리지(IOPS/Throughput) 설정
  * → Step 4: 보안그룹(인바운드 제한/아웃바운드 화이트리스트)
  * → Step 5: UserData로 하드닝/헬스체크 스크립트 실행
  * → Step 6: 태깅/네이밍 적용 → 기동
  * → Step 7: 스모크 테스트(포트/헬스/로그 인제스트 확인)

> **핵심 한줄:** 콘솔 클릭도 “미리 정한 표준”을 따른다면 일관성이 생긴다.

---

## ✅ 최종 체크리스트

1. **Pre-brief 작성**(목적/성능/가용성/보안/운영/RPO·RTO/예산)
2. **결정 트리 선택**(매니지드 → IaaS → 온프렘) 근거 기록
3. **네이밍/태깅/디렉터리** 규칙 적용
4. **IaC 배포**(Terraform) + **하드닝**(Ansible/UserData)
5. **접근·암호화·아웃바운드** 정책 확인
6. **스모크/기능/부하 테스트** 자동 스크립트 실행
7. **모니터링/로그/백업/DR** 연결 및 알람 설정
8. **런북/다이어그램/감사기록** 저장소에 커밋
9. **코스트 검증**(태그/리포트), **리스크·완화책** 문서화

---

## 🎯 빠른 시작(2가지 옵션)

* **옵션 A — 가장 쉬운 시작(매니지드+최소 VM)**

  1. 관리형 DB/캐시로 대체  2) 앱 서버만 EC2/VM  3) 위 Terraform 스켈레톤 사용  4) 스모크 후 트래픽 유도
* **옵션 B — 본격 표준화(IaC+하드닝+테스트 풀셋)**

  1. 저장소 템플릿 복제  2) Terraform 모듈화  3) Ansible 하드닝  4) CI에서 스모크/린트/포맷 자동화

> **핵심 한줄:** 작은 성공을 먼저 만든 뒤, 표준을 **리포지토리로 고정**하라.

---

필요하면 위 템플릿들(Pre-brief, Terraform, Ansible, PowerShell)을 **당신 환경에 맞춰 커스터마이즈해서 한 파일로 묶은 스타터 킷**까지 바로 만들어줄게. 어떤 클라우드/OS 조합으로 시작할지만 알려줘!
