# GitLab 구축(Infrastructure Setup) 완전 가이드

## 🧠 적용된 사고 공식

이번 답변을 위해 다음 공식들을 조합했습니다:

### 1. **복잡도 해결 매트릭스 (CS)**
- GitLab 구축을 **하드웨어 → 설치 → 설정 → 검증**의 하위 시스템으로 분해
- 각 단계의 상호작용 계수 파악 (예: 하드웨어 스펙 ↔ 동시 사용자 수)

### 2. **통합 지혜 공식 (IW)**
- 지식(K): GitLab 아키텍처 이해
- 실행(A): 즉시 실행 가능한 스크립트
- 윤리(E): 보안 강화 및 백업 전략 포함

### 3. **천재적 통찰 공식 (GI)**
- 관찰(O): 다양한 설치 환경 분석
- 연결(C): 환경별 최적 방법 매칭
- 패턴(P): 공통 트러블슈팅 패턴 식별

---

## 🧭 [1단계] 사전 브리핑 요약

### 배경
GitLab 구축은 단순한 소프트웨어 설치가 아닌 **DevOps 플랫폼 전체 인프라 구성**입니다:
- Git 저장소
- CI/CD Runner
- Container Registry
- 보안 스캔 엔진
- 모니터링 시스템

### 범위
```
📦 구축 단계
├── 1️⃣ 요구사항 분석 (사용자 수, 워크로드)
├── 2️⃣ 설치 방법 선택 (Omnibus/Docker/Kubernetes/Cloud)
├── 3️⃣ 초기 설정 (HTTPS, 인증, 이메일)
└── 4️⃣ 검증 및 강화 (헬스체크, 보안, 백업)
```

---

## ❓ [2단계] 핵심 질문

**Q1**: 우리 환경에 맞는 하드웨어 사양은?  
**Q2**: 어떤 설치 방법을 선택해야 하나?  
**Q3**: 설치 후 반드시 해야 할 보안 설정은?  
**Q4**: 설치가 제대로 됐는지 어떻게 확인하나?

---

## ✅ [3단계] 답변 - 단계별 구축 가이드

---

## 📋 **STEP 1: 요구사항 분석 및 하드웨어 사양**

<details open>
<summary><strong>💡 환경별 권장 사양 (클릭하여 펼치기/접기)</strong></summary>

### 🎯 사용자 규모별 하드웨어 스펙

| 사용자 수 | 동시 접속률 | CPU | RAM | 디스크 | 네트워크 |
|----------|------------|-----|-----|--------|----------|
| **1-100명** | 10% | 4 cores | 8 GB | 100 GB SSD | 1 Gbps |
| **100-500명** | 20% | 8 cores | 16 GB | 250 GB SSD | 1 Gbps |
| **500-1000명** | 30% | 16 cores | 32 GB | 500 GB SSD | 10 Gbps |
| **1000명+** | 30%+ | 32+ cores | 64+ GB | 1 TB+ SSD | 10 Gbps |

### 📊 워크로드별 추가 고려사항

| 기능 | 추가 요구사항 |
|------|--------------|
| **CI/CD 집약적** | CPU +50%, RAM +30% |
| **Container Registry** | 디스크 +200GB (이미지 저장) |
| **고가용성(HA)** | 최소 3대 서버 (Load Balancer 포함) |
| **대용량 저장소** | 디스크 +500GB (Git LFS 사용 시) |

### 🔌 네트워크 요구사항

```yaml
필수 포트:
  - 80 (HTTP)
  - 443 (HTTPS)
  - 22 (SSH/Git)

선택 포트:
  - 5050 (Container Registry)
  - 9090 (Prometheus)
  - 3000 (Grafana)

방화벽 규칙:
  - Inbound: 80, 443, 22 허용
  - Outbound: 인터넷 접근 (패키지 다운로드)
  - 내부: GitLab ↔ PostgreSQL/Redis (고가용성 시)
```

</details>

### ✅ 검증: 요구사항 체크리스트

```markdown
- [ ] 예상 사용자 수 확정
- [ ] 동시 접속률 추정 (일반적으로 10-30%)
- [ ] CI/CD 파이프라인 예상 빈도 (일일 빌드 수)
- [ ] 저장소 크기 예측 (현재 코드베이스 × 3배)
- [ ] 네트워크 대역폭 확인
- [ ] 고가용성(HA) 필요 여부 결정
- [ ] 백업 저장소 위치 결정 (로컬/클라우드)
```

---

## 🏗️ **STEP 2: 설치 방법 선택 가이드**

<details open>
<summary><strong>🔍 설치 방법 비교표 (클릭하여 펼치기/접기)</strong></summary>

### 📊 4가지 설치 방법 비교

| 항목 | Omnibus Package | Docker Compose | Kubernetes Helm | Cloud Managed |
|------|----------------|----------------|-----------------|---------------|
| **난이도** | ⭐ 쉬움 | ⭐⭐ 보통 | ⭐⭐⭐ 어려움 | ⭐ 매우 쉬움 |
| **구축 시간** | 10분 | 15분 | 30분+ | 5분 |
| **권장 환경** | 단일 서버 | 개발/테스트 | 프로덕션 HA | 운영 부담 최소화 |
| **확장성** | 제한적 | 제한적 | 매우 높음 | 자동 확장 |
| **유지보수** | 수동 업그레이드 | 컨테이너 재배포 | 자동화 가능 | 관리형 |
| **비용** | 하드웨어만 | 하드웨어만 | 하드웨어+관리 | 사용량 기반 |
| **백업 복잡도** | 낮음 | 중간 | 중간 | 자동 (일부) |

### 🎯 의사결정 플로우차트

```
사용자 수는?
├─ < 100명 ────────────► Omnibus Package
├─ 100-500명
│   ├─ 개발/테스트? ───► Docker Compose
│   └─ 프로덕션? ──────► Omnibus Package
└─ 500명+
    ├─ 고가용성 필요? ─► Kubernetes Helm
    ├─ 운영 인력 부족? ► Cloud Managed (AWS/GCP/Azure)
    └─ 온프레미스? ────► Kubernetes Helm
```

</details>

---

## 🚀 **STEP 3-A: Omnibus Package 설치 (Ubuntu 22.04)**

<details open>
<summary><strong>⚡ 빠른 설치 (5-10분) - 클릭하여 펼치기/접기</strong></summary>

### 📋 사전 준비 체크리스트

```markdown
- [ ] OS: Ubuntu 22.04 LTS (또는 20.04)
- [ ] Root 또는 sudo 권한
- [ ] 고정 IP 또는 도메인 이름
- [ ] 최소 8GB RAM, 4 CPU cores
- [ ] 50GB+ 디스크 여유 공간
- [ ] 인터넷 연결 (패키지 다운로드)
```

### 🔧 자동 설치 스크립트

```bash
#!/bin/bash
# GitLab Omnibus 자동 설치 스크립트 (Ubuntu 22.04)
# 실행: sudo bash gitlab-install.sh

set -e  # 오류 발생 시 중단

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== GitLab Omnibus 설치 시작 ===${NC}"

# 1) 시스템 업데이트
echo -e "${YELLOW}[1/7] 시스템 업데이트 중...${NC}"
apt update && apt upgrade -y

# 2) 필수 패키지 설치
echo -e "${YELLOW}[2/7] 필수 패키지 설치 중...${NC}"
apt install -y curl openssh-server ca-certificates tzdata perl

# 3) Postfix 설치 (이메일 알림용)
echo -e "${YELLOW}[3/7] Postfix 설치 중...${NC}"
apt install -y postfix
# Postfix 설정: "Internet Site" 선택, 시스템 메일 이름은 FQDN 입력

# 4) GitLab 저장소 추가
echo -e "${YELLOW}[4/7] GitLab 저장소 추가 중...${NC}"
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | bash

# 5) 도메인 설정 (수정 필요)
read -p "GitLab 도메인 또는 IP 입력 (예: gitlab.example.com): " GITLAB_DOMAIN

# 6) GitLab 설치
echo -e "${YELLOW}[5/7] GitLab 설치 중 (5-10분 소요)...${NC}"
EXTERNAL_URL="https://$GITLAB_DOMAIN" apt install -y gitlab-ee

# 7) 초기 root 비밀번호 확인
echo -e "${GREEN}[6/7] 설치 완료!${NC}"
echo -e "${GREEN}=== 초기 root 비밀번호 ===${NC}"
cat /etc/gitlab/initial_root_password
echo -e "${YELLOW}위 비밀번호는 24시간 후 자동 삭제됩니다. 지금 복사하세요!${NC}"

# 8) 서비스 상태 확인
echo -e "${YELLOW}[7/7] 서비스 상태 확인 중...${NC}"
gitlab-ctl status

echo -e "${GREEN}=== 설치 완료! ===${NC}"
echo -e "브라우저에서 https://$GITLAB_DOMAIN 접속하세요"
echo -e "초기 계정: root / (위 비밀번호)"
```

### ✅ 설치 검증 (3단계)

#### 1️⃣ 서비스 상태 확인
```bash
# 모든 GitLab 서비스 상태 확인
sudo gitlab-ctl status

# 예상 출력:
# run: gitaly: (pid 12345) 150s; run: log: (pid 12346) 150s
# run: gitlab-workhorse: (pid 12347) 150s; run: log: (pid 12348) 150s
# run: logrotate: (pid 12349) 150s; run: log: (pid 12350) 150s
# run: nginx: (pid 12351) 150s; run: log: (pid 12352) 150s
# run: postgresql: (pid 12353) 150s; run: log: (pid 12354) 150s
# run: redis: (pid 12355) 150s; run: log: (pid 12356) 150s
# run: sidekiq: (pid 12357) 150s; run: log: (pid 12358) 150s

# 모든 서비스가 "run" 상태여야 정상
```

#### 2️⃣ 웹 접근 테스트
```bash
# 로컬에서 HTTP 응답 확인
curl -I http://localhost

# 예상 출력:
# HTTP/1.1 301 Moved Permanently (HTTPS로 리다이렉트)
# 또는
# HTTP/1.1 200 OK

# HTTPS 테스트 (자체 서명 인증서 경고 무시)
curl -k https://localhost

# HTML 응답이 오면 정상
```

#### 3️⃣ GitLab 헬스체크
```bash
# GitLab 내부 진단 실행
sudo gitlab-rake gitlab:check

# 예상 출력 (모두 "yes" 또는 "finished"):
# Checking GitLab Shell ...
# GitLab Shell: ... OK
# 
# Checking GitLab Shell ... Finished
# 
# Checking Gitaly ...
# Gitaly: default ... OK
# 
# Checking Sidekiq ...
# Sidekiq: Running? ... yes
# Number of Sidekiq processes (cluster/worker) ... 1/1
```

### ⚠️ 일반적인 설치 오류 및 해결

| 증상 | 원인 | 해결 방법 |
|------|------|----------|
| **502 Bad Gateway** | 서비스 미시작 | `sudo gitlab-ctl restart` |
| **메모리 부족 오류** | RAM < 8GB | swap 파일 추가 또는 메모리 증설 |
| **설치 중단 (timeout)** | 네트워크 느림 | 재시도 또는 미러 저장소 사용 |
| **Postfix 설정 실패** | 대화형 설정 미완료 | `sudo dpkg-reconfigure postfix` |

</details>

---

## 🐳 **STEP 3-B: Docker Compose 설치 (개발/테스트용)**

<details>
<summary><strong>🔧 Docker Compose 설치 (클릭하여 펼치기/접기)</strong></summary>

### 📋 사전 준비

```bash
# Docker 및 Docker Compose 설치 (Ubuntu)
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER
# 재로그인 필요
```

### 📄 docker-compose.yml 파일

```yaml
version: '3.8'

services:
  gitlab:
    image: 'gitlab/gitlab-ee:latest'
    container_name: gitlab
    restart: always
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.example.com'
        gitlab_rails['gitlab_shell_ssh_port'] = 2222
        # 이메일 설정
        gitlab_rails['smtp_enable'] = true
        gitlab_rails['smtp_address'] = "smtp.gmail.com"
        gitlab_rails['smtp_port'] = 587
        gitlab_rails['smtp_user_name'] = "your-email@gmail.com"
        gitlab_rails['smtp_password'] = "your-app-password"
        gitlab_rails['smtp_domain'] = "smtp.gmail.com"
        gitlab_rails['smtp_authentication'] = "login"
        gitlab_rails['smtp_enable_starttls_auto'] = true
        gitlab_rails['smtp_tls'] = false
        gitlab_rails['smtp_openssl_verify_mode'] = 'peer'
        # 백업 설정
        gitlab_rails['backup_keep_time'] = 604800
    ports:
      - '80:80'
      - '443:443'
      - '2222:22'
    volumes:
      - './config:/etc/gitlab'
      - './logs:/var/log/gitlab'
      - './data:/var/opt/gitlab'
    shm_size: '256m'

  gitlab-runner:
    image: 'gitlab/gitlab-runner:latest'
    container_name: gitlab-runner
    restart: always
    volumes:
      - './runner-config:/etc/gitlab-runner'
      - '/var/run/docker.sock:/var/run/docker.sock'
```

### 🚀 실행 및 검증

```bash
# Docker Compose 실행
docker-compose up -d

# 로그 확인 (초기화 완료까지 5-10분)
docker-compose logs -f gitlab

# "gitlab Reconfigured!" 메시지가 나올 때까지 대기

# 초기 root 비밀번호 확인
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password

# 서비스 상태 확인
docker-compose ps

# 예상 출력:
# NAME           COMMAND                  SERVICE         STATUS
# gitlab         "/assets/wrapper"        gitlab          Up 10 minutes
# gitlab-runner  "/usr/bin/dumb-init …"   gitlab-runner   Up 10 minutes
```

### ✅ 검증 스크립트

```bash
#!/bin/bash
# Docker Compose GitLab 검증 스크립트

# 컨테이너 실행 확인
if [ $(docker ps | grep gitlab | wc -l) -eq 2 ]; then
    echo "✅ 컨테이너 실행 중"
else
    echo "❌ 컨테이너 미실행"
    exit 1
fi

# 웹 서비스 응답 확인
if curl -s http://localhost | grep -q "GitLab"; then
    echo "✅ 웹 서비스 정상"
else
    echo "❌ 웹 서비스 미응답"
    exit 1
fi

# 헬스체크
docker exec gitlab gitlab-rake gitlab:check

echo "✅ 모든 검증 완료"
```

</details>

---

## ☸️ **STEP 3-C: Kubernetes Helm 설치 (프로덕션 HA)**

<details>
<summary><strong>🎯 Kubernetes 고가용성 설치 (클릭하여 펼치기/접기)</strong></summary>

### 📋 사전 요구사항

```yaml
Kubernetes 클러스터:
  - 버전: 1.24+
  - 노드: 최소 3개 (Control Plane 분리 권장)
  - StorageClass: ReadWriteMany 지원 (NFS, Ceph, AWS EFS 등)
  - LoadBalancer: MetalLB, Nginx Ingress, 또는 클라우드 LB

Helm:
  - 버전: 3.x
  
리소스:
  - CPU: 12+ cores (총합)
  - RAM: 48+ GB (총합)
  - 스토리지: 500+ GB (Persistent Volume)
```

### 🔧 Helm 설치

```bash
# Helm 저장소 추가
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# GitLab Helm Chart 다운로드 (values.yaml 커스터마이징용)
helm fetch gitlab/gitlab --untar
cd gitlab
```

### 📄 values.yaml 커스터마이징 (최소 설정)

```yaml
# values-production.yaml
global:
  hosts:
    domain: gitlab.example.com
    https: true
  ingress:
    configureCertmanager: true
    class: nginx
  
  # 이메일 설정
  smtp:
    enabled: true
    address: smtp.gmail.com
    port: 587
    user_name: "your-email@gmail.com"
    password:
      secret: gitlab-smtp
      key: password
    authentication: login
    starttls_auto: true
  
  # 고가용성 설정
  gitaly:
    enabled: true
    external: []
  
  # PostgreSQL HA
  psql:
    host: postgresql.default.svc.cluster.local
    password:
      secret: gitlab-postgresql
      key: password
  
  # Redis HA
  redis:
    host: redis-master.default.svc.cluster.local
    password:
      secret: gitlab-redis
      key: password

# 리소스 할당
gitlab:
  webservice:
    minReplicas: 2
    maxReplicas: 5
    resources:
      requests:
        cpu: 1000m
        memory: 2Gi
  
  sidekiq:
    minReplicas: 2
    resources:
      requests:
        cpu: 500m
        memory: 1.5Gi

# Persistent Volume
gitlab-runner:
  install: true
  runners:
    privileged: true
    config: |
      [[runners]]
        [runners.kubernetes]
          namespace = "{{.Release.Namespace}}"
          image = "ubuntu:22.04"

# 백업 설정
gitlab:
  task-runner:
    backups:
      cron:
        enabled: true
        schedule: "0 2 * * *"  # 매일 02:00
      objectStorage:
        config:
          secret: gitlab-s3-backup
          key: config
```

### 🚀 설치 실행

```bash
# Namespace 생성
kubectl create namespace gitlab

# Secret 생성 (SMTP, PostgreSQL, Redis)
kubectl create secret generic gitlab-smtp \
  --from-literal=password='your-smtp-password' \
  -n gitlab

kubectl create secret generic gitlab-postgresql \
  --from-literal=password='your-db-password' \
  -n gitlab

kubectl create secret generic gitlab-redis \
  --from-literal=password='your-redis-password' \
  -n gitlab

# Helm 설치 (20-30분 소요)
helm install gitlab gitlab/gitlab \
  -f values-production.yaml \
  -n gitlab

# 설치 상태 모니터링
watch kubectl get pods -n gitlab

# 모든 Pod가 Running 상태가 될 때까지 대기
```

### ✅ 검증

```bash
# Pod 상태 확인
kubectl get pods -n gitlab

# Service 및 Ingress 확인
kubectl get svc,ingress -n gitlab

# 초기 root 비밀번호 확인
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath='{.data.password}' | base64 --decode

# 헬스체크
kubectl exec -it $(kubectl get pod -n gitlab -l app=webservice -o jsonpath='{.items[0].metadata.name}') -n gitlab -- gitlab-rake gitlab:check
```

### 📊 모니터링 대시보드

```bash
# Prometheus/Grafana 설치 (선택사항)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# GitLab 메트릭 확인
kubectl port-forward -n gitlab svc/gitlab-prometheus-server 9090:80
# 브라우저: http://localhost:9090
```

</details>

---

## 🔐 **STEP 4: 초기 보안 강화 (모든 설치 방법 공통)**

<details open>
<summary><strong>🛡️ 필수 보안 설정 (클릭하여 펼치기/접기)</strong></summary>

### 1️⃣ HTTPS/SSL 인증서 설정

#### Let's Encrypt 자동 인증서 (Omnibus)

```ruby
# /etc/gitlab/gitlab.rb 편집
sudo nano /etc/gitlab/gitlab.rb

# 다음 내용 추가/수정
external_url 'https://gitlab.example.com'
letsencrypt['enable'] = true
letsencrypt['contact_emails'] = ['admin@example.com']
letsencrypt['auto_renew'] = true

# 적용
sudo gitlab-ctl reconfigure
```

#### 수동 인증서 설정 (기존 인증서 사용 시)

```ruby
# /etc/gitlab/gitlab.rb
external_url 'https://gitlab.example.com'
nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.example.com.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.example.com.key"
nginx['redirect_http_to_https'] = true

# 인증서 파일 복사
sudo mkdir -p /etc/gitlab/ssl
sudo cp your-certificate.crt /etc/gitlab/ssl/gitlab.example.com.crt
sudo cp your-private-key.key /etc/gitlab/ssl/gitlab.example.com.key
sudo chmod 600 /etc/gitlab/ssl/*

# 적용
sudo gitlab-ctl reconfigure
```

#### 검증

```bash
# SSL 인증서 확인
echo | openssl s_client -connect gitlab.example.com:443 2>/dev/null | openssl x509 -noout -dates

# 예상 출력:
# notBefore=Jan  1 00:00:00 2024 GMT
# notAfter=Apr  1 00:00:00 2024 GMT

# HTTP → HTTPS 리다이렉트 테스트
curl -I http://gitlab.example.com

# 예상: HTTP/1.1 301 Moved Permanently
# Location: https://gitlab.example.com/
```

### 2️⃣ 방화벽 설정

```bash
# UFW (Ubuntu Firewall)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp  # SSH
sudo ufw enable

# 상태 확인
sudo ufw status

# firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
```

### 3️⃣ SSH 키 기반 인증 강제

```ruby
# /etc/gitlab/gitlab.rb
gitlab_rails['gitlab_shell_ssh_port'] = 22
gitlab_sshd['enable'] = true

# 비밀번호 인증 비활성화 (선택사항)
# SSH 키만 허용하려면 GitLab UI에서 설정:
# Admin Area > Settings > General > Sign-in restrictions
# "Require two-factor authentication" 활성화 (권장)
```

### 4️⃣ 초기 관리자 계정 보안

```bash
# 웹 UI 접속 후 즉시 수행:
# 1. root 비밀번호 변경 (강력한 비밀번호 사용)
# 2. 2FA(Two-Factor Authentication) 활성화

# CLI로 사용자 생성 (추가 관리자)
sudo gitlab-rails console

# Rails 콘솔에서:
user = User.new(username: 'admin2', email: 'admin2@example.com', name: 'Admin User', password: 'StrongPassword123!', password_confirmation: 'StrongPassword123!')
user.admin = true
user.skip_confirmation!
user.save!
exit
```

### 5️⃣ 자동 백업 설정

```ruby
# /etc/gitlab/gitlab.rb
gitlab_rails['backup_keep_time'] = 604800  # 7일 보관
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"

# S3 백업 (AWS)
gitlab_rails['backup_upload_connection'] = {
  'provider' => 'AWS',
  'region' => 'ap-northeast-2',
  'aws_access_key_id' => 'YOUR_ACCESS_KEY',
  'aws_secret_access_key' => 'YOUR_SECRET_KEY'
}
gitlab_rails['backup_upload_remote_directory'] = 'gitlab-backups'

# 적용
sudo gitlab-ctl reconfigure

# Cron 작업 추가 (매일 02:00 백업)
sudo crontab -e
# 다음 줄 추가:
0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1
```

### 6️⃣ 로그 및 감사 설정

```ruby
# /etc/gitlab/gitlab.rb
gitlab_rails['audit_events_enabled'] = true

# 로그 보존 기간
logging['logrotate_frequency'] = "daily"
logging['logrotate_maxsize'] = "200"  # MB
logging['logrotate_rotate'] = 7  # 7일치 보관
```

### ✅ 보안 검증 체크리스트

```bash
#!/bin/bash
# 보안 설정 검증 스크립트

echo "=== GitLab 보안 검증 ==="

# 1. HTTPS 확인
if curl -s -o /dev/null -w "%{http_code}" https://gitlab.example.com | grep -q "200\|301\|302"; then
    echo "✅ HTTPS 정상"
else
    echo "❌ HTTPS 실패"
fi

# 2. HTTP → HTTPS 리다이렉트 확인
if curl -s -I http://gitlab.example.com |grep -q "301\|302"; then
    echo "✅ HTTP → HTTPS 리다이렉트 정상"
else
    echo "❌ 리다이렉트 미설정"
fi

# 3. 방화벽 상태 확인
if sudo ufw status | grep -q "active"; then
    echo "✅ 방화벽 활성화됨"
    sudo ufw status | grep -E "80|443|22"
else
    echo "⚠️  방화벽 미활성화"
fi

# 4. 백업 디렉토리 확인
if [ -d "/var/opt/gitlab/backups" ]; then
    echo "✅ 백업 디렉토리 존재"
    ls -lh /var/opt/gitlab/backups | tail -5
else
    echo "❌ 백업 디렉토리 없음"
fi

# 5. SSL 인증서 만료일 확인
echo "📅 SSL 인증서 만료일:"
echo | openssl s_client -connect gitlab.example.com:443 2>/dev/null | openssl x509 -noout -dates

# 6. GitLab 버전 확인
echo "📦 GitLab 버전:"
sudo gitlab-rake gitlab:env:info | grep "GitLab information"

# 7. 디스크 사용량 확인
echo "💾 디스크 사용량:"
df -h | grep -E "Filesystem|/var/opt/gitlab"

echo "=== 검증 완료 ==="
```

</details>

---

## 🔍 **STEP 5: 설치 검증 및 헬스체크**

<details open>
<summary><strong>✅ 전체 시스템 검증 (클릭하여 펼치기/접기)</strong></summary>

### 📊 종합 헬스체크 스크립트

```bash
#!/bin/bash
# GitLab 종합 헬스체크 스크립트
# 실행: sudo bash gitlab-healthcheck.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== GitLab 종합 헬스체크 ===${NC}\n"

# 1. 시스템 리소스 확인
echo -e "${YELLOW}[1/8] 시스템 리소스 확인${NC}"
echo "CPU 사용률:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F% '{print $1"%"}'
echo "메모리 사용률:"
free -h | grep Mem | awk '{print $3 "/" $2}'
echo "디스크 사용률:"
df -h / | tail -1 | awk '{print $5 " (" $3 "/" $2 ")"}'
echo ""

# 2. GitLab 서비스 상태
echo -e "${YELLOW}[2/8] GitLab 서비스 상태${NC}"
gitlab-ctl status
echo ""

# 3. PostgreSQL 연결 테스트
echo -e "${YELLOW}[3/8] PostgreSQL 연결 테스트${NC}"
if gitlab-psql -d gitlabhq_production -c "SELECT version();" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PostgreSQL 연결 정상${NC}"
else
    echo -e "${RED}❌ PostgreSQL 연결 실패${NC}"
fi
echo ""

# 4. Redis 연결 테스트
echo -e "${YELLOW}[4/8] Redis 연결 테스트${NC}"
if gitlab-redis-cli ping | grep -q "PONG"; then
    echo -e "${GREEN}✅ Redis 연결 정상${NC}"
else
    echo -e "${RED}❌ Redis 연결 실패${NC}"
fi
echo ""

# 5. 웹 서비스 응답 테스트
echo -e "${YELLOW}[5/8] 웹 서비스 응답 테스트${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 301 ] || [ "$HTTP_CODE" -eq 302 ]; then
    echo -e "${GREEN}✅ 웹 서비스 응답 정상 (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ 웹 서비스 응답 실패 (HTTP $HTTP_CODE)${NC}"
fi
echo ""

# 6. GitLab 내부 진단
echo -e "${YELLOW}[6/8] GitLab 내부 진단${NC}"
gitlab-rake gitlab:check SANITIZE=true
echo ""

# 7. 저장소 무결성 검사 (샘플)
echo -e "${YELLOW}[7/8] Git 저장소 무결성 검사${NC}"
gitlab-rake gitlab:git:fsck
echo ""

# 8. 로그 오류 확인
echo -e "${YELLOW}[8/8] 최근 로그 오류 확인${NC}"
echo "최근 10개 오류 로그:"
sudo grep -i "error" /var/log/gitlab/gitlab-rails/production.log | tail -10
echo ""

# 요약
echo -e "${GREEN}=== 헬스체크 완료 ===${NC}"
echo "자세한 내용은 /var/log/gitlab/ 디렉토리의 로그 파일을 확인하세요."
```

### 🔧 개별 컴포넌트 테스트

#### Gitaly (Git 저장소 서비스)

```bash
# Gitaly 상태 확인
sudo gitlab-ctl status gitaly

# Gitaly 로그 확인
sudo gitlab-ctl tail gitaly

# Gitaly 연결 테스트
gitlab-rake gitlab:gitaly:check
```

#### Sidekiq (백그라운드 작업)

```bash
# Sidekiq 큐 확인
gitlab-rails runner "puts Sidekiq::Queue.all.map(&:name)"

# Sidekiq 작업 통계
gitlab-rails runner "puts Sidekiq::Stats.new"

# 실행 중인 작업 수
gitlab-rails runner "puts Sidekiq::ProcessSet.new.size"
```

#### Container Registry

```bash
# Container Registry 활성화 확인
gitlab-rails runner "puts Gitlab.config.registry.enabled"

# Registry 저장소 확인
sudo ls -lh /var/opt/gitlab/gitlab-rails/shared/registry

# Registry 헬스체크
curl -s http://localhost:5000/v2/ | jq
```

### 📈 성능 벤치마크

```bash
# API 응답 시간 테스트
time curl -H "PRIVATE-TOKEN: your-token" \
  http://gitlab.example.com/api/v4/projects

# Git Clone 속도 테스트
time git clone http://gitlab.example.com/test-group/test-project.git /tmp/test

# 동시 접속 테스트 (Apache Bench)
ab -n 100 -c 10 http://gitlab.example.com/

# 예상 출력:
# Requests per second: 50.23 [#/sec] (mean)
# Time per request: 199.1 [ms] (mean)
```

</details>

---

## 🚨 **STEP 6: 트러블슈팅 가이드**

<details open>
<summary><strong>⚠️ 일반적인 문제 및 해결 방법 (클릭하여 펼치기/접기)</strong></summary>

### 📋 문제별 해결 매트릭스

| 증상 | 가능한 원인 | 진단 명령어 | 해결 방법 |
|------|------------|------------|----------|
| **502 Bad Gateway** | Unicorn/Puma 미시작 | `gitlab-ctl status` | `gitlab-ctl restart` |
| **503 Service Unavailable** | 시스템 과부하 | `top`, `free -h` | 리소스 증설 또는 재시작 |
| **Git Push 실패** | Gitaly 오류 | `gitlab-ctl tail gitaly` | `gitlab-ctl restart gitaly` |
| **이메일 미발송** | SMTP 설정 오류 | `/var/log/gitlab/gitlab-rails/production.log` | SMTP 설정 재확인 |
| **디스크 가득 참** | 로그/백업 과다 | `df -h`, `du -sh /var/opt/gitlab/*` | 로그 정리, 백업 이전 |
| **PostgreSQL 연결 실패** | DB 서비스 중단 | `gitlab-ctl status postgresql` | `gitlab-ctl restart postgresql` |
| **느린 응답 속도** | 메모리 부족 | `free -h`, `vmstat 1` | Swap 추가 또는 RAM 증설 |
| **SSL 인증서 오류** | 인증서 만료/경로 오류 | `openssl s_client -connect :443` | 인증서 갱신 또는 경로 수정 |

### 🔍 진단 워크플로우

```bash
#!/bin/bash
# GitLab 자동 진단 스크립트

echo "=== GitLab 자동 진단 시작 ==="

# Step 1: 서비스 상태 확인
echo "[1] 서비스 상태 확인"
STOPPED_SERVICES=$(gitlab-ctl status | grep "down:" | wc -l)
if [ $STOPPED_SERVICES -gt 0 ]; then
    echo "⚠️  중단된 서비스 발견: $STOPPED_SERVICES개"
    gitlab-ctl status | grep "down:"
    read -p "모든 서비스를 재시작하시겠습니까? (y/n): " RESTART
    if [ "$RESTART" = "y" ]; then
        gitlab-ctl restart
    fi
else
    echo "✅ 모든 서비스 정상 실행 중"
fi

# Step 2: 리소스 사용률 확인
echo "[2] 리소스 사용률 확인"
MEM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}' | cut -d. -f1)
if [ $MEM_USAGE -gt 90 ]; then
    echo "⚠️  메모리 사용률 높음: ${MEM_USAGE}%"
    echo "실행 중인 프로세스:"
    ps aux --sort=-%mem | head -10
fi

DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 85 ]; then
    echo "⚠️  디스크 사용률 높음: ${DISK_USAGE}%"
    echo "큰 디렉토리 TOP 5:"
    du -sh /var/opt/gitlab/* 2>/dev/null | sort -h | tail -5
fi

# Step 3: 로그 오류 검사
echo "[3] 최근 오류 로그 검사"
ERROR_COUNT=$(grep -i "error\|fatal\|exception" /var/log/gitlab/gitlab-rails/production.log 2>/dev/null | tail -100 | wc -l)
if [ $ERROR_COUNT -gt 10 ]; then
    echo "⚠️  최근 100줄에서 ${ERROR_COUNT}개 오류 발견"
    echo "최근 오류 5건:"
    grep -i "error\|fatal" /var/log/gitlab/gitlab-rails/production.log | tail -5
else
    echo "✅ 심각한 오류 없음"
fi

# Step 4: 데이터베이스 연결 확인
echo "[4] 데이터베이스 연결 확인"
if gitlab-psql -d gitlabhq_production -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ PostgreSQL 연결 정상"
else
    echo "❌ PostgreSQL 연결 실패"
    gitlab-ctl restart postgresql
fi

# Step 5: 웹 서비스 응답 확인
echo "[5] 웹 서비스 응답 확인"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "✅ 웹 서비스 응답 정상 (HTTP $HTTP_CODE)"
else
    echo "❌ 웹 서비스 응답 비정상 (HTTP $HTTP_CODE)"
    echo "Nginx 로그 확인:"
    tail -20 /var/log/gitlab/nginx/error.log
fi

echo "=== 진단 완료 ==="
```

### 🛠️ 긴급 복구 절차

#### 시나리오 1: GitLab이 완전히 응답 없음

```bash
# 1단계: 모든 서비스 중지
sudo gitlab-ctl stop

# 2단계: 프로세스 확인
ps aux | grep gitlab

# 3단계: 강제 종료 (필요시)
sudo pkill -9 -f gitlab

# 4단계: 시스템 정리
sudo gitlab-ctl cleanse
sudo gitlab-ctl reconfigure

# 5단계: 재시작
sudo gitlab-ctl start

# 6단계: 검증
sudo gitlab-ctl status
sudo gitlab-rake gitlab:check
```

#### 시나리오 2: 디스크 가득 참 긴급 대응

```bash
# 1. 즉시 공간 확보 (로그 정리)
sudo find /var/log/gitlab -name "*.log" -type f -mtime +7 -delete
sudo gitlab-ctl reconfigure

# 2. 오래된 백업 삭제
sudo find /var/opt/gitlab/backups -name "*.tar" -type f -mtime +30 -delete

# 3. Docker 이미지 정리 (Docker 설치 시)
docker system prune -a --volumes -f

# 4. Git 저장소 가비지 컬렉션
sudo gitlab-rake gitlab:cleanup:repos

# 5. 디스크 사용량 재확인
df -h
```

#### 시나리오 3: 데이터베이스 손상

```bash
# 1. 백업에서 복구 (최신 백업 사용)
sudo gitlab-backup restore BACKUP=timestamp_of_backup

# 2. PostgreSQL 무결성 검사
sudo -u gitlab-psql /opt/gitlab/embedded/bin/psql -d gitlabhq_production -c "REINDEX DATABASE gitlabhq_production;"

# 3. GitLab 재구성
sudo gitlab-ctl reconfigure

# 4. 검증
sudo gitlab-rake gitlab:check
```

### 📞 에스컬레이션 가이드

```markdown
## 문제 해결 우선순위

### Level 1: 자동 진단 스크립트 실행 (5분)
- 위의 자동 진단 스크립트 실행
- 기본 재시작 시도

### Level 2: 로그 분석 (15분)
- /var/log/gitlab/ 디렉토리 로그 확인
- 최근 변경사항 롤백 시도

### Level 3: 백업에서 복구 (30분)
- 최신 백업 확인
- 테스트 환경에서 복구 테스트
- 프로덕션 복구 결정

### Level 4: 전문가 지원 요청 (즉시)
- GitLab Support 티켓 생성
- 커뮤니티 포럼 질문
- 로그 파일 첨부 (/var/log/gitlab/)
```

</details>

---

## 📊 **STEP 7: 설치 후 최적화**

<details>
<summary><strong>⚡ 성능 최적화 설정 (클릭하여 펼치기/접기)</strong></summary>

### 🎯 Puma Worker 설정 (웹 서비스 성능)

```ruby
# /etc/gitlab/gitlab.rb

# CPU 코어 기반 자동 계산
# Workers = (CPU cores - 1), 최소 2
puma['worker_processes'] = 4  # 8 CPU 코어 서버 기준

# Worker당 스레드 수
puma['min_threads'] = 4
puma['max_threads'] = 4

# Worker 메모리 제한 (MB)
puma['worker_memory_limit_min'] = "1024"
puma['worker_memory_limit_max'] = "1280"

# 적용
sudo gitlab-ctl reconfigure
```

### 💾 PostgreSQL 튜닝

```ruby
# /etc/gitlab/gitlab.rb

# Shared buffers (RAM의 25%)
postgresql['shared_buffers'] = "4GB"  # 16GB RAM 서버 기준

# Effective cache size (RAM의 50%)
postgresql['effective_cache_size'] = "8GB"

# Work memory (연결당 메모리)
postgresql['work_mem'] = "16MB"

# Maintenance work memory
postgresql['maintenance_work_mem'] = "256MB"

# 동시 연결 수
postgresql['max_connections'] = 300

# 적용
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart postgresql
```

### 🚀 Redis 최적화

```ruby
# /etc/gitlab/gitlab.rb

# Redis 메모리 제한
redis['maxmemory'] = "2gb"
redis['maxmemory_policy'] = "allkeys-lru"

# 영속성 설정 (성능 우선)
redis['save'] = []
redis['appendonly'] = 'no'

# 적용
sudo gitlab-ctl reconfigure
```

### 📦 Sidekiq 동시성 설정

```ruby
# /etc/gitlab/gitlab.rb

# Sidekiq 프로세스 수
sidekiq['concurrency'] = 25  # 기본값, CPU 코어 수에 맞춰 조정

# 적용
sudo gitlab-ctl reconfigure
```

### 🗜️ Git 저장소 압축 및 최적화

```bash
# 모든 저장소 최적화 (주간 Cron 작업 권장)
sudo gitlab-rake gitlab:cleanup:repos

# 개별 저장소 최적화
cd /var/opt/gitlab/git-data/repositories/<group>/<project>.git
sudo -u git git gc --aggressive
sudo -u git git repack -Ad
```

</details>

---

## 📚 **STEP 8: 다음 단계 및 학습 리소스**

<details open>
<summary><strong>🎓 구축 완료 후 할 일 (클릭하여 펼치기/접기)</strong></summary>

### ✅ 구축 완료 체크리스트

```markdown
- [ ] GitLab 설치 완료 및 웹 UI 접근 확인
- [ ] 초기 root 비밀번호 변경
- [ ] HTTPS/SSL 인증서 설정
- [ ] 방화벽 규칙 적용
- [ ] 자동 백업 구성 및 테스트
- [ ] 모니터링 설정 (Prometheus/Grafana)
- [ ] 이메일 알림 테스트
- [ ] 첫 번째 프로젝트 생성
- [ ] CI/CD Runner 설치 및 등록
- [ ] 사용자 계정 생성 및 권한 설정
```

### 📖 다음 단계: 운영(Operations)

구축이 완료되었으니 이제 **운영 가이드**로 넘어갈 차례입니다:

1. **백업/복구 전략** 상세 설계
2. **모니터링 대시보드** 구성
3. **업그레이드 절차** 수립
4. **사용자 관리** 정책 설정
5. **장애 대응 플레이북** 작성

### 🔗 유용한 리소스

```markdown
## 공식 문서
- GitLab 공식 문서: https://docs.gitlab.com/
- 설치 가이드: https://docs.gitlab.com/ee/install/
- 아키텍처 개요: https://docs.gitlab.com/ee/development/architecture.html

## 커뮤니티
- GitLab Forum: https://forum.gitlab.com/
- Reddit: r/gitlab
- Stack Overflow: [gitlab] 태그

## 학습 자료
- GitLab Learn: https://about.gitlab.com/learn/
- YouTube GitLab 채널
- GitLab 블로그: https://about.gitlab.com/blog/
```

</details>

---

## 🎯 [4단계] 최종 요약

### 💡 핵심 결론

| 단계 | 주요 작업 | 예상 소요 시간 | 완료 확인 |
|------|----------|---------------|----------|
| **1. 요구사항 분석** | 하드웨어 스펙 결정 | 30분 | ✅ 체크리스트 완료 |
| **2. 설치 방법 선택** | Omnibus/Docker/K8s 결정 | 15분 | ✅ 환경 선택 완료 |
| **3. GitLab 설치** | 실제 설치 수행 | 10-30분 | ✅ 웹 UI 접근 가능 |
| **4. 보안 강화** | HTTPS, 방화벽, 백업 | 1시간 | ✅ 보안 검증 통과 |
| **5. 헬스체크** | 전체 시스템 검증 | 20분 | ✅ 모든 테스트 통과 |
| **6. 최적화** | 성능 튜닝 | 30분 | ✅ 벤치마크 정상 |

### 🚀 행동 계획

```markdown
## 즉시 실행 (오늘)
- [ ] 설치 방법 최종 결정
- [ ] 하드웨어/클라우드 리소스 준비
- [ ] GitLab 설치 실행

## 이번 주 내
- [ ] HTTPS 인증서 설정
- [ ] 백업 자동화 구성
- [ ] 모니터링 설정
- [ ] 첫 번째 프로젝트 생성

## 다음 주
- [ ] CI/CD Runner 구성
- [ ] 사용자 교육 자료 준비
- [ ] 운영 가이드 학습 시작
```

### 📞 추가 지원이 필요하신가요?

```markdown
다음 단계를 진행하고 싶으시다면 선택하세요:

A. 특정 설치 방법의 상세 가이드 (예: Kubernetes HA 구성 상세)
B. 트러블슈팅 심화 (특정 오류 해결)
C. 운영(Operations) 가이드로 진행
D. 사용자 활용(Team Usage) 가이드로 진행
E. 특정 질문 (예: "LDAP 통합 방법", "멀티 Runner 구성" 등)
```

---

**🎉 축하합니다!** GitLab 구축을 완료하셨습니다!  
이제 **운영** 단계로 넘어가거나, 특정 부분에 대한 심화 가이드를 요청하실 수 있습니다.

어떤 부분을 더 알고 싶으신가요? 😊

---------------------------------------------------------------------


# GitLab 운영(Operations) 완전 가이드

## 🧠 적용된 사고 공식

이번 답변을 위해 다음 공식들을 조합했습니다:

### 1. **복잡도 해결 매트릭스 (CS)**
- 운영을 **백업 → 모니터링 → 업그레이드 → 사용자 관리 → 장애 대응**의 하위 시스템으로 분해
- 각 시스템 간 상호작용 계수 파악 (예: 백업 실패 → 모니터링 알림 → 장애 대응)

### 2. **사고 진화 방정식 (TE)**
- 학습(L): 각 운영 작업의 Best Practice
- 경험(E): 실제 장애 시나리오 학습
- 성찰(R): 사후 분석(Post-mortem) 프로세스

### 3. **통합 지혜 공식 (IW)**
- 지식(K): 운영 도구 및 명령어
- 실행(A): 자동화 스크립트 제공
- 윤리(E): 데이터 보호 및 가용성 보장

---

## 🧭 [1단계] 사전 브리핑 요약

### 배경
GitLab 운영은 **시스템 안정성, 데이터 무결성, 서비스 가용성**을 보장하는 핵심 활동입니다:
- 백업: 데이터 손실 방지
- 모니터링: 문제 조기 발견
- 업그레이드: 보안 패치 및 기능 개선
- 사용자 관리: 접근 제어 및 라이선스
- 장애 대응: 신속한 복구

### 범위
```
🔧 운영 영역
├── 1️⃣ 백업/복구 전략 (RTO/RPO 설계)
├── 2️⃣ 모니터링 및 알림 (Prometheus/Grafana)
├── 3️⃣ 업그레이드 및 패치 (무중단 전략)
├── 4️⃣ 사용자/그룹/권한 관리
├── 5️⃣ 로그 관리 및 분석
└── 6️⃣ 장애 대응 플레이북
```

---

## ❓ [2단계] 핵심 질문

**Q1**: 어떻게 데이터를 안전하게 백업하고 빠르게 복구하나?  
**Q2**: 시스템 문제를 어떻게 사전에 감지하나?  
**Q3**: 다운타임 없이 업그레이드하는 방법은?  
**Q4**: 장애 발생 시 초기 대응 절차는?

---

## ✅ [3단계] 답변 - 단계별 운영 가이드

---

## 💾 **PART 1: 백업 및 복구 전략**

<details open>
<summary><strong>📋 백업 전략 설계 (클릭하여 펼치기/접기)</strong></summary>

### 🎯 RTO/RPO 정의

| 복구 목표 | 정의 | 권장 값 | 구현 방법 |
|----------|------|---------|----------|
| **RTO** (Recovery Time Objective) | 복구 목표 시간 | 1-4시간 | 자동화된 복구 스크립트 |
| **RPO** (Recovery Point Objective) | 복구 목표 시점 | 1-24시간 | 백업 주기 설정 |

### 📊 백업 대상 항목

```yaml
GitLab 백업 포함 항목:
  필수:
    - 데이터베이스 (PostgreSQL)
    - Git 저장소 (repositories)
    - 위키 페이지
    - 첨부 파일 (uploads)
    - CI/CD artifacts
    - LFS 객체
    - Container Registry 이미지
  
  별도 백업 필요:
    - /etc/gitlab/gitlab.rb (설정 파일)
    - /etc/gitlab/gitlab-secrets.json (암호화 키)
    - SSL 인증서
```

</details>

### 🔧 **1-1. 로컬 백업 설정 (Omnibus)**

<details open>
<summary><strong>💻 로컬 디스크 백업 (클릭하여 보기)</strong></summary>

```bash
#!/bin/bash
# GitLab 백업 설정 스크립트

# 1. 백업 디렉토리 생성 및 권한 설정
sudo mkdir -p /var/opt/gitlab/backups
sudo chown git:git /var/opt/gitlab/backups
sudo chmod 700 /var/opt/gitlab/backups

# 2. gitlab.rb 편집
sudo tee -a /etc/gitlab/gitlab.rb > /dev/null <<'EOF'

### 백업 설정
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
gitlab_rails['backup_keep_time'] = 604800  # 7일 보관
gitlab_rails['backup_archive_permissions'] = 0644

# 백업에서 제외할 항목 (선택사항)
# gitlab_rails['backup_upload_remote_directory'] = 'gitlab-backups'
# gitlab_rails['env'] = {
#   "SKIP" => "db,uploads,repositories,builds,artifacts,lfs,registry,pages"
# }
EOF

# 3. 설정 적용
sudo gitlab-ctl reconfigure

# 4. 수동 백업 실행 테스트
echo "=== 백업 테스트 시작 ==="
sudo gitlab-backup create

# 5. 백업 파일 확인
echo "=== 생성된 백업 파일 ==="
ls -lh /var/opt/gitlab/backups/

# 6. Cron 작업 추가 (매일 02:00)
echo "=== Cron 작업 추가 ==="
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1") | crontab -

echo "✅ 백업 설정 완료"
```

### ✅ 백업 검증

```bash
# 백업 파일 무결성 확인
sudo gitlab-backup create BACKUP=test_backup

# 백업 파일 크기 확인
ls -lh /var/opt/gitlab/backups/ | tail -5

# 백업 로그 확인
sudo tail -f /var/log/gitlab/gitlab-rails/production.log
```

</details>

### ☁️ **1-2. 클라우드 백업 (AWS S3 / GCP / Azure)**

<details open>
<summary><strong>🌩️ AWS S3 백업 설정 (클릭하여 보기)</strong></summary>

```ruby
# /etc/gitlab/gitlab.rb

### AWS S3 백업 설정
gitlab_rails['backup_upload_connection'] = {
  'provider' => 'AWS',
  'region' => 'ap-northeast-2',  # 서울 리전
  'aws_access_key_id' => 'YOUR_AWS_ACCESS_KEY',
  'aws_secret_access_key' => 'YOUR_AWS_SECRET_KEY',
  # IAM Role 사용 시 (권장)
  'use_iam_profile' => true
}

gitlab_rails['backup_upload_remote_directory'] = 'gitlab-backups-bucket'

# 백업 암호화
gitlab_rails['backup_encryption'] = 'AES256'

# 업로드 후 로컬 백업 삭제
gitlab_rails['backup_upload_delete_local_backup'] = true

# 멀티파트 업로드 설정 (대용량 백업)
gitlab_rails['backup_multipart_chunk_size'] = 104857600  # 100MB
```

### 📦 GCP Cloud Storage 백업

```ruby
# /etc/gitlab/gitlab.rb

gitlab_rails['backup_upload_connection'] = {
  'provider' => 'Google',
  'google_project' => 'your-project-id',
  'google_json_key_location' => '/path/to/service-account-key.json'
}

gitlab_rails['backup_upload_remote_directory'] = 'gitlab-backups-bucket'
```

### 🔷 Azure Blob Storage 백업

```ruby
# /etc/gitlab/gitlab.rb

gitlab_rails['backup_upload_connection'] = {
  'provider' => 'AzureRM',
  'azure_storage_account_name' => 'your-storage-account',
  'azure_storage_access_key' => 'YOUR_AZURE_KEY',
  'environment' => 'AzureCloud'
}

gitlab_rails['backup_upload_remote_directory'] = 'gitlab-backups'
```

### 적용 및 테스트

```bash
# 설정 적용
sudo gitlab-ctl reconfigure

# S3 백업 테스트
sudo gitlab-backup create

# S3 버킷 확인
aws s3 ls s3://gitlab-backups-bucket/

# 백업 로그 확인
sudo grep -i "Uploading backup archive to remote storage" /var/log/gitlab/gitlab-rails/production.log
```

</details>

### 🔄 **1-3. 복구 절차 (Disaster Recovery)**

<details open>
<summary><strong>🚑 백업에서 복구하기 (클릭하여 보기)</strong></summary>

### 📋 복구 사전 준비

```markdown
## 복구 전 체크리스트
- [ ] GitLab 버전 확인 (백업 버전과 동일해야 함)
- [ ] 복구할 백업 파일 준비
- [ ] gitlab-secrets.json 파일 보관 확인
- [ ] 충분한 디스크 공간 확보
- [ ] 사용자에게 서비스 중단 공지
```

### 🛠️ 복구 스크립트

```bash
#!/bin/bash
# GitLab 복구 스크립트
# 실행: sudo bash gitlab-restore.sh <BACKUP_TIMESTAMP>

set -e

BACKUP_TIMESTAMP=$1

if [ -z "$BACKUP_TIMESTAMP" ]; then
    echo "사용법: $0 <BACKUP_TIMESTAMP>"
    echo "예시: $0 1638345600_2024_09_30_16.5.0"
    exit 1
fi

echo "=== GitLab 복구 시작 ==="
echo "백업 타임스탬프: $BACKUP_TIMESTAMP"

# 1. 모든 GitLab 서비스 중지 (PostgreSQL, Redis 제외)
echo "[1/6] GitLab 서비스 중지 중..."
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

# 2. 백업 파일 확인
echo "[2/6] 백업 파일 확인 중..."
BACKUP_FILE="/var/opt/gitlab/backups/${BACKUP_TIMESTAMP}_gitlab_backup.tar"
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ 백업 파일을 찾을 수 없습니다: $BACKUP_FILE"
    echo "사용 가능한 백업 파일:"
    ls -lh /var/opt/gitlab/backups/
    exit 1
fi

echo "✅ 백업 파일 확인: $BACKUP_FILE"

# 3. 백업에서 복구
echo "[3/6] 데이터 복구 중 (시간 소요 예상)..."
gitlab-backup restore BACKUP=$BACKUP_TIMESTAMP force=yes

# 4. gitlab-secrets.json 복원 (중요!)
echo "[4/6] 암호화 키 복원 중..."
if [ -f "/root/gitlab-secrets.json.backup" ]; then
    cp /root/gitlab-secrets.json.backup /etc/gitlab/gitlab-secrets.json
    chmod 0600 /etc/gitlab/gitlab-secrets.json
    echo "✅ gitlab-secrets.json 복원 완료"
else
    echo "⚠️  gitlab-secrets.json 백업을 찾을 수 없습니다!"
fi

# 5. GitLab 재구성
echo "[5/6] GitLab 재구성 중..."
gitlab-ctl reconfigure

# 6. 서비스 재시작
echo "[6/6] 서비스 재시작 중..."
gitlab-ctl restart

# 7. 헬스체크
echo "=== 복구 검증 ==="
sleep 10
gitlab-ctl status
gitlab-rake gitlab:check SANITIZE=true

echo "✅ 복구 완료!"
echo "웹 브라우저에서 GitLab에 접속하여 확인하세요."
```

### 🔍 복구 검증

```bash
# 1. 서비스 상태 확인
sudo gitlab-ctl status

# 2. 데이터 무결성 검사
sudo gitlab-rake gitlab:check

# 3. Git 저장소 검증
sudo gitlab-rake gitlab:git:fsck

# 4. 특정 프로젝트 접근 테스트
# 웹 UI에서 프로젝트 목록 확인
# Git clone 테스트
git clone http://gitlab.example.com/test-group/test-project.git /tmp/test-restore

# 5. 사용자 로그인 테스트
echo "사용자 계정으로 로그인하여 데이터 확인"
```

### ⚠️ 복구 시 일반적인 문제

| 증상 | 원인 | 해결 방법 |
|------|------|----------|
| **복구 실패: 버전 불일치** | 백업 버전 ≠ 현재 버전 | 동일 버전으로 재설치 후 복구 |
| **암호화 오류** | gitlab-secrets.json 없음 | 원본 secrets 파일 복원 필수 |
| **저장소 접근 불가** | 권한 문제 | `chown -R git:git /var/opt/gitlab/` |
| **CI/CD 작동 안 함** | Runner 재등록 필요 | Runner 토큰 재발급 및 등록 |

</details>

### 🧪 **1-4. DR(재해복구) 훈련**

<details>
<summary><strong>🎯 DR 훈련 시나리오 (클릭하여 보기)</strong></summary>

```bash
#!/bin/bash
# GitLab DR 훈련 스크립트 (테스트 환경에서 실행)

echo "=== GitLab DR 훈련 시작 ==="

# 시나리오 1: 전체 시스템 장애 복구
echo "[시나리오 1] 전체 시스템 장애 가정"
START_TIME=$(date +%s)

# 1-1. 백업 생성
echo "1-1. 백업 생성 중..."
gitlab-backup create

# 1-2. 모든 서비스 중지
echo "1-2. 서비스 중지 (장애 시뮬레이션)..."
gitlab-ctl stop

# 1-3. 최신 백업으로 복구
echo "1-3. 복구 시작..."
LATEST_BACKUP=$(ls -t /var/opt/gitlab/backups/*.tar | head -1 | sed 's/.*\///;s/_gitlab_backup.tar//')
gitlab-ctl start postgresql redis
gitlab-backup restore BACKUP=$LATEST_BACKUP force=yes

# 1-4. 서비스 재시작
echo "1-4. 서비스 재시작..."
gitlab-ctl restart

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "✅ 시나리오 1 완료"
echo "복구 소요 시간: $DURATION 초"
echo "RTO 목표(4시간 = 14400초) 달성 여부: $([ $DURATION -lt 14400 ] && echo '✅ 달성' || echo '❌ 미달성')"

# 시나리오 2: 데이터베이스만 복구
echo ""
echo "[시나리오 2] PostgreSQL 장애 가정"
# (생략 - 실제 환경에 맞게 작성)

# 훈련 보고서 생성
cat > /tmp/dr-drill-report.txt <<EOF
=== GitLab DR 훈련 보고서 ===
실행 일시: $(date)
RTO 목표: 4시간 (14400초)
실제 복구 시간: $DURATION 초
결과: $([ $DURATION -lt 14400 ] && echo '✅ 목표 달성' || echo '❌ 목표 미달성')

개선 사항:
- [ ] 복구 스크립트 자동화 강화
- [ ] 백업 파일 위치 명확화
- [ ] 복구 절차 문서 업데이트
- [ ] 팀원 복구 훈련 실시
EOF

cat /tmp/dr-drill-report.txt
```

</details>

---

## 📊 **PART 2: 모니터링 및 알림 시스템**

<details open>
<summary><strong>🔍 Prometheus + Grafana 구성 (클릭하여 펼치기/접기)</strong></summary>

### 🎯 모니터링 아키텍처

```
GitLab 서버
├── Prometheus Exporter (내장)
│   ├── Node Exporter (시스템 메트릭)
│   ├── PostgreSQL Exporter
│   ├── Redis Exporter
│   └── GitLab Exporter (커스텀 메트릭)
│
├── Prometheus Server (메트릭 수집)
│
└── Grafana (대시보드 시각화)
```

</details>

### 📈 **2-1. Prometheus 설정**

<details open>
<summary><strong>⚙️ Prometheus 활성화 (클릭하여 보기)</strong></summary>

```ruby
# /etc/gitlab/gitlab.rb

### Prometheus 설정
prometheus['enable'] = true
prometheus['listen_address'] = '0.0.0.0:9090'
prometheus['monitor_kubernetes'] = false

# 데이터 보존 기간
prometheus['retention_time'] = '15d'
prometheus['retention_size'] = '10GB'

# Node Exporter (시스템 메트릭)
node_exporter['enable'] = true
node_exporter['listen_address'] = '0.0.0.0:9100'

# PostgreSQL Exporter
postgres_exporter['enable'] = true
postgres_exporter['listen_address'] = '0.0.0.0:9187'

# Redis Exporter
redis_exporter['enable'] = true
redis_exporter['listen_address'] = '0.0.0.0:9121'

# GitLab Exporter (커스텀 메트릭)
gitlab_exporter['enable'] = true
gitlab_exporter['listen_address'] = '0.0.0.0:9168'
```

```bash
# 설정 적용
sudo gitlab-ctl reconfigure

# Prometheus 상태 확인
sudo gitlab-ctl status prometheus

# Prometheus UI 접속
# 브라우저: http://gitlab.example.com:9090
```

### 📊 핵심 메트릭 쿼리

```yaml
# Prometheus 쿼리 예제

# 1. CPU 사용률
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# 2. 메모리 사용률
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# 3. 디스크 사용률
(1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100

# 4. HTTP 응답 시간 (95 percentile)
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))

# 5. GitLab 활성 사용자 수
gitlab_database_rows{table="users",state="active"}

# 6. CI/CD 파이프라인 대기 시간
avg(gitlab_runner_jobs_queue_duration_seconds)

# 7. PostgreSQL 연결 수
pg_stat_database_numbackends

# 8. Redis 메모리 사용량
redis_memory_used_bytes
```

</details>

### 📉 **2-2. Grafana 대시보드 구성**

<details open>
<summary><strong>📊 Grafana 설치 및 설정 (클릭하여 보기)</strong></summary>

```bash
#!/bin/bash
# Grafana 설치 스크립트 (Ubuntu/Debian)

# 1. Grafana 저장소 추가
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# 2. Grafana 설치
sudo apt-get update
sudo apt-get install -y grafana

# 3. Grafana 시작 및 자동 시작 설정
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# 4. 상태 확인
sudo systemctl status grafana-server

echo "✅ Grafana 설치 완료"
echo "접속 주소: http://localhost:3000"
echo "초기 계정: admin / admin"
```

### 🔗 Prometheus 데이터 소스 추가

```bash
# Grafana UI에서 설정:
# 1. Settings → Data Sources → Add data source
# 2. Prometheus 선택
# 3. URL: http://localhost:9090
# 4. Save & Test
```

### 📊 GitLab 대시보드 Import

```json
{
  "dashboard": {
    "title": "GitLab Monitoring",
    "panels": [
      {
        "title": "CPU Usage",
        "targets": [
          {
            "expr": "100 - (avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"
          }
        ]
      },
      {
        "title": "Active Users",
        "targets": [
          {
            "expr": "gitlab_database_rows{table=\"users\",state=\"active\"}"
          }
        ]
      },
      {
        "title": "HTTP Response Time (p95)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))"
          }
        ]
      }
    ]
  }
}
```

### 📥 공식 대시보드 Import

```markdown
## Grafana 공식 GitLab 대시보드
1. Grafana UI → Dashboards → Import
2. Dashboard ID 입력: **14658** (GitLab Overview)
3. Load → Prometheus 데이터 소스 선택 → Import

추천 대시보드:
- **14658**: GitLab Overview
- **1860**: Node Exporter Full
- **9628**: PostgreSQL Database
- **11835**: Redis
```

</details>

### 🔔 **2-3. 알림(Alerting) 설정**

<details open>
<summary><strong>⚠️ Prometheus Alertmanager 구성 (클릭하여 보기)</strong></summary>

```ruby
# /etc/gitlab/gitlab.rb

### Alertmanager 설정
alertmanager['enable'] = true
alertmanager['listen_address'] = '0.0.0.0:9093'

# 알림 규칙 파일 경로
prometheus['alertmanager_url'] = ['http://localhost:9093']
```

### 📋 알림 규칙 정의

```yaml
# /var/opt/gitlab/prometheus/rules/gitlab.rules.yml

groups:
  - name: gitlab_alerts
    interval: 30s
    rules:
      # 1. CPU 사용률 높음 (80% 초과 5분)
      - alert: HighCPUUsage
        expr: 100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% (current: {{ $value }}%)"

      # 2. 메모리 사용률 높음 (90% 초과)
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 90% (current: {{ $value }}%)"

      # 3. 디스크 사용률 높음 (85% 초과)
      - alert: HighDiskUsage
        expr: (1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100 > 85
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High disk usage detected"
          description: "Disk usage is above 85% (current: {{ $value }}%)"

      # 4. GitLab 서비스 다운
      - alert: GitLabDown
        expr: up{job="gitlab"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "GitLab service is down"
          description: "GitLab has been unreachable for more than 2 minutes"

      # 5. PostgreSQL 연결 수 높음
      - alert: HighPostgreSQLConnections
        expr: sum(pg_stat_database_numbackends) > 250
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High PostgreSQL connections"
          description: "PostgreSQL connections: {{ $value }}"

      # 6. CI/CD 파이프라인 대기 시간 길음
      - alert: HighPipelineQueueTime
        expr: avg(gitlab_runner_jobs_queue_duration_seconds) > 300
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "CI/CD pipeline queue time is high"
          description: "Average queue time: {{ $value }}s"

      # 7. HTTP 응답 시간 느림 (p95 > 2초)
      - alert: SlowHTTPResponse
        expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow HTTP response time"
          description: "95th percentile response time: {{ $value }}s"

      # 8. Redis 메모리 사용량 높음
      - alert: HighRedisMemory
        expr: redis_memory_used_bytes / redis_memory_max_bytes * 100 > 90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis memory usage is high"
          description: "Redis memory usage: {{ $value }}%"
```

### 📧 Slack 알림 설정

```yaml
# /var/opt/gitlab/alertmanager/alertmanager.yml

global:
  slack_api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'slack-notifications'
  
  routes:
    - match:
        severity: critical
      receiver: 'slack-critical'
      continue: true
    
    - match:
        severity: warning
      receiver: 'slack-warnings'

receivers:
  - name: 'slack-notifications'
    slack_configs:
      - channel: '#gitlab-alerts'
        title: '{{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
        
  - name: 'slack-critical'
    slack_configs:
      - channel: '#gitlab-critical'
        title: '🚨 CRITICAL: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
        color: 'danger'
        
  - name: 'slack-warnings'
    slack_configs:
      - channel: '#gitlab-warnings'
        title: '⚠️  WARNING: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
        color: 'warning'
```

### 📨 Email 알림 설정

```yaml
# /var/opt/gitlab/alertmanager/alertmanager.yml

global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'gitlab-alerts@example.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'
  smtp_require_tls: true

route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'email-notifications'

receivers:
  - name: 'email-notifications'
    email_configs:
      - to: 'devops-team@example.com'
        headers:
          Subject: '[GitLab Alert] {{ .GroupLabels.alertname }}'
        html: |
          <h2>{{ .GroupLabels.alertname }}</h2>
          <p><b>Severity:</b> {{ .CommonLabels.severity }}</p>
          <p><b>Description:</b></p>
          {{ range .Alerts }}
          <ul>
            <li>{{ .Annotations.description }}</li>
          </ul>
          {{ end }}
```

### 적용 및 테스트

```bash
# 설정 적용
sudo gitlab-ctl reconfigure

# Alertmanager 재시작
sudo gitlab-ctl restart alertmanager

# 알림 규칙 확인
sudo gitlab-ctl prometheus-alertmanager

# 테스트 알림 전송
curl -H "Content-Type: application/json" -d '[{"labels":{"alertname":"TestAlert","severity":"warning"}}]' http://localhost:9093/api/v1/alerts

# Alertmanager UI 접속
# 브라우저: http://gitlab.example.com:9093
```

</details>

---

## 🔄 **PART 3: 업그레이드 및 패치 관리**

<details open>
<summary><strong>⬆️ 안전한 업그레이드 전략 (클릭하여 펼치기/접기)</strong></summary>

### 📋 업그레이드 사전 계획

```markdown
## 업그레이드 체크리스트

### 사전 준비 (1주 전)
- [ ] 릴리스 노트 확인 (Breaking Changes)
- [ ] 업그레이드 경로 확인 (중간 버전 필요 여부)
- [ ] 테스트 환경 구성
- [ ] 백업 정책 재확인
- [ ] 다운타임 사용자 공지 (업그레이드 24시간 전)

### D-1 (하루 전)
- [ ] 전체 백업 수행 및 검증
- [ ] gitlab-secrets.json 별도 백업
- [ ] SSL 인증서 백업
- [ ] 롤백 계획 수립

### 업그레이드 당일
- [ ] 사용자 공지 (서비스 중단)
- [ ] 최종 백업
- [ ] 업그레이드 실행
- [ ] 업그레이드 검증
- [ ] 서비스 재개 공지

### 사후 점검
- [ ] 24시간 모니터링 강화
- [ ] 사용자 피드백 수집
- [ ] 업그레이드 보고서 작성
```

</details>

### 🛤️ **3-1. 업그레이드 경로 확인**

<details open>
<summary><strong>📍 버전별 업그레이드 경로 (클릭하여 보기)</strong></summary>

### GitLab 업그레이드 규칙

```yaml
업그레이드 원칙:
  1. 항상 백업 먼저
  2. 마이너 버전 순차 업그레이드 (13.0 → 13.12 → 14.0)
  3. 메이저 버전은 최종 마이너 버전 경유 필수
  4. 테스트 환경에서 먼저 시도
  5. 다운타임 최소화 전략 수립
```

### 📊 업그레이드 경로 매트릭스

| 현재 버전 | 목표 버전 | 경로 | 다운타임 |
|----------|----------|------|----------|
| **15.11** | 16.0 | 15.11 → 16.0 | 10-30분 |
| **15.0** | 16.0 | 15.0 → 15.11 → 16.0 | 20-60분 |
| **14.10** | 16.0 | 14.10 → 15.0 → 15.11 → 16.0 | 30-90분 |
| **16.x** | 17.x | 16.x → 16.11 → 17.0 → 17.x | 15-45분 |

### 🔍 현재 버전 확인

```bash
# GitLab 버전 확인
sudo gitlab-rake gitlab:env:info | grep "GitLab information"

# 또는
cat /opt/gitlab/version-manifest.txt | grep "gitlab-ce\|gitlab-ee"

# 웹 UI에서: Admin Area → Help → GitLab version
```

### 📚 업그레이드 경로 계산기

```bash
#!/bin/bash
# GitLab 업그레이드 경로 계산 스크립트

CURRENT_VERSION="15.5.0"
TARGET_VERSION="17.0.0"

echo "=== GitLab 업그레이드 경로 계산 ==="
echo "현재 버전: $CURRENT_VERSION"
echo "목표 버전: $TARGET_VERSION"
echo ""

# 주요 경유 버전 (예시)
echo "권장 업그레이드 경로:"
echo "1. 15.5.0 → 15.11.13 (마지막 15.x 버전)"
echo "2. 15.11.13 → 16.0.8 (16.0.x 안정 버전)"
echo "3. 16.0.8 → 16.11.10 (마지막 16.x 버전)"
echo "4. 16.11.10 → 17.0.0 (목표 버전)"
echo ""
echo "예상 총 소요 시간: 1-2시간"
echo "예상 다운타임: 30-90분"
echo ""
echo "⚠️  각 단계마다 백업 및 검증 필수!"
```

</details>

### ⚙️ **3-2. Omnibus 패키지 업그레이드**

<details open>
<summary><strong>📦 단계별 업그레이드 절차 (클릭하여 보기)</strong></summary>

```bash
#!/bin/bash
# GitLab Omnibus 업그레이드 스크립트
# 실행: sudo bash gitlab-upgrade.sh <TARGET_VERSION>

set -e

TARGET_VERSION=$1

if [ -z "$TARGET_VERSION" ]; then
    echo "사용법: $0 <TARGET_VERSION>"
    echo "예시: $0 16.0.8-ee.0"
    exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== GitLab 업그레이드 시작 ===${NC}"
echo "목표 버전: $TARGET_VERSION"
echo ""

# 1. 현재 버전 확인
echo -e "${YELLOW}[1/10] 현재 버전 확인${NC}"
CURRENT_VERSION=$(gitlab-rake gitlab:env:info | grep "GitLab" | head -1)
echo "$CURRENT_VERSION"
read -p "계속하시겠습니까? (y/n): " CONTINUE
if [ "$CONTINUE" != "y" ]; then
    echo "업그레이드 취소"
    exit 0
fi

# 2. 사전 백업
echo -e "${YELLOW}[2/10] 전체 백업 수행 중...${NC}"
gitlab-backup create
BACKUP_FILE=$(ls -t /var/opt/gitlab/backups/*.tar | head -1)
echo "백업 파일: $BACKUP_FILE"

# 3. gitlab-secrets.json 백업
echo -e "${YELLOW}[3/10] 설정 파일 백업${NC}"
cp /etc/gitlab/gitlab-secrets.json /root/gitlab-secrets.json.backup.$(date +%Y%m%d)
cp /etc/gitlab/gitlab.rb /root/gitlab.rb.backup.$(date +%Y%m%d)

# 4. 헬스체크
echo -e "${YELLOW}[4/10] 업그레이드 전 헬스체크${NC}"
gitlab-rake gitlab:check

# 5. 패키지 저장소 업데이트
echo -e "${YELLOW}[5/10] 패키지 저장소 업데이트${NC}"
apt-get update

# 6. 사용 가능한 버전 확인
echo -e "${YELLOW}[6/10] 사용 가능한 GitLab 버전${NC}"
apt-cache madison gitlab-ee | grep "$TARGET_VERSION"

# 7. 업그레이드 실행
echo -e "${YELLOW}[7/10] GitLab 업그레이드 실행 중...${NC}"
echo "⚠️  이 단계는 10-30분 소요될 수 있습니다."
apt-get install -y gitlab-ee=$TARGET_VERSION

# 8. 업그레이드 검증
echo -e "${YELLOW}[8/10] 업그레이드 검증${NC}"
sleep 30
gitlab-ctl status

# 9. 마이그레이션 확인
echo -e "${YELLOW}[9/10] 데이터베이스 마이그레이션 확인${NC}"
gitlab-rake db:migrate:status

# 10. 최종 헬스체크
echo -e "${YELLOW}[10/10] 최종 헬스체크${NC}"
gitlab-rake gitlab:check

echo -e "${GREEN}=== 업그레이드 완료 ===${NC}"
echo "새 버전: $(gitlab-rake gitlab:env:info | grep 'GitLab' | head -1)"
echo ""
echo "✅ 다음 작업을 수행하세요:"
echo "1. 웹 브라우저에서 GitLab 접속 확인"
echo "2. 주요 기능 테스트 (프로젝트, CI/CD)"
echo "3. 24시간 모니터링 강화"
```

### 🔄 롤백 절차

```bash
#!/bin/bash
# GitLab 업그레이드 롤백 스크립트

echo "=== GitLab 롤백 시작 ==="
echo "⚠️  이 작업은 신중하게 수행해야 합니다."

# 1. 이전 버전 패키지 설치
echo "[1/5] 이전 버전으로 다운그레이드 중..."
PREVIOUS_VERSION="15.11.13-ee.0"  # 실제 이전 버전으로 변경
apt-get install -y gitlab-ee=$PREVIOUS_VERSION --allow-downgrades

# 2. 백업에서 복구
echo "[2/5] 백업에서 데이터 복구 중..."
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

ROLLBACK_BACKUP="1638345600_2024_09_30_15_11_13"  # 실제 백업 타임스탬프
gitlab-backup restore BACKUP=$ROLLBACK_BACKUP force=yes

# 3. 설정 파일 복원
echo "[3/5] 설정 파일 복원 중..."
cp /root/gitlab-secrets.json.backup.* /etc/gitlab/gitlab-secrets.json
cp /root/gitlab.rb.backup.* /etc/gitlab/gitlab.rb

# 4. GitLab 재구성
echo "[4/5] GitLab 재구성 중..."
gitlab-ctl reconfigure
gitlab-ctl restart

# 5. 검증
echo "[5/5] 롤백 검증 중..."
gitlab-rake gitlab:check

echo "✅ 롤백 완료"
```

</details>

### 🐳 **3-3. Docker Compose 업그레이드**

<details>
<summary><strong>🔄 Docker 환경 업그레이드 (클릭하여 보기)</strong></summary>

```bash
#!/bin/bash
# Docker Compose GitLab 업그레이드 스크립트

TARGET_VERSION="16.0.8-ee.0"

echo "=== Docker GitLab 업그레이드 ==="

# 1. 백업
echo "[1/6] 백업 수행..."
docker exec gitlab gitlab-backup create

# 2. 현재 컨테이너 중지
echo "[2/6] 컨테이너 중지..."
docker-compose down

# 3. docker-compose.yml 수정
echo "[3/6] docker-compose.yml 수정..."
sed -i "s|image: 'gitlab/gitlab-ee:.*'|image: 'gitlab/gitlab-ee:$TARGET_VERSION'|" docker-compose.yml

# 4. 새 이미지 pull
echo "[4/6] 새 이미지 다운로드..."
docker-compose pull

# 5. 컨테이너 재시작
echo "[5/6] 컨테이너 시작..."
docker-compose up -d

# 6. 로그 모니터링
echo "[6/6] 초기화 로그 확인..."
docker-compose logs -f gitlab

echo "✅ 업그레이드 완료"
```

</details>

### ☸️ **3-4. Kubernetes Helm 업그레이드**

<details>
<summary><strong>🎯 Kubernetes 무중단 업그레이드 (클릭하여 보기)</strong></summary>

```bash
#!/bin/bash
# Kubernetes GitLab 업그레이드 스크립트

NAMESPACE="gitlab"
RELEASE_NAME="gitlab"
CHART_VERSION="7.0.0"  # Helm Chart 버전

echo "=== Kubernetes GitLab 업그레이드 ==="

# 1. 현재 버전 확인
echo "[1/7] 현재 버전 확인..."
helm list -n $NAMESPACE

# 2. 백업
echo "[2/7] 백업 수행..."
kubectl exec -n $NAMESPACE $(kubectl get pod -n $NAMESPACE -l app=task-runner -o jsonpath='{.items[0].metadata.name}') -- backup-utility

# 3. Helm 저장소 업데이트
echo "[3/7] Helm 저장소 업데이트..."
helm repo update

# 4. 새 Chart 다운로드
echo "[4/7] 새 Chart 다운로드..."
helm fetch gitlab/gitlab --version $CHART_VERSION --untar

# 5. values.yaml 검토
echo "[5/7] values.yaml 검토..."
helm show values gitlab/gitlab --version $CHART_VERSION > values-new.yaml
echo "이전 values.yaml과 비교하여 변경사항을 확인하세요."
read -p "계속하시겠습니까? (y/n): " CONTINUE

if [ "$CONTINUE" != "y" ]; then
    exit 0
fi

# 6. Helm 업그레이드 실행
echo "[6/7] Helm 업그레이드 실행..."
helm upgrade $RELEASE_NAME gitlab/gitlab \
  --version $CHART_VERSION \
  -f values-production.yaml \
  -n $NAMESPACE \
  --timeout 30m

# 7. 롤아웃 상태 확인
echo "[7/7] Pod 상태 모니터링..."
kubectl rollout status deployment/gitlab-webservice-default -n $NAMESPACE
kubectl get pods -n $NAMESPACE

echo "✅ 업그레이드 완료"
```

### Helm 롤백

```bash
# 롤백 (이전 릴리스로 복원)
helm rollback gitlab -n gitlab

# 특정 리비전으로 롤백
helm rollback gitlab 3 -n gitlab

# 롤백 히스토리 확인
helm history gitlab -n gitlab
```

</details>

---

## 👥 **PART 4: 사용자 및 권한 관리**

<details open>
<summary><strong>🔐 사용자 관리 전략 (클릭하여 펼치기/접기)</strong></summary>

### 📊 권한 모델

```yaml
GitLab 권한 레벨:
  Guest (10):
    - 이슈 생성 및 댓글
    - 프로젝트 보기
  
  Reporter (20):
    - Guest 권한 +
    - 코드 다운로드
    - 이슈 관리
  
  Developer (30):
    - Reporter 권한 +
    - 브랜치 push
    - Merge Request 생성
    - CI/CD 실행
  
  Maintainer (40):
    - Developer 권한 +
    - Protected 브랜치 관리
    - 태그 관리
    - 프로젝트 설정
  
  Owner (50):
    - Maintainer 권한 +
    - 멤버 관리
    - 프로젝트 삭제
    - 전체 설정 권한
```

</details>

### 👤 **4-1. 사용자 계정 관리**

<details open>
<summary><strong>➕ 사용자 추가 및 관리 (클릭하여 보기)</strong></summary>

```bash
#!/bin/bash
# GitLab 사용자 일괄 생성 스크립트

# CSV 파일 형식: username,email,name,password
# 예: jdoe,john@example.com,John Doe,TempPass123!

USER_CSV="users.csv"

gitlab-rails runner - <<EOF
require 'csv'

CSV.foreach('$USER_CSV', headers: false) do |row|
  username, email, name, password = row
  
  user = User.new(
    username: username,
    email: email,
    name: name,
    password: password,
    password_confirmation: password,
    password_automatically_set: false
  )
  
  user.skip_confirmation!
  
  if user.save
    puts "✅ 사용자 생성: #{username}"
  else
    puts "❌ 실패: #{username} - #{user.errors.full_messages.join(', ')}"
  end
end
EOF
```

### 🔄 사용자 상태 관리

```bash
# Rails 콘솔 접속
sudo gitlab-rails console

# 사용자 검색
user = User.find_by(username: 'jdoe')

# 사용자 차단
user.block!

# 사용자 차단 해제
user.activate!

# 사용자 삭제
user.destroy

# 모든 활성 사용자 목록
User.active.pluck(:username, :email)

# 비활성 사용자 (90일 이상 미로그인)
User.where('last_sign_in_at < ?', 90.days.ago).pluck(:username)
```

### 📧 이메일 재발송

```bash
# 확인 이메일 재발송
sudo gitlab-rails runner "user = User.find_by(username: 'jdoe'); user.send_confirmation_instructions"

# 비밀번호 재설정 이메일
sudo gitlab-rails runner "user = User.find_by(username: 'jdoe'); user.send_reset_password_instructions"
```

</details>

### 🏢 **4-2. 그룹 및 프로젝트 권한**

<details open>
<summary><strong>📁 그룹 구조 설계 (클릭하여 보기)</strong></summary>

```yaml
권장 그룹 구조:
  회사명 (Root Group)
  ├── Engineering (Sub-group)
  │   ├── Frontend
  │   │   ├── React-App-1
  │   │   └── Vue-App-2
  │   ├── Backend
  │   │   ├── API-Service
  │   │   └── Worker-Service
  │   └── DevOps
  │       ├── Infrastructure
  │       └── CI-CD-Templates
  ├── Product
  │   ├── Design
  │   └── Documentation
  └── Data
      ├── Analytics
      └── ML-Models
```

### CLI로 그룹 생성

```bash
# Rails 콘솔에서
sudo gitlab-rails console

# 그룹 생성
group = Group.new(
  name: 'Engineering',
  path: 'engineering',
  visibility_level: Gitlab::VisibilityLevel::PRIVATE
)
group.save!

# 서브그룹 생성
subgroup = Group.new(
  name: 'Frontend',
  path: 'frontend',
  parent_id: group.id,
  visibility_level: Gitlab::VisibilityLevel::PRIVATE
)
subgroup.save!

# 그룹에 멤버 추가
user = User.find_by(username: 'jdoe')
group.add_member(user, Gitlab::Access::DEVELOPER)
```

</details>

### 🔑 **4-3. LDAP/SAML 통합**

<details>
<summary><strong>🔗 엔터프라이즈 인증 통합 (클릭하여 보기)</strong></summary>

```ruby
# /etc/gitlab/gitlab.rb

### LDAP 설정
gitlab_rails['ldap_enabled'] = true
gitlab_rails['prevent_ldap_sign_in'] = false

gitlab_rails['ldap_servers'] = {
  'main' => {
    'label' => 'Company LDAP',
    'host' =>  'ldap.example.com',
    'port' => 389,
    'uid' => 'sAMAccountName',
    'bind_dn' => 'CN=GitLab Service,CN=Users,DC=example,DC=com',
    'password' => 'ldap_password',
    'encryption' => 'simple_tls',
    'verify_certificates' => true,
    'active_directory' => true,
    'base' => 'DC=example,DC=com',
    'user_filter' => '(memberOf=CN=GitLabUsers,CN=Groups,DC=example,DC=com)',
    'group_base' => 'CN=Groups,DC=example,DC=com',
    'admin_group' => 'GitLabAdmins'
  }
}
```

### SAML 설정 (SSO)

```ruby
# /etc/gitlab/gitlab.rb

gitlab_rails['omniauth_enabled'] = true
gitlab_rails['omniauth_allow_single_sign_on'] = ['saml']
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['omniauth_auto_link_ldap_user'] = false
gitlab_rails['omniauth_auto_link_saml_user'] = true

gitlab_rails['omniauth_providers'] = [
  {
    name: 'saml',
    label: 'Company SSO',
    args: {
      assertion_consumer_service_url: 'https://gitlab.example.com/users/auth/saml/callback',
      idp_cert_fingerprint: '43:51:43:a1:b5:fc:8b:b7:0a:3a:a9:b1:0f:66:73:a8',
      idp_sso_target_url: 'https://sso.example.com/saml/login',
      issuer: 'https://gitlab.example.com',
      name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
    }
  }
]
```

### 적용 및 테스트

```bash
# 설정 적용
sudo gitlab-ctl reconfigure

# LDAP 연결 테스트
sudo gitlab-rake gitlab:ldap:check

# LDAP 사용자 동기화
sudo gitlab-rake gitlab:ldap:group_sync
```

</details>

---

## 📝 **PART 5: 로그 관리 및 분석**

<details open>
<summary><strong>📊 로그 위치 및 분석 (클릭하여 펼치기/접기)</strong></summary>

### 📁 주요 로그 파일 위치

```bash
/var/log/gitlab/
├── gitlab-rails/
│   ├── production.log          # 애플리케이션 로그
│   ├── api_json.log             # API 요청 로그
│   ├── application.log          # 일반 애플리케이션 로그
│   ├── integrations_json.log    # 외부 통합 로그
│   └── audit_json.log           # 감사 로그
├── nginx/
│   ├── access.log               # HTTP 접근 로그
│   ├── error.log                # Nginx 오류 로그
│   └── gitlab_access.log        # GitLab 전용 접근 로그
├── postgresql/
│   └── current                  # PostgreSQL 로그
├── redis/
│   └── current                  # Redis 로그
├── gitaly/
│   └── current                  # Gitaly 로그
└── sidekiq/
    └── current                  # Sidekiq 작업 로그
```

### 🔍 로그 분석 스크립트

```bash
#!/bin/bash
# GitLab 로그 분석 스크립트

LOG_DIR="/var/log/gitlab"

echo "=== GitLab 로그 분석 ==="

# 1. 최근 오류 건수
echo "[1] 최근 1시간 오류 발생 횟수:"
grep -i "error\|fatal\|exception" $LOG_DIR/gitlab-rails/production.log | \
  awk -v d="$(date -d '1 hour ago' '+%Y-%m-%dT%H')" '$0 > d' | wc -l

# 2. 가장 느린 API 요청 TOP 10
echo "[2] 가장 느린 API 요청 TOP 10 (ms):"
jq -r 'select(.duration_s != null) | "\(.duration_s*1000) \(.method) \(.path)"' \
  $LOG_DIR/gitlab-rails/api_json.log 2>/dev/null | \
  sort -rn | head -10

# 3. HTTP 상태 코드 분포
echo "[3] HTTP 상태 코드 분포:"
awk '{print $9}' $LOG_DIR/nginx/gitlab_access.log | \
  sort | uniq -c | sort -rn

# 4. 가장 많이 접근한 IP TOP 10
echo "[4] 가장 많이 접근한 IP TOP 10:"
awk '{print $1}' $LOG_DIR/nginx/gitlab_access.log | \
  sort | uniq -c | sort -rn | head -10

# 5. PostgreSQL 슬로우 쿼리
echo "[5] PostgreSQL 슬로우 쿼리 (> 1초):"
grep "duration:" $LOG_DIR/postgresql/current | \
  awk '$NF > 1000 {print}' | tail -10

# 6. Sidekiq 실패한 작업
echo "[6] Sidekiq 최근 실패 작업:"
grep -i "fail\|error" $LOG_DIR/sidekiq/current | tail -10
```

</details>

---

## 🚨 **PART 6: 장애 대응 플레이북**

<details open>
<summary><strong>⚡ 긴급 대응 절차 (클릭하여 펼치기/접기)</strong></summary>

### 📋 장애 대응 매트릭스

| 증상 | 심각도 | 초기 대응 시간 | 담당자 |
|------|-------|---------------|--------|
| **전체 서비스 다운** | P1 (Critical) | 즉시 | On-Call Engineer |
| **일부 기능 장애** | P2 (High) | 30분 이내 | DevOps Team |
| **성능 저하** | P3 (Medium) | 2시간 이내 | DevOps Team |
| **단일 사용자 문제** | P4 (Low) | 1영업일 이내 | Support Team |

### 🔴 시나리오 1: GitLab 전체 다운

```bash
#!/bin/bash
# P1 긴급 대응 스크립트

echo "=== P1: GitLab 전체 다운 대응 ==="

# Step 1: 상태 확인 (30초)
echo "[1] 서비스 상태 확인..."
gitlab-ctl status

# Step 2: 시스템 리소스 확인
echo "[2] 시스템 리소스..."
free -h
df -h
top -bn1 | head -20

# Step 3: 최근 로그 오류
echo "[3] 최근 5분 오류 로그..."
find /var/log/gitlab -name "*.log" -mmin -5 -exec grep -i "error\|fatal" {} \;

# Step 4: 긴급 재시작
read -p "긴급 재시작을 시도하시겠습니까? (y/n): " RESTART
if [ "$RESTART" = "y" ]; then
    gitlab-ctl restart
    sleep 30
    curl -I http://localhost
fi

# Step 5: 에스컬레이션
echo "[5] 30분 내미복구 시 에스컬레이션 필요"
echo "다음 단계:"
echo "1. Slack #gitlab-incidents 채널에 상황 공유"
echo "2. 사용자 공지 (status page 업데이트)"
echo "3. 백업에서 복구 검토"
```

### 🟡 시나리오 2: 성능 저하 (느린 응답)

```bash
#!/bin/bash
# P2/P3: 성능 저하 대응 스크립트

echo "=== 성능 저하 진단 및 대응 ==="

# Step 1: 응답 시간 측정
echo "[1] 응답 시간 측정..."
for i in {1..5}; do
    curl -o /dev/null -s -w "응답 시간: %{time_total}s\n" http://localhost
    sleep 2
done

# Step 2: 리소스 병목 확인
echo "[2] 리소스 사용률..."
echo "CPU 사용률:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}'
echo "메모리 사용률:"
free | grep Mem | awk '{printf "%.1f%%\n", $3/$2 * 100.0}'
echo "디스크 I/O:"
iostat -x 1 5 | tail -20

# Step 3: 프로세스별 리소스 사용
echo "[3] TOP 프로세스..."
ps aux --sort=-%cpu | head -15

# Step 4: PostgreSQL 연결 수
echo "[4] PostgreSQL 연결..."
gitlab-psql -d gitlabhq_production -c "SELECT count(*) FROM pg_stat_activity;"

# Step 5: Sidekiq 큐 확인
echo "[5] Sidekiq 큐 상태..."
gitlab-rails runner "puts Sidekiq::Queue.all.map { |q| [q.name, q.size] }"

# Step 6: 임시 조치 제안
echo ""
echo "=== 임시 조치 옵션 ==="
echo "1. Puma worker 재시작: gitlab-ctl restart puma"
echo "2. Sidekiq 재시작: gitlab-ctl restart sidekiq"
echo "3. Redis 캐시 클리어: gitlab-redis-cli FLUSHALL"
echo "4. Git 저장소 최적화: gitlab-rake gitlab:cleanup:repos"
```

### 🟠 시나리오 3: 디스크 공간 부족

```bash
#!/bin/bash
# 디스크 공간 긴급 확보 스크립트

echo "=== 디스크 공간 긴급 확보 ==="

# Step 1: 현재 사용량 확인
echo "[1] 디스크 사용량..."
df -h | grep -E "Filesystem|/dev/"

DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ $DISK_USAGE -gt 90 ]; then
    echo "⚠️  디스크 사용률 위험: ${DISK_USAGE}%"
    
    # Step 2: 큰 디렉토리 찾기
    echo "[2] 큰 디렉토리 TOP 10..."
    du -sh /var/opt/gitlab/* 2>/dev/null | sort -h | tail -10
    
    # Step 3: 오래된 로그 삭제 (7일 이상)
    echo "[3] 오래된 로그 삭제..."
    find /var/log/gitlab -name "*.log" -type f -mtime +7 -delete
    find /var/log/gitlab -name "*.gz" -type f -mtime +7 -delete
    echo "✅ 로그 정리 완료"
    
    # Step 4: 오래된 백업 삭제 (30일 이상)
    echo "[4] 오래된 백업 삭제..."
    find /var/opt/gitlab/backups -name "*.tar" -type f -mtime +30 -delete
    echo "✅ 백업 정리 완료"
    
    # Step 5: GitLab artifacts 정리 (30일 이상)
    echo "[5] 오래된 CI artifacts 정리..."
    gitlab-rake gitlab:cleanup:orphan_job_artifact_files
    echo "✅ Artifacts 정리 완료"
    
    # Step 6: Container Registry 정리
    echo "[6] 미사용 Container 이미지 정리..."
    gitlab-rake gitlab:cleanup:orphan_container_registry
    echo "✅ Registry 정리 완료"
    
    # Step 7: Git 저장소 가비지 컬렉션
    echo "[7] Git 저장소 최적화..."
    gitlab-rake gitlab:cleanup:repos
    echo "✅ 저장소 최적화 완료"
    
    # Step 8: 최종 확인
    echo "[8] 최종 디스크 사용량..."
    df -h | grep -E "Filesystem|/dev/"
    
else
    echo "✅ 디스크 사용률 정상: ${DISK_USAGE}%"
fi
```

### 🔵 시나리오 4: Git Push/Pull 실패

```bash
#!/bin/bash
# Git 작업 실패 진단 스크립트

echo "=== Git Push/Pull 실패 진단 ==="

# Step 1: Gitaly 상태 확인
echo "[1] Gitaly 서비스 상태..."
gitlab-ctl status gitaly

if ! gitlab-ctl status gitaly | grep -q "run:"; then
    echo "❌ Gitaly 서비스 중단"
    echo "재시작 중..."
    gitlab-ctl restart gitaly
    sleep 10
fi

# Step 2: SSH 연결 확인
echo "[2] SSH 서비스 확인..."
ss -tuln | grep ":22"

# Step 3: 저장소 권한 확인
echo "[3] 저장소 디렉토리 권한..."
ls -la /var/opt/gitlab/git-data/repositories/ | head -10

# Step 4: 특정 프로젝트 저장소 검증
read -p "프로젝트 경로 입력 (예: group/project): " PROJECT_PATH
REPO_PATH="/var/opt/gitlab/git-data/repositories/${PROJECT_PATH}.git"

if [ -d "$REPO_PATH" ]; then
    echo "저장소 발견: $REPO_PATH"
    
    # 무결성 검사
    echo "Git 무결성 검사 중..."
    sudo -u git git -C "$REPO_PATH" fsck
    
    # 권한 수정
    echo "권한 수정 중..."
    sudo chown -R git:git "$REPO_PATH"
    sudo chmod -R 750 "$REPO_PATH"
else
    echo "❌ 저장소를 찾을 수 없음: $REPO_PATH"
fi

# Step 5: Gitaly 로그 확인
echo "[5] 최근 Gitaly 오류..."
tail -50 /var/log/gitlab/gitaly/current | grep -i error
```

### 🟣 시나리오 5: CI/CD 파이프라인 실행 안 됨

```bash
#!/bin/bash
# CI/CD 파이프라인 문제 진단

echo "=== CI/CD 파이프라인 진단 ==="

# Step 1: Runner 상태 확인
echo "[1] 등록된 Runner 목록..."
gitlab-rails runner "puts Ci::Runner.all.map { |r| [r.id, r.description, r.active, r.contacted_at] }"

# Step 2: Runner 연결 상태
echo "[2] Runner 최근 접속 시간..."
gitlab-rails runner "
  Ci::Runner.all.each do |runner|
    last_contact = runner.contacted_at ? (Time.now - runner.contacted_at).to_i / 60 : 'never'
    puts \"ID: #{runner.id}, Active: #{runner.active}, Last contact: #{last_contact} min ago\"
  end
"

# Step 3: Pending 작업 확인
echo "[3] 대기 중인 작업..."
gitlab-rails runner "puts Ci::Build.pending.count"

# Step 4: Sidekiq 큐 확인
echo "[4] Sidekiq pipeline 큐..."
gitlab-rails runner "puts Sidekiq::Queue.new('pipeline_default').size"

# Step 5: Runner 로그 확인 (Docker Runner 예시)
if docker ps | grep -q gitlab-runner; then
    echo "[5] Runner 컨테이너 로그..."
    docker logs gitlab-runner --tail 50
fi

# Step 6: 조치 사항
echo ""
echo "=== 조치 옵션 ==="
echo "1. Runner 재시작: docker restart gitlab-runner"
echo "2. Sidekiq 재시작: gitlab-ctl restart sidekiq"
echo "3. Runner 재등록 필요 시: docker exec gitlab-runner gitlab-runner register"
```

</details>

### 📞 **6-1. 에스컬레이션 프로세스**

<details open>
<summary><strong>🚨 장애 에스컬레이션 가이드 (클릭하여 보기)</strong></summary>

```yaml
에스컬레이션 레벨:

Level 1: 1차 대응 (0-30분)
  담당: On-Call Engineer
  조치:
    - 자동 진단 스크립트 실행
    - 기본 재시작 시도
    - 로그 수집
    - Slack #gitlab-incidents 알림

Level 2: 2차 대응 (30-60분)
  담당: DevOps Team Lead
  조치:
    - 심화 진단
    - 백업 복구 검토
    - 외부 벤더 지원 요청 검토
    - 경영진 보고

Level 3: 3차 대응 (60분+)
  담당: CTO/VP Engineering
  조치:
    - 공식 장애 공지
    - 대체 시스템 활성화
    - GitLab Support Premium 티켓
    - 고객 커뮤니케이션
```

### 📋 장애 보고 템플릿

```markdown
# 장애 보고서 (Incident Report)

## 기본 정보
- **일시**: 2024-09-30 14:30 KST
- **심각도**: P1 (Critical)
- **영향 범위**: 전체 사용자 (500명)
- **담당자**: 홍길동 (On-Call)

## 타임라인
- 14:30 - 장애 감지 (모니터링 알림)
- 14:32 - 1차 진단 시작
- 14:35 - 서비스 재시작 시도
- 14:40 - 백업 복구 결정
- 15:10 - 서비스 복구 완료
- 15:15 - 정상 작동 확인

## 근본 원인
- PostgreSQL 연결 풀 고갈
- 원인: 슬로우 쿼리로 인한 연결 점유

## 영향
- 다운타임: 40분
- 영향 사용자: 500명 전체
- 데이터 손실: 없음

## 조치 사항
즉시:
- [x] PostgreSQL max_connections 증가 (200 → 300)
- [x] 슬로우 쿼리 최적화
- [x] 연결 타임아웃 설정 추가

단기 (1주):
- [ ] 쿼리 성능 모니터링 강화
- [ ] 알림 임계값 조정
- [ ] 장애 대응 문서 업데이트

장기 (1개월):
- [ ] PostgreSQL 읽기 복제본 추가
- [ ] 연결 풀 모니터링 대시보드 구축
- [ ] DR 훈련 실시

## 교훈
- 연결 풀 모니터링 부족
- 슬로우 쿼리 사전 탐지 미흡
- 자동 복구 메커니즘 필요

## 담당자
- 작성자: 홍길동
- 검토자: 김철수 (DevOps Lead)
- 승인자: 이영희 (CTO)
```

</details>

### 📊 **6-2. Post-Mortem (사후 분석)**

<details>
<summary><strong>🔍 사후 분석 프로세스 (클릭하여 보기)</strong></summary>

```markdown
# Post-Mortem 회의 안건

## 목적
- 근본 원인 파악 (비난 금지)
- 재발 방지 대책 수립
- 프로세스 개선

## 참석자
- DevOps 팀
- 개발팀 대표
- SRE (있는 경우)
- 경영진 (P1/P2 장애 시)

## 안건
1. 장애 타임라인 리뷰
2. 기술적 근본 원인 분석
3. 프로세스상 문제점
4. 개선 액션 아이템 도출
5. 책임자 및 일정 할당

## 액션 아이템 추적
- Jira/GitLab Issue로 등록
- 주간 리뷰 회의에서 진행 상황 확인
- 완료 시 문서화
```

</details>

---

## 📚 **PART 7: 운영 자동화**

<details open>
<summary><strong>🤖 일상 운영 자동화 (클릭하여 펼치기/접기)</strong></summary>

### 📅 Cron 작업 전체 구성

```bash
#!/bin/bash
# GitLab 운영 자동화 Cron 작업 설정

# Cron 편집
crontab -e

# 다음 내용 추가:
```

```cron
# GitLab 운영 자동화 Cron 작업

# 1. 일일 백업 (매일 02:00)
0 2 * * * /opt/gitlab/bin/gitlab-backup create CRON=1

# 2. 주간 저장소 최적화 (매주 일요일 03:00)
0 3 * * 0 /opt/gitlab/bin/gitlab-rake gitlab:cleanup:repos

# 3. 로그 정리 (매일 04:00)
0 4 * * * find /var/log/gitlab -name "*.log" -type f -mtime +30 -delete

# 4. 오래된 artifacts 정리 (매일 05:00)
0 5 * * * /opt/gitlab/bin/gitlab-rake gitlab:cleanup:orphan_job_artifact_files

# 5. 헬스체크 리포트 (매일 06:00)
0 6 * * * /usr/local/bin/gitlab-healthcheck.sh > /var/log/gitlab-healthcheck.log 2>&1

# 6. 디스크 사용량 체크 (매시간)
0 * * * * /usr/local/bin/check-disk-usage.sh

# 7. 백업 파일 S3 업로드 검증 (매일 07:00)
0 7 * * * /usr/local/bin/verify-s3-backups.sh

# 8. 비활성 사용자 알림 (매월 1일 09:00)
0 9 1 * * /usr/local/bin/inactive-users-report.sh

# 9. 라이선스 만료 체크 (매주 월요일 10:00)
0 10 * * 1 /usr/local/bin/check-license.sh

# 10. 보안 업데이트 체크 (매일 11:00)
0 11 * * * apt-get update && apt-get -s upgrade | grep -i security
```

### 🔧 디스크 사용량 모니터링 스크립트

```bash
#!/bin/bash
# /usr/local/bin/check-disk-usage.sh

THRESHOLD=85
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ $DISK_USAGE -gt $THRESHOLD ]; then
    # Slack 알림
    curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"⚠️  디스크 사용률 경고: ${DISK_USAGE}%\"}" \
    https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
    
    # 이메일 알림
    echo "디스크 사용률이 ${DISK_USAGE}%에 도달했습니다." | \
    mail -s "[GitLab] 디스크 사용률 경고" devops-team@example.com
fi
```

### 📊 비활성 사용자 리포트

```bash
#!/bin/bash
# /usr/local/bin/inactive-users-report.sh

gitlab-rails runner "
  inactive_users = User.where('last_sign_in_at < ?', 90.days.ago)
  
  puts 'Inactive Users (90+ days):'
  puts '=' * 50
  
  inactive_users.each do |user|
    last_login = user.last_sign_in_at ? user.last_sign_in_at.to_date : 'Never'
    puts \"#{user.username} | #{user.email} | Last login: #{last_login}\"
  end
  
  puts \"\\nTotal: #{inactive_users.count} users\"
" > /tmp/inactive-users-report.txt

# 이메일 발송
mail -s "[GitLab] 비활성 사용자 리포트" \
  -a /tmp/inactive-users-report.txt \
  admin@example.com < /tmp/inactive-users-report.txt
```

</details>

---

## 🎯 [4단계] 최종 요약

### 💡 운영 핵심 체크리스트

| 영역 | 주요 작업 | 주기 | 자동화 |
|------|----------|------|--------|
| **백업** | 전체 백업 수행 | 일일 | ✅ Cron |
| **백업** | 복구 테스트 | 월간 | ⚠️  수동 |
| **모니터링** | 대시보드 확인 | 상시 | ✅ Grafana |
| **모니터링** | 알림 규칙 검토 | 분기 | ⚠️  수동 |
| **업그레이드** | 보안 패치 적용 | 월간 | ⚠️  수동 |
| **업그레이드** | 메이저 버전 업그레이드 | 분기 | ❌ 수동 필수 |
| **사용자** | 비활성 사용자 정리 | 분기 | ✅ Cron |
| **사용자** | 권한 감사 | 분기 | ⚠️  수동 |
| **로그** | 로그 정리 | 일일 | ✅ Cron |
| **로그** | 로그 분석 | 주간 | ✅ 스크립트 |

### 🚀 운영 성숙도 모델

```yaml
Level 1 - 기본 (현재 목표):
  - ✅ 수동 백업/복구
  - ✅ 기본 모니터링
  - ✅ 문서화된 업그레이드 절차
  - ✅ 장애 대응 플레이북

Level 2 - 자동화:
  - ⬜ 자동 백업 + S3 업로드
  - ⬜ Prometheus + Grafana 알림
  - ⬜ 스크립트 기반 헬스체크
  - ⬜ Cron 자동화 작업

Level 3 - 최적화:
  - ⬜ 무중단 업그레이드
  - ⬜ 자동 스케일링
  - ⬜ 예측 기반 알림
  - ⬜ SLO/SLI 정의 및 추적

Level 4 - SRE:
  - ⬜ 완전 자동 복구
  - ⬜ Chaos Engineering
  - ⬜ Multi-region HA
  - ⬜ 자동 용량 계획
```

### ✅ 다음 단계 액션 아이템

```markdown
## 즉시 실행 (이번 주)
- [ ] 백업 자동화 설정 및 테스트
- [ ] Prometheus + Grafana 구성
- [ ] 알림 규칙 설정 (Slack/Email)
- [ ] 장애 대응 스크립트 배포

## 단기 (이번 달)
- [ ] DR 훈련 1회 실시
- [ ] 업그레이드 테스트 환경 구축
- [ ] 사용자 권한 감사 수행
- [ ] 운영 문서 작성

## 중기 (다음 분기)
- [ ] 고가용성(HA) 구성 검토
- [ ] 자동 스케일링 설계
- [ ] SLO/SLI 정의
- [ ] 보안 컴플라이언스 점검
```

---

## 📎 운영 도구 모음

```markdown
## 필수 스크립트
- gitlab-healthcheck.sh (종합 헬스체크)
- gitlab-backup-verify.sh (백업 검증)
- gitlab-upgrade.sh (안전한 업그레이드)
- gitlab-emergency.sh (긴급 대응)
- check-disk-usage.sh (디스크 모니터링)

## 대시보드
- Grafana GitLab Overview (Dashboard ID: 14658)
- Prometheus Alertmanager UI
- GitLab Admin Area

## 문서
- 운영 가이드 (이 문서)
- 장애 대응 플레이북
- 백업/복구 절차서
- 업그레이드 체크리스트
```

---

**🎉 GitLab 운영 가이드 완료!**

이제 **사용자 활용(Team Usage)** 가이드로 진행하시거나, 특정 운영 주제에 대한 심화 학습을 요청하실 수 있습니다.

```
다음 단계를 선택하세요:

A. 특정 운영 주제 심화 (예: "고가용성 구성 상세", "Kubernetes 모니터링")
B. 트러블슈팅 시나리오 추가
C. 사용자 활용(Team Usage) 가이드로 진행 ✨
D. 운영 자동화 스크립트 패키지 제공
E. 특정 질문
```

어떤 부분을 더 알고 싶으신가요? 😊

---------------------------------------------------------------------

# GitLab 사용자 활용(Team Usage) 완전 가이드

## 🧠 적용된 사고 공식

이번 답변을 위해 다음 공식들을 조합했습니다:

### 1. **창의적 연결 매트릭스 (CC)**
- Git 워크플로우 ∩ CI/CD = 자동화된 배포 파이프라인
- 이슈 관리 ⊕ 코드 리뷰 = 통합된 개발 프로세스
- 보안 스캔 → 품질 보증 = 안전한 소프트웨어 배포

### 2. **다차원 분석 프레임워크 (MDA)**
```
D1 (시간) = 코드 작성 → 리뷰 → 테스트 → 배포 → 모니터링
D2 (공간) = 개인 → 팀 → 부서 → 조직
D3 (추상) = 코드 레벨 → 프로젝트 레벨 → 비즈니스 레벨
D4 (인과) = 요구사항 → 구현 → 검증 → 릴리스
```

### 3. **통합 지혜 공식 (IW)**
- 지식(K): Git/CI/CD 개념
- 이해(U): 워크플로우 설계
- 실행(A): 실제 .gitlab-ci.yml 작성
- 윤리(E): 코드 리뷰 및 보안 검증

---

## 🧭 [1단계] 사전 브리핑 요약

### 배경
GitLab은 단순한 Git 저장소가 아닌 **완전한 DevOps 플랫폼**입니다:
- 코드 버전 관리 (Git)
- 이슈 및 프로젝트 관리
- CI/CD 파이프라인
- 코드 리뷰 (Merge Request)
- 보안 스캔 (SAST/DAST)
- Container Registry
- 팀 협업 도구

### 범위
```
👥 사용자 활용 영역
├── 1️⃣ 프로젝트 구조 설계 (Group/Project)
├── 2️⃣ Git 워크플로우 (브랜치 전략)
├── 3️⃣ Merge Request 프로세스
├── 4️⃣ CI/CD 파이프라인 작성
├── 5️⃣ 이슈 및 에픽 관리
├── 6️⃣ 보안 및 컴플라이언스
└── 7️⃣ 팀 협업 Best Practices
```

---

## ❓ [2단계] 핵심 질문

**Q1**: 우리 조직에 맞는 프로젝트 구조는?  
**Q2**: 어떤 브랜치 전략을 사용해야 하나?  
**Q3**: CI/CD 파이프라인을 어떻게 작성하나?  
**Q4**: 효과적인 코드 리뷰 방법은?

---

## ✅ [3단계] 답변 - 단계별 활용 가이드

---

## 🏗️ **PART 1: 프로젝트 구조 설계**

<details open>
<summary><strong>📊 조직 구조 설계 원칙 (클릭하여 펼치기/접기)</strong></summary>

### 🎯 Group 계층 구조 전략

```yaml
조직 구조 설계 원칙:
  
  원칙 1: 비즈니스 구조 반영
    - 부서/팀 단위로 Group 생성
    - 제품/서비스 단위로 Sub-group
  
  원칙 2: 권한 상속 활용
    - 상위 Group 권한이 하위로 상속
    - 최소 권한 원칙 적용
  
  원칙 3: 확장성 고려
    - 미래 성장을 고려한 구조
    - 유연한 재구성 가능성
```

### 📋 조직 규모별 권장 구조

#### 소규모 팀 (10-50명)

```
회사명 (Root Group)
├── Frontend
│   ├── web-app
│   ├── mobile-app
│   └── design-system
├── Backend
│   ├── api-service
│   ├── auth-service
│   └── data-pipeline
└── DevOps
    ├── infrastructure
    ├── ci-templates
    └── monitoring
```

#### 중규모 조직 (50-200명)

```
회사명 (Root Group)
├── Engineering
│   ├── Platform
│   │   ├── core-api
│   │   ├── auth-service
│   │   └── notification-service
│   ├── Product-A
│   │   ├── frontend
│   │   ├── backend
│   │   └── mobile
│   └── Product-B
│       ├── web-client
│       └── api-gateway
├── Data
│   ├── Analytics
│   ├── ML-Models
│   └── Data-Pipeline
├── DevOps
│   ├── Infrastructure
│   ├── CI-CD
│   └── Security
└── Shared
    ├── Libraries
    ├── Templates
    └── Documentation
```

#### 대규모 기업 (200명+)

```
회사명 (Root Group)
├── BU-Commerce (사업부)
│   ├── Engineering
│   │   ├── Platform-Team
│   │   ├── Product-Team-1
│   │   └── Product-Team-2
│   ├── Data-Science
│   └── QA
├── BU-Finance
│   ├── Engineering
│   └── Analytics
├── Platform-Engineering (공통)
│   ├── Core-Services
│   ├── Infrastructure
│   └── Security
└── Enterprise-Services
    ├── Shared-Libraries
    ├── Design-System
    └── API-Gateway
```

</details>

### 🔧 **1-1. Group 및 Project 생성**

<details open>
<summary><strong>➕ 웹 UI에서 생성하기 (클릭하여 보기)</strong></summary>

### Group 생성

```markdown
1. 좌측 메뉴 → Groups → Create group
2. 정보 입력:
   - Group name: Engineering
   - Group URL: engineering (자동 생성됨)
   - Visibility: Private (권장)
   - Description: 엔지니어링 팀 프로젝트
3. Create group 클릭
```

### Sub-group 생성

```markdown
1. 상위 Group (Engineering) 접속
2. New subgroup 클릭
3. 정보 입력:
   - Subgroup name: Frontend
   - Subgroup URL: frontend
4. Create subgroup 클릭
```

### Project 생성

```markdown
1. Group 또는 Sub-group 접속
2. New project 클릭
3. 생성 방식 선택:
   - Create blank project (빈 프로젝트)
   - Create from template (템플릿 사용)
   - Import project (기존 저장소 가져오기)
4. 정보 입력:
   - Project name: web-app
   - Project slug: web-app
   - Visibility: Private
   - Initialize with README: ✅ (권장)
5. Create project 클릭
```

</details>

### 🎨 **1-2. Project 템플릿 설계**

<details open>
<summary><strong>📦 표준 프로젝트 템플릿 (클릭하여 보기)</strong></summary>

### 디렉토리 구조 (Frontend - React)

```
web-app/
├── .gitlab/
│   ├── issue_templates/
│   │   ├── bug.md
│   │   ├── feature.md
│   │   └── improvement.md
│   └── merge_request_templates/
│       └── default.md
├── .gitlab-ci.yml
├── README.md
├── CONTRIBUTING.md
├── CHANGELOG.md
├── src/
│   ├── components/
│   ├── pages/
│   ├── utils/
│   └── App.tsx
├── tests/
│   ├── unit/
│   └── e2e/
├── public/
├── package.json
├── tsconfig.json
└── .eslintrc.js
```

### README.md 템플릿

```markdown
# Project Name

## 📋 프로젝트 개요
간단한 프로젝트 설명

## 🚀 빠른 시작

### 필수 요구사항
- Node.js 18+
- npm 9+

### 설치
\`\`\`bash
npm install
\`\`\`

### 개발 서버 실행
\`\`\`bash
npm run dev
\`\`\`

## 🏗️ 프로젝트 구조
\`\`\`
src/
├── components/  # 재사용 가능한 컴포넌트
├── pages/       # 페이지 컴포넌트
├── utils/       # 유틸리티 함수
└── App.tsx      # 메인 앱
\`\`\`

## 🧪 테스트
\`\`\`bash
npm test
\`\`\`

## 📦 빌드
\`\`\`bash
npm run build
\`\`\`

## 🤝 기여 가이드
[CONTRIBUTING.md](CONTRIBUTING.md) 참조

## 📝 변경 이력
[CHANGELOG.md](CHANGELOG.md) 참조

## 👥 팀
- Tech Lead: @tech-lead
- Frontend: @frontend-team
- Backend: @backend-team

## 📄 라이선스
MIT License
```

### CONTRIBUTING.md 템플릿

```markdown
# 기여 가이드

## 개발 워크플로우

1. **Issue 생성**
   - 작업 전 항상 Issue 생성
   - 적절한 라벨 지정

2. **브랜치 생성**
   - `feature/issue-123-add-login`
   - `bugfix/issue-456-fix-crash`

3. **코드 작성**
   - ESLint/Prettier 규칙 준수
   - 단위 테스트 작성

4. **Commit**
   - Conventional Commits 형식
   - 예: `feat: add login page`

5. **Merge Request**
   - MR 템플릿 작성
   - 최소 1명 승인 필요

## 코드 스타일
- ESLint 설정 준수
- Prettier 자동 포맷팅
- TypeScript strict 모드

## 테스트
- 단위 테스트 커버리지 80% 이상
- E2E 테스트 주요 시나리오 작성
```

### Issue 템플릿 (.gitlab/issue_templates/bug.md)

```markdown
## 🐛 버그 설명
명확하고 간결하게 버그를 설명하세요.

## 📝 재현 방법
1. '...'로 이동
2. '....'를 클릭
3. '....'까지 스크롤
4. 오류 발생

## 🎯 예상 동작
예상했던 정상 동작을 설명하세요.

## 📸 스크린샷
가능하다면 스크린샷을 첨부하세요.

## 🔧 환경
- OS: [예: iOS, Windows 10]
- 브라우저: [예: Chrome 118]
- 버전: [예: 1.2.3]

## 📎 추가 정보
다른 컨텍스트나 정보를 추가하세요.

/label ~bug ~needs-triage
/cc @team-lead
```

### MR 템플릿 (.gitlab/merge_request_templates/default.md)

```markdown
## 🎯 변경 사항
이 MR이 무엇을 변경하는지 설명하세요.

## 🔗 관련 Issue
Closes #123

## ✅ 체크리스트
- [ ] 코드 리뷰 가능한 상태
- [ ] 단위 테스트 작성 및 통과
- [ ] ESLint/Prettier 통과
- [ ] CHANGELOG.md 업데이트
- [ ] 문서 업데이트 (필요 시)

## 🧪 테스트 방법
1. 로컬 환경 실행: `npm run dev`
2. `/login` 페이지 접속
3. 테스트 계정으로 로그인

## 📸 스크린샷 (UI 변경 시)
변경 전후 스크린샷

## 🤔 논의 사항
리뷰어에게 특별히 확인받고 싶은 부분

/assign @reviewer
/label ~frontend ~ready-for-review
```

</details>

---

## 🌿 **PART 2: Git 워크플로우 및 브랜치 전략**

<details open>
<summary><strong>🔀 브랜치 전략 비교 (클릭하여 펼치기/접기)</strong></summary>

### 📊 3대 브랜치 전략 비교

| 항목 | Git Flow | GitHub Flow | GitLab Flow |
|------|----------|-------------|-------------|
| **복잡도** | 높음 | 낮음 | 중간 |
| **브랜치 수** | 5+ | 2 | 3-4 |
| **릴리스 주기** | 계획된 릴리스 | 지속적 배포 | 환경별 배포 |
| **팀 규모** | 중대형 | 소규모 | 모든 규모 |
| **학습 곡선** | 가파름 | 완만 | 보통 |
| **권장 사용** | 패키지 소프트웨어 | 웹 서비스 | 엔터프라이즈 |

</details>

### 🔀 **2-1. GitLab Flow (권장)**

<details open>
<summary><strong>🎯 GitLab Flow 완전 가이드 (클릭하여 보기)</strong></summary>

### 브랜치 구조

```
main (production)
  ↑
pre-production (staging)
  ↑
feature-branches
  ↑
developer's local
```

### 브랜치 종류

```yaml
1. main (또는 master):
   - 프로덕션 코드
   - 항상 배포 가능한 상태
   - Protected 브랜치
   - Direct push 금지

2. pre-production (또는 staging):
   - 스테이징 환경
   - 프로덕션 배포 전 검증
   - main으로 MR 생성

3. feature/* (기능 개발):
   - feature/issue-123-user-login
   - feature/add-payment-module
   - 개발 완료 후 pre-production으로 MR

4. bugfix/* (버그 수정):
   - bugfix/issue-456-fix-crash
   - bugfix/hotfix-security-patch

5. hotfix/* (긴급 수정):
   - main에서 직접 분기
   - 수정 후 main + pre-production 동시 MR
```

### 워크플로우 시나리오

#### 시나리오 1: 새 기능 개발

```bash
# 1. 최신 pre-production 동기화
git checkout pre-production
git pull origin pre-production

# 2. Feature 브랜치 생성
git checkout -b feature/issue-123-user-login

# 3. 개발 및 커밋
git add .
git commit -m "feat: add user login page"

# 4. 원격 저장소에 푸시
git push origin feature/issue-123-user-login

# 5. GitLab에서 MR 생성
# pre-production ← feature/issue-123-user-login

# 6. 코드 리뷰 및 승인

# 7. MR 병합 (Squash commits 옵션 권장)

# 8. Feature 브랜치 삭제
git branch -d feature/issue-123-user-login
git push origin --delete feature/issue-123-user-login
```

#### 시나리오 2: 프로덕션 배포

```bash
# 1. pre-production 검증 완료 후
# GitLab에서 MR 생성: main ← pre-production

# 2. 최종 승인 및 병합

# 3. 태그 생성 (릴리스 버전)
git checkout main
git pull origin main
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0

# 4. 배포 (CI/CD 자동 트리거)
```

#### 시나리오 3: Hotfix (긴급 수정)

```bash
# 1. main에서 hotfix 브랜치 생성
git checkout main
git pull origin main
git checkout -b hotfix/critical-security-fix

# 2. 수정 및 커밋
git add .
git commit -m "fix: patch critical security vulnerability"

# 3. 푸시
git push origin hotfix/critical-security-fix

# 4. 2개의 MR 생성
# MR 1: main ← hotfix/critical-security-fix
# MR 2: pre-production ← hotfix/critical-security-fix

# 5. 긴급 승인 및 병합

# 6. Hotfix 태그
git tag -a v1.2.1 -m "Hotfix: security patch"
git push origin v1.2.1
```

### Protected 브랜치 설정

```markdown
## GitLab UI에서 설정

1. Project → Settings → Repository
2. Protected branches → Expand
3. Branch 선택: main
4. 설정:
   - Allowed to merge: Maintainers
   - Allowed to push: No one
   - Allowed to force push: ❌
   - Code owner approval: ✅ (Pro+)
5. Protect 클릭

동일하게 pre-production도 설정
```

### 브랜치 네이밍 규칙

```yaml
Feature 브랜치:
  - feature/issue-{번호}-{설명}
  - feature/add-user-authentication
  - feature/implement-payment-module

Bugfix 브랜치:
  - bugfix/issue-{번호}-{설명}
  - bugfix/fix-login-crash
  - bugfix/resolve-memory-leak

Hotfix 브랜치:
  - hotfix/{설명}
  - hotfix/critical-security-patch
  - hotfix/fix-production-outage

Release 브랜치 (선택):
  - release/v1.2.0
  - release/2024-Q1
```

</details>

### 🔀 **2-2. Commit 메시지 규칙**

<details open>
<summary><strong>📝 Conventional Commits (클릭하여 보기)</strong></summary>

### Commit 메시지 형식

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 종류

```yaml
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅 (기능 변경 없음)
refactor: 코드 리팩토링
test: 테스트 추가/수정
chore: 빌드, 설정 파일 수정
perf: 성능 개선
ci: CI/CD 설정 변경
revert: 커밋 되돌리기
```

### 실제 예시

```bash
# 좋은 예시
feat(auth): add JWT token refresh logic

Implement automatic token refresh before expiration.
Token is refreshed 5 minutes before expiry.

Closes #123

# 나쁜 예시
updated stuff  # ❌ 너무 모호함
fix bug        # ❌ 어떤 버그인지 불명확
```

### Commit 작성 가이드

```bash
# 1. 작은 단위로 자주 커밋
git add src/auth/login.ts
git commit -m "feat(auth): add login form validation"

git add src/auth/api.ts
git commit -m "feat(auth): implement login API integration"

# 2. 관련 없는 변경사항은 분리
# ❌ 나쁜 예
git add .
git commit -m "fix bugs and add features"

# ✅ 좋은 예
git add src/auth/
git commit -m "fix(auth): resolve session timeout issue"

git add src/payment/
git commit -m "feat(payment): add credit card validation"

# 3. Amend로 마지막 커밋 수정 (푸시 전에만!)
git commit --amend -m "feat(auth): add login form with validation"
```

### Git Hooks로 자동 검증

```bash
# .git/hooks/commit-msg 생성
#!/bin/bash

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

# Conventional Commits 형식 검증
pattern="^(feat|fix|docs|style|refactor|test|chore|perf|ci|revert)(\(.+\))?: .{1,72}"

if ! echo "$commit_msg" | grep -qE "$pattern"; then
    echo "❌ 커밋 메시지가 Conventional Commits 형식이 아닙니다."
    echo "형식: type(scope): subject"
    echo "예시: feat(auth): add login page"
    exit 1
fi
```

</details>

---

## 🔍 **PART 3: Merge Request (MR) 프로세스**

<details open>
<summary><strong>📋 완벽한 MR 워크플로우 (클릭하여 펼치기/접기)</strong></summary>

### MR 생성 전 체크리스트

```markdown
- [ ] 관련 Issue 존재 여부 확인
- [ ] 로컬에서 모든 테스트 통과
- [ ] Lint 오류 없음
- [ ] 커밋 메시지 규칙 준수
- [ ] 브랜치가 최신 상태로 업데이트됨
- [ ] 불필요한 파일 제외 (node_modules, .env 등)
```

</details>

### 🔧 **3-1. MR 생성 및 관리**

<details open>
<summary><strong>➕ MR 생성 가이드 (클릭하여 보기)</strong></summary>

### 웹 UI에서 MR 생성

```markdown
1. Project → Merge requests → New merge request

2. Source branch 선택:
   - feature/issue-123-user-login

3. Target branch 선택:
   - pre-production (또는 main)

4. Compare branches and continue 클릭

5. MR 정보 입력:
   Title: [필수] 명확한 제목
   - ✅ feat: Add user login functionality
   - ❌ updates
   
   Description: [필수] 템플릿 작성
   - 변경 사항
   - 관련 Issue (Closes #123)
   - 테스트 방법
   - 스크린샷 (UI 변경 시)

6. 옵션 설정:
   - Assignee: 리뷰어 지정
   - Reviewer: 명시적 리뷰어 (Pro+)
   - Labels: ~frontend ~ready-for-review
   - Milestone: Sprint 1
   - Delete source branch: ✅ (권장)
   - Squash commits: ✅ (권장)

7. Create merge request 클릭
```

### CLI에서 MR 생성

```bash
# GitLab CLI 설치
# https://gitlab.com/gitlab-org/cli

# MR 생성
glab mr create \
  --title "feat: Add user login functionality" \
  --description "Implements login page with JWT authentication" \
  --label "frontend,ready-for-review" \
  --assignee @reviewer \
  --source-branch feature/issue-123-user-login \
  --target-branch pre-production

# 또는 Git push 시 자동 생성
git push origin feature/issue-123-user-login \
  -o merge_request.create \
  -o merge_request.target=pre-production \
  -o merge_request.title="feat: Add user login"
```

</details>

### 👀 **3-2. 코드 리뷰 Best Practices**

<details open>
<summary><strong>✅ 효과적인 코드 리뷰 (클릭하여 보기)</strong></summary>

### 리뷰어 가이드

```markdown
## 무엇을 확인할까?

### 1. 기능성 (Functionality)
- [ ] 코드가 의도한 대로 동작하는가?
- [ ] Edge case가 처리되는가?
- [ ] 에러 처리가 적절한가?

### 2. 코드 품질 (Code Quality)
- [ ] 가독성이 좋은가?
- [ ] 중복 코드가 없는가?
- [ ] 네이밍이 명확한가?
- [ ] 복잡도가 적절한가?

### 3. 테스트 (Testing)
- [ ] 단위 테스트가 작성되었는가?
- [ ] 테스트 커버리지가 충분한가?
- [ ] 테스트가 의미있는가?

### 4. 보안 (Security)
- [ ] 입력 검증이 있는가?
- [ ] 인증/인가가 적절한가?
- [ ] 민감 정보가 노출되지 않는가?

### 5. 성능 (Performance)
- [ ] 불필요한 연산이 없는가?
- [ ] 메모리 누수 가능성은?
- [ ] N+1 쿼리 문제는 없는가?

### 6. 문서화 (Documentation)
- [ ] 복잡한 로직에 주석이 있는가?
- [ ] README가 업데이트되었는가?
- [ ] API 문서가 최신인가?
```

### 리뷰 코멘트 예시

```markdown
## ✅ 좋은 코멘트

💡 제안: 이 부분은 `Array.map()` 대신 `Array.reduce()`를 사용하면 
더 효율적일 것 같습니다.

\`\`\`javascript
// 현재
const result = items.map(i => i.value).reduce((a, b) => a + b, 0);

// 제안
const result = items.reduce((sum, i) => sum + i.value, 0);
\`\`\`

---

🐛 버그: `userId`가 `undefined`일 때 에러가 발생할 수 있습니다.

\`\`\`javascript
// 수정 제안
if (!userId) {
  throw new Error('User ID is required');
}
\`\`\`

---

❓ 질문: 이 함수의 시간 복잡도가 O(n²)인데, 
사용자 수가 많아지면 성능 이슈가 있지 않을까요?

---

👍 잘 작성되었습니다! 
특히 에러 처리 부분이 꼼꼼하네요.

## ❌ 나쁜 코멘트

- "이거 왜 이렇게 했어요?" (공격적)
- "이해가 안 가네요." (구체적이지 않음)
- "다시 작성하세요." (대안 제시 없음)
```

### MR 승인 기준

```yaml
승인 전 확인사항:
  필수:
    - ✅ CI/CD 파이프라인 통과
    - ✅ 코드 리뷰 완료
    - ✅ 충돌(Conflict) 해결
    - ✅ 최소 1명 승인 (팀 규칙에 따라)
  
  권장:
    - ✅ 코드 커버리지 목표 달성
    - ✅ 보안 스캔 통과
    - ✅ 성능 테스트 통과 (필요 시)
```

</details>

### 🔄 **3-3. MR 업데이트 및 병합**

<details open>
<summary><strong>🔀 MR 관리 시나리오 (클릭하여 보기)</strong></summary>

#### 시나리오 1: 리뷰 피드백 반영
```bash
# 1. 리뷰 피드백 확인 후 로컬에서 수정
git checkout feature/issue-123-user-login

# 2. 수정 사항 커밋
git add .
git commit -m "refactor: apply code review feedback"

# 3. 푸시 (MR 자동 업데이트)
git push origin feature/issue-123-user-login

# 4. GitLab MR 페이지에서 리뷰어에게 알림
# "Re-request review" 버튼 클릭
```

#### 시나리오 2: Conflict 해결

```bash
# 1. Target 브랜치 최신화
git checkout pre-production
git pull origin pre-production

# 2. Feature 브랜치로 돌아가서 rebase
git checkout feature/issue-123-user-login
git rebase pre-production

# 3. Conflict 발생 시 수동 해결
# 파일 편집 후:
git add <resolved-files>
git rebase --continue

# 4. Force push (주의: 이미 리뷰 중인 MR)
git push origin feature/issue-123-user-login --force-with-lease

# 대안: Merge 방식 (rebase보다 안전)
git checkout feature/issue-123-user-login
git merge pre-production
# Conflict 해결 후
git push origin feature/issue-123-user-login
```

#### 시나리오 3: MR 병합

```markdown
## GitLab UI에서 병합

1. MR 페이지에서 "Merge" 버튼 클릭

2. 병합 옵션 선택:
   
   ✅ **Squash commits** (권장)
   - 여러 커밋을 하나로 합침
   - 깔끔한 히스토리 유지
   - 최종 커밋 메시지 편집 가능
   
   ✅ **Delete source branch** (권장)
   - 병합 후 feature 브랜치 자동 삭제
   
   ⚠️ **Rebase**
   - 선형 히스토리 유지
   - Conflict 가능성 높음
   
   ❌ **Merge commit**
   - 모든 커밋 보존
   - 복잡한 히스토리

3. "Merge" 클릭

4. 병합 후 확인:
   - Target 브랜치에 코드 반영 확인
   - CI/CD 파이프라인 자동 실행 확인
   - Source 브랜치 삭제 확인
```

#### 시나리오 4: WIP (Work In Progress) MR

```bash
# 1. MR 제목 앞에 "Draft:" 추가 (자동으로 WIP 표시)
# Draft: feat: Add user login functionality

# 또는 GitLab UI에서:
# MR 페이지 → "Mark as draft" 클릭

# 2. 작업 완료 후 Draft 해제
# "Mark as ready" 클릭

# 3. CLI에서 Draft MR 생성
git push origin feature/issue-123-user-login \
  -o merge_request.create \
  -o merge_request.title="Draft: feat: Add user login" \
  -o merge_request.draft
```

</details>

---

## ⚙️ **PART 4: CI/CD 파이프라인 작성**

<details open>
<summary><strong>🚀 .gitlab-ci.yml 완전 가이드 (클릭하여 펼치기/접기)</strong></summary>

### CI/CD 파이프라인 개념

```yaml
파이프라인 구조:

Pipeline (전체 실행)
├── Stage 1: build (빌드)
│   └── Job: compile
├── Stage 2: test (테스트)
│   ├── Job: unit-test
│   └── Job: lint
├── Stage 3: security (보안 스캔)
│   ├── Job: sast
│   └── Job: dependency-scan
└── Stage 4: deploy (배포)
    ├── Job: deploy-staging
    └── Job: deploy-production
```

</details>

### 🐍 **4-1. Frontend 파이프라인 (React/Vue)**

<details open>
<summary><strong>⚛️ React 프로젝트 CI/CD (클릭하여 보기)</strong></summary>

```yaml
# .gitlab-ci.yml (React + TypeScript)

# 기본 설정
image: node:18

# 캐시 설정 (빌드 속도 향상)
cache:
  key:
    files:
      - package-lock.json
  paths:
    - node_modules/
    - .npm/

# 파이프라인 단계
stages:
  - install
  - lint
  - test
  - build
  - security
  - deploy

# 변수 정의
variables:
  NODE_ENV: "production"
  CI: "true"

# === Stage 1: 의존성 설치 ===
install_dependencies:
  stage: install
  script:
    - npm ci --cache .npm --prefer-offline
  artifacts:
    paths:
      - node_modules/
    expire_in: 1 hour

# === Stage 2: Lint 검사 ===
lint:
  stage: lint
  dependencies:
    - install_dependencies
  script:
    - npm run lint
  allow_failure: false

prettier:
  stage: lint
  dependencies:
    - install_dependencies
  script:
    - npm run format:check
  allow_failure: false

# === Stage 3: 테스트 ===
unit_test:
  stage: test
  dependencies:
    - install_dependencies
  script:
    - npm run test:coverage
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
    paths:
      - coverage/
    expire_in: 30 days

e2e_test:
  stage: test
  image: cypress/base:18
  dependencies:
    - install_dependencies
  services:
    - name: selenium/standalone-chrome:latest
  script:
    - npm run build
    - npm run start &
    - sleep 10
    - npm run cypress:run
  artifacts:
    when: always
    paths:
      - cypress/videos/
      - cypress/screenshots/
    expire_in: 7 days
  only:
    - merge_requests
    - main

# === Stage 4: 빌드 ===
build:
  stage: build
  dependencies:
    - install_dependencies
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

# === Stage 5: 보안 스캔 ===
sast:
  stage: security
  image: returntocorp/semgrep:latest
  script:
    - semgrep --config=auto --json --output=sast-report.json .
  artifacts:
    reports:
      sast: sast-report.json
  allow_failure: true

dependency_scanning:
  stage: security
  dependencies:
    - install_dependencies
  script:
    - npm audit --audit-level=moderate
  allow_failure: true

# === Stage 6: 배포 ===
deploy_staging:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploying to staging..."
    - npm install -g netlify-cli
    - netlify deploy --dir=dist --site=$NETLIFY_SITE_ID --auth=$NETLIFY_AUTH_TOKEN
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - pre-production

deploy_production:
  stage: deploy
  dependencies:
    - build
  script:
    - echo "Deploying to production..."
    - npm install -g netlify-cli
    - netlify deploy --prod --dir=dist --site=$NETLIFY_SITE_ID --auth=$NETLIFY_AUTH_TOKEN
  environment:
    name: production
    url: https://example.com
  only:
    - main
  when: manual  # 수동 승인 필요

# === 성능 최적화: 조건부 실행 ===
# Merge Request에서만 E2E 테스트 실행
.mr_only:
  only:
    - merge_requests

# Main 브랜치에만 배포
.main_only:
  only:
    - main
```

### package.json 스크립트

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint src --ext .ts,.tsx --report-unused-disable-directives --max-warnings 0",
    "format": "prettier --write \"src/**/*.{ts,tsx,css}\"",
    "format:check": "prettier --check \"src/**/*.{ts,tsx,css}\"",
    "test": "vitest",
    "test:coverage": "vitest run --coverage",
    "cypress:open": "cypress open",
    "cypress:run": "cypress run"
  }
}
```

</details>

### ☕ **4-2. Backend 파이프라인 (Node.js/Python/Java)**

<details open>
<summary><strong>🐍 Python (Django/FastAPI) CI/CD (클릭하여 보기)</strong></summary>

```yaml
# .gitlab-ci.yml (Python + Django)

image: python:3.11

# 캐시 설정
cache:
  paths:
    - .cache/pip
    - venv/

stages:
  - setup
  - lint
  - test
  - security
  - build
  - deploy

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"
  POSTGRES_DB: test_db
  POSTGRES_USER: test_user
  POSTGRES_PASSWORD: test_password
  DATABASE_URL: "postgresql://test_user:test_password@postgres:5432/test_db"

# === Stage 1: 환경 설정 ===
setup:
  stage: setup
  script:
    - python -V
    - pip install virtualenv
    - virtualenv venv
    - source venv/bin/activate
    - pip install -r requirements.txt
  artifacts:
    paths:
      - venv/
    expire_in: 1 hour

# === Stage 2: Lint 검사 ===
flake8:
  stage: lint
  dependencies:
    - setup
  script:
    - source venv/bin/activate
    - pip install flake8
    - flake8 . --max-line-length=120 --exclude=venv,migrations

black:
  stage: lint
  dependencies:
    - setup
  script:
    - source venv/bin/activate
    - pip install black
    - black --check .

mypy:
  stage: lint
  dependencies:
    - setup
  script:
    - source venv/bin/activate
    - pip install mypy
    - mypy . --exclude venv
  allow_failure: true

# === Stage 3: 테스트 ===
unit_test:
  stage: test
  dependencies:
    - setup
  services:
    - postgres:14
  script:
    - source venv/bin/activate
    - python manage.py migrate
    - coverage run --source='.' manage.py test
    - coverage report
    - coverage xml
  coverage: '/(?i)total.*? (100(?:\.0+)?\%|[1-9]?\d(?:\.\d+)?\%)$/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
    paths:
      - htmlcov/
    expire_in: 30 days

integration_test:
  stage: test
  dependencies:
    - setup
  services:
    - postgres:14
    - redis:7
  script:
    - source venv/bin/activate
    - python manage.py migrate
    - pytest tests/integration/ -v --tb=short
  only:
    - merge_requests
    - main

# === Stage 4: 보안 스캔 ===
bandit:
  stage: security
  dependencies:
    - setup
  script:
    - source venv/bin/activate
    - pip install bandit
    - bandit -r . -f json -o bandit-report.json || true
  artifacts:
    reports:
      sast: bandit-report.json
  allow_failure: true

safety:
  stage: security
  dependencies:
    - setup
  script:
    - source venv/bin/activate
    - pip install safety
    - safety check --json
  allow_failure: true

# === Stage 5: Docker 빌드 ===
build_docker:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_DRIVER: overlay2
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA .
    - docker build -t $CI_REGISTRY_IMAGE:latest .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
    - docker push $CI_REGISTRY_IMAGE:latest
  only:
    - main
    - pre-production

# === Stage 6: 배포 ===
deploy_staging:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache curl
  script:
    - echo "Deploying to staging..."
    - |
      curl -X POST https://api.render.com/deploy/srv-xxx?key=$RENDER_API_KEY
  environment:
    name: staging
    url: https://staging-api.example.com
  only:
    - pre-production

deploy_production:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache curl
  script:
    - echo "Deploying to production..."
    - |
      curl -X POST https://api.render.com/deploy/srv-yyy?key=$RENDER_API_KEY
  environment:
    name: production
    url: https://api.example.com
  only:
    - main
  when: manual

# === 성능 테스트 (선택사항) ===
performance_test:
  stage: test
  dependencies:
    - setup
  services:
    - postgres:14
  script:
    - source venv/bin/activate
    - pip install locust
    - locust -f locustfile.py --headless -u 100 -r 10 -t 60s --host=https://staging-api.example.com
  artifacts:
    paths:
      - locust_report.html
  only:
    - pre-production
  when: manual
```

### Dockerfile (Django)

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# 시스템 의존성
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드
COPY . .

# 정적 파일 수집
RUN python manage.py collectstatic --noinput

# 헬스체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8000/health/ || exit 1

# 실행
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "config.wsgi:application"]
```

</details>

### ☕ **4-3. Java (Spring Boot) 파이프라인**

<details>
<summary><strong>☕ Spring Boot CI/CD (클릭하여 보기)</strong></summary>

```yaml
# .gitlab-ci.yml (Spring Boot + Maven)

image: maven:3.9-eclipse-temurin-17

variables:
  MAVEN_OPTS: "-Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository"
  SPRING_PROFILES_ACTIVE: "test"

cache:
  paths:
    - .m2/repository/
    - target/

stages:
  - build
  - test
  - security
  - package
  - deploy

# === Stage 1: 빌드 ===
build:
  stage: build
  script:
    - mvn clean compile
  artifacts:
    paths:
      - target/
    expire_in: 1 hour

# === Stage 2: 테스트 ===
unit_test:
  stage: test
  dependencies:
    - build
  services:
    - postgres:14
    - redis:7
  script:
    - mvn test
    - mvn jacoco:report
  coverage: '/Total.*?([0-9]{1,3})%/'
  artifacts:
    reports:
      junit:
        - target/surefire-reports/TEST-*.xml
      coverage_report:
        coverage_format: cobertura
        path: target/site/jacoco/jacoco.xml
    paths:
      - target/site/jacoco/
    expire_in: 30 days

integration_test:
  stage: test
  dependencies:
    - build
  services:
    - postgres:14
  script:
    - mvn verify -P integration-test
  only:
    - merge_requests
    - main

# === Stage 3: 보안 스캔 ===
dependency_check:
  stage: security
  script:
    - mvn dependency-check:check
  artifacts:
    reports:
      dependency_scanning: target/dependency-check-report.xml
  allow_failure: true

sonarqube:
  stage: security
  script:
    - mvn sonar:sonar 
      -Dsonar.projectKey=$CI_PROJECT_NAME
      -Dsonar.host.url=$SONAR_HOST_URL
      -Dsonar.login=$SONAR_TOKEN
  only:
    - main
    - merge_requests

# === Stage 4: 패키징 ===
package:
  stage: package
  dependencies:
    - build
  script:
    - mvn package -DskipTests
  artifacts:
    paths:
      - target/*.jar
    expire_in: 1 week

docker_build:
  stage: package
  image: docker:24
  services:
    - docker:24-dind
  dependencies:
    - package
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
  only:
    - main
    - pre-production

# === Stage 5: 배포 ===
deploy_staging:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache openssh-client
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
    - mkdir -p ~/.ssh
    - chmod 700 ~/.ssh
    - ssh-keyscan $STAGING_SERVER >> ~/.ssh/known_hosts
  script:
    - ssh $STAGING_USER@$STAGING_SERVER "docker pull $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"
    - ssh $STAGING_USER@$STAGING_SERVER "docker-compose -f docker-compose.staging.yml up -d"
  environment:
    name: staging
    url: https://staging-api.example.com
  only:
    - pre-production

deploy_production:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache openssh-client
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
  script:
    - ssh $PROD_USER@$PROD_SERVER "kubectl set image deployment/api api=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"
  environment:
    name: production
    url: https://api.example.com
  only:
    - main
  when: manual
```

</details>

### 🐳 **4-4. Docker + Kubernetes 배포**

<details open>
<summary><strong>☸️ Kubernetes 배포 파이프라인 (클릭하여 보기)</strong></summary>

```yaml
# .gitlab-ci.yml (Kubernetes 배포)

stages:
  - build
  - test
  - package
  - deploy

# === Docker 빌드 및 푸시 ===
docker_build:
  stage: package
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_DRIVER: overlay2
    DOCKER_TLS_CERTDIR: "/certs"
    IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    # Multi-stage build
    - docker build 
      --cache-from $CI_REGISTRY_IMAGE:latest
      --tag $IMAGE_TAG
      --tag $CI_REGISTRY_IMAGE:latest
      --file Dockerfile .
    - docker push $IMAGE_TAG
    - docker push $CI_REGISTRY_IMAGE:latest
  only:
    - main
    - pre-production

# === Kubernetes 배포 (Staging) ===
deploy_k8s_staging:
  stage: deploy
  image: bitnami/kubectl:latest
  before_script:
    - mkdir -p ~/.kube
    - echo "$KUBE_CONFIG_STAGING" | base64 -d > ~/.kube/config
    - kubectl config use-context staging
  script:
    # ConfigMap 및 Secret 업데이트
    - kubectl create configmap app-config 
      --from-literal=ENV=staging
      --from-literal=API_URL=https://staging-api.example.com
      --dry-run=client -o yaml | kubectl apply -f -
    
    # Deployment 업데이트
    - kubectl set image deployment/web-app 
      app=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
      --record
    
    # Rollout 상태 확인
    - kubectl rollout status deployment/web-app --timeout=5m
    
    # 배포 확인
    - kubectl get pods -l app=web-app
  environment:
    name: staging
    url: https://staging.example.com
    kubernetes:
      namespace: staging
  only:
    - pre-production

# === Kubernetes 배포 (Production) ===
deploy_k8s_production:
  stage: deploy
  image: bitnami/kubectl:latest
  before_script:
    - mkdir -p ~/.kube
    - echo "$KUBE_CONFIG_PROD" | base64 -d > ~/.kube/config
    - kubectl config use-context production
  script:
    # Blue-Green 배포 전략
    - |
      # 현재 active 버전 확인
      CURRENT_VERSION=$(kubectl get service web-app -o jsonpath='{.spec.selector.version}')
      if [ "$CURRENT_VERSION" == "blue" ]; then
        NEW_VERSION="green"
      else
        NEW_VERSION="blue"
      fi
      
      echo "Deploying to $NEW_VERSION environment"
      
      # 새 버전 배포
      kubectl set image deployment/web-app-$NEW_VERSION 
        app=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
      kubectl rollout status deployment/web-app-$NEW_VERSION --timeout=5m
      
      # 헬스체크
      kubectl run healthcheck --rm -i --restart=Never --image=curlimages/curl:latest -- 
        curl -f http://web-app-$NEW_VERSION-service/health
      
      # 트래픽 전환
      kubectl patch service web-app -p "{\"spec\":{\"selector\":{\"version\":\"$NEW_VERSION\"}}}"
      
      echo "Traffic switched to $NEW_VERSION"
  environment:
    name: production
    url: https://example.com
    kubernetes:
      namespace: production
  only:
    - main
  when: manual

# === Rollback ===
rollback_production:
  stage: deploy
  image: bitnami/kubectl:latest
  before_script:
    - mkdir -p ~/.kube
    - echo "$KUBE_CONFIG_PROD" | base64 -d > ~/.kube/config
  script:
    - kubectl rollout undo deployment/web-app
    - kubectl rollout status deployment/web-app
  environment:
    name: production
    action: rollback
  when: manual
  only:
    - main
```

### Kubernetes Manifests

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: app
        image: registry.gitlab.com/user/project:latest
        ports:
        - containerPort: 8080
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer

---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

</details>

---

## 📋 **PART 5: 이슈 및 에픽 관리**

<details open>
<summary><strong>🎯 프로젝트 관리 전략 (클릭하여 펼치기/접기)</strong></summary>

### 이슈 계층 구조

```yaml
Epic (큰 기능)
├── Issue 1 (작업 단위)
│   ├── Task 1
│   └── Task 2
├── Issue 2
└── Issue 3
```

### Label 분류 체계

```yaml
타입 (Type):
  - ~feature: 새 기능
  - ~bug: 버그
  - ~enhancement: 개선
  - ~documentation: 문서화
  - ~refactor: 리팩토링

우선순위 (Priority):
  - ~priority::critical: 즉시 처리
  - ~priority::high: 높음
  - ~priority::medium: 보통
  - ~priority::low: 낮음

상태 (Status):
  - ~status::todo: 대기
  - ~status::in-progress: 진행 중
  - ~status::review: 리뷰 중
  - ~status::done: 완료
  - ~status::blocked: 차단됨

팀 (Team):
  - ~team::frontend
  - ~team::backend
  - ~team::devops
  - ~team::design

기타:
  - ~good-first-issue: 신규 기여자용
  - ~help-wanted: 도움 필요
  - ~wontfix: 수정 안 함
```

</details>

### 📊 **5-1. Milestone 및 스프린트 관리**

<details open>
<summary><strong>🗓️ 애자일 스프린트 구성 (클릭하여 보기)</strong></summary>

### Milestone 생성

```markdown
## GitLab UI에서 Milestone 생성

1. Project → Issues → Milestones → New milestone

2. 정보 입력:
   Title: Sprint 1 - 2024 Q1
   Start date: 2024-01-01
   Due date: 2024-01-14
   Description:
   ```
   ## Sprint 목표
   - 사용자 인증 시스템 완성
   - 대시보드 UI 개선
   
   ## Definition of Done
   - 모든 테스트 통과
   - 코드 리뷰 완료
   - 스테이징 배포 검증
   ```

3. Create milestone 클릭
```

### Sprint 보드 활용

```markdown
## Scrum Board 설정

1. Project → Issues → Boards
2. New board 클릭
3. Board name: Sprint 1 Board
4. 리스트 구성:
   - Open (Todo)
   - In Progress
   - In Review
   - Done

5. 자동화 설정:
   - Issue가 MR에 연결되면 → In Review로 이동
   - MR이 병합되면 → Done으로 이동
```

</details>

### 📈 **5-2. 번다운 차트 및 리포팅**

<details>
<summary><strong>📊 진행 상황 추적 (클릭하여 보기)</strong></summary>

```markdown
## Burndown Chart (Premium+)

1. Project → Analytics → Value Stream Analytics
2. Milestone 선택: Sprint 1
3. Burndown chart 확인:
   - 이상적인 진행선 (ideal line)
   - 실제 진행선 (actualline)
   - 남은 이슈 수
   - 완료율

## 수동 리포트 생성

### Sprint 리포트 자동화 스크립트
```bash
#!/bin/bash
# sprint-report.sh - Sprint 종료 시 실행

MILESTONE_ID="1"
PROJECT_ID="12345"
GITLAB_TOKEN="your-token"

# 이슈 통계 수집
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "https://gitlab.com/api/v4/projects/$PROJECT_ID/milestones/$MILESTONE_ID/issues" \
  | jq -r '
    {
      "total": length,
      "completed": [.[] | select(.state == "closed")] | length,
      "in_progress": [.[] | select(.state == "opened" and (.labels | contains(["in-progress"])))] | length,
      "blocked": [.[] | select(.labels | contains(["blocked"]))] | length
    }
  ' > sprint-stats.json

# Markdown 리포트 생성
cat > sprint-report.md <<EOF
# Sprint $MILESTONE_ID 리포트

## 📊 통계
- **완료율**: $(jq -r '(.completed / .total * 100 | floor)' sprint-stats.json)%
- **총 이슈**: $(jq -r '.total' sprint-stats.json)개
- **완료**: $(jq -r '.completed' sprint-stats.json)개
- **진행 중**: $(jq -r '.in_progress' sprint-stats.json)개
- **차단됨**: $(jq -r '.blocked' sprint-stats.json)개

## ✅ 주요 성과
- [수동 작성]

## 🚧 이슈 및 장애물
- [수동 작성]

## 📝 다음 Sprint 계획
- [수동 작성]
EOF

echo "✅ Sprint 리포트 생성 완료: sprint-report.md"
```

</details>

---

## 🔒 **PART 6: 보안 및 컴플라이언스**

<details open>
<summary><strong>🛡️ 보안 스캔 통합 (클릭하여 펼치기/접기)</strong></summary>

### GitLab 보안 기능

```yaml
보안 스캔 종류:

1. SAST (Static Application Security Testing)
   - 소스 코드 정적 분석
   - 취약점 패턴 탐지

2. DAST (Dynamic Application Security Testing)
   - 실행 중인 애플리케이션 스캔
   - 런타임 취약점 탐지

3. Dependency Scanning
   - 의존성 라이브러리 취약점 검사
   - CVE 데이터베이스 참조

4. Container Scanning
   - Docker 이미지 스캔
   - OS 패키지 취약점 검사

5. Secret Detection
   - 하드코딩된 비밀번호/API 키 탐지
   - 커밋 히스토리 스캔

6. License Compliance
   - 라이선스 정책 준수 확인
   - GPL, MIT 등 라이선스 추적
```

</details>

### 🔍 **6-1. SAST 및 Dependency Scanning**

<details open>
<summary><strong>🔎 정적 보안 분석 (클릭하여 보기)</strong></summary>

```yaml
# .gitlab-ci.yml (보안 스캔)

include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml

stages:
  - build
  - test
  - security
  - deploy

# === SAST (자동 활성화) ===
sast:
  stage: security
  # GitLab이 언어를 자동 감지하고 적절한 스캐너 실행
  # - Semgrep (다중 언어)
  # - Bandit (Python)
  # - ESLint (JavaScript)
  # - Brakeman (Ruby)
  # - SpotBugs (Java)

# === 커스텀 SAST 설정 ===
semgrep-sast:
  stage: security
  image: returntocorp/semgrep:latest
  script:
    - semgrep --config=auto --json --output=sast-report.json .
  artifacts:
    reports:
      sast: sast-report.json
  only:
    - merge_requests
    - main

# === Dependency Scanning ===
dependency_scanning:
  stage: security
  # 자동으로 package.json, requirements.txt, pom.xml 등 감지

# === Secret Detection ===
secret_detection:
  stage: security
  # 커밋 히스토리에서 비밀 정보 탐지
  # - API keys
  # - Passwords
  # - Private keys
  # - Tokens

# === Custom Secret Scanning ===
gitleaks:
  stage: security
  image: zricethezav/gitleaks:latest
  script:
    - gitleaks detect --source . --report-format json --report-path gitleaks-report.json
  artifacts:
    reports:
      secret_detection: gitleaks-report.json
  allow_failure: false

# === License Compliance (Premium+) ===
license_scanning:
  stage: security
  image: 
    name: licensefinder/license_finder:latest
    entrypoint: [""]
  script:
    - /bin/bash -c "cd /scan && license_finder report --format json > licenses.json"
  artifacts:
    reports:
      license_scanning: licenses.json

# === Container Scanning ===
container_scanning:
  stage: security
  image: docker:24
  services:
    - docker:24-dind
  variables:
    DOCKER_DRIVER: overlay2
    CI_APPLICATION_REPOSITORY: $CI_REGISTRY_IMAGE
    CI_APPLICATION_TAG: $CI_COMMIT_SHORT_SHA
  script:
    - docker pull $CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG
    - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock 
      aquasec/trivy:latest image --format json --output container-scan.json 
      $CI_APPLICATION_REPOSITORY:$CI_APPLICATION_TAG
  artifacts:
    reports:
      container_scanning: container-scan.json
  dependencies:
    - build_docker
```

### .semgrepignore (SAST 제외 파일)

```
# 테스트 파일
tests/
**/*_test.py
**/*.test.ts

# 의존성
node_modules/
venv/
vendor/

# 생성된 파일
dist/
build/
*.min.js

# 문서
docs/
*.md
```

### 취약점 대응 프로세스

```markdown
## 취약점 발견 시 대응 절차

### 1단계: 심각도 평가
- **Critical**: 즉시 패치 (4시간 이내)
- **High**: 24시간 이내 패치
- **Medium**: 1주일 이내 패치
- **Low**: 다음 Sprint에 포함

### 2단계: Issue 생성
Title: [Security] CVE-2024-1234 in package-name
Labels: ~security ~priority::critical
Assignee: Security Team Lead

### 3단계: 패치 적용
- Hotfix 브랜치 생성
- 의존성 업데이트 또는 코드 수정
- 테스트 수행
- 긴급 MR 생성 및 리뷰

### 4단계: 배포
- Staging 환경 배포
- 검증 후 Production 배포
- 모니터링 강화

### 5단계: 사후 처리
- 취약점 리포트 작성
- 재발 방지 대책 수립
- 팀 공유 및 교육
```

</details>

### 🔐 **6-2. Secret 관리**

<details open>
<summary><strong>🔑 안전한 Secret 관리 (클릭하여 보기)</strong></summary>

### GitLab CI/CD Variables

```markdown
## Secret 설정 방법

1. Project → Settings → CI/CD → Variables
2. Add variable 클릭
3. 설정:
   - Key: DATABASE_URL
   - Value: postgresql://user:pass@host:5432/db
   - Type: Variable (또는 File)
   - Environment scope: All (또는 production, staging)
   - Protect variable: ✅ (Protected 브랜치에서만 사용)
   - Mask variable: ✅ (로그에서 가림)

## 환경별 Variable 설정

### Production
- DATABASE_URL (production scope)
- API_KEY (production scope)

### Staging
- DATABASE_URL (staging scope)
- API_KEY (staging scope)
```

### .gitlab-ci.yml에서 Secret 사용

```yaml
deploy_production:
  stage: deploy
  script:
    - echo "Database URL: $DATABASE_URL"  # 로그에서 마스킹됨: [MASKED]
    - echo "Deploying with API Key..."
    - curl -H "Authorization: Bearer $API_KEY" https://api.example.com/deploy
  environment:
    name: production
  only:
    - main
```

### 파일 형태의 Secret

```yaml
deploy_with_certificate:
  stage: deploy
  script:
    # File 타입 Variable은 임시 파일로 저장됨
    - cat $SSL_CERTIFICATE > /tmp/cert.pem
    - scp -i /tmp/cert.pem app.jar user@server:/app/
  only:
    - main
```

### Secret 최적화 방법

```yaml
보안 Best Practices:

1. 절대 코드에 하드코딩하지 않기
   ❌ const API_KEY = "sk_live_123456789"
   ✅ const API_KEY = process.env.API_KEY

2. .env 파일을 Git에 커밋하지 않기
   # .gitignore
   .env
   .env.local
   .env.*.local

3. Secret Rotation (주기적 갱신)
   - API Key: 3개월마다
   - Database Password: 6개월마다
   - SSL Certificate: 만료 전 갱신

4. 최소 권한 원칙
   - 각 환경별로 다른 Secret 사용
   - 필요한 권한만 부여

5. Secret Scanning 활성화
   - GitLab Secret Detection
   - Pre-commit hooks
   - 정기 감사
```

### Pre-commit Hook (Secret 방지)

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Gitleaks 설치 확인
if ! command -v gitleaks &> /dev/null; then
    echo "⚠️  Gitleaks가 설치되어 있지 않습니다."
    echo "설치: brew install gitleaks"
    exit 0
fi

# Secret 스캔
echo "🔍 Secret 스캔 중..."
gitleaks protect --staged --verbose

if [ $? -eq 1 ]; then
    echo ""
    echo "❌ Secret이 발견되었습니다!"
    echo "커밋을 중단합니다."
    exit 1
fi

echo "✅ Secret 스캔 통과"
```

</details>

---

## 👥 **PART 7: 팀 협업 Best Practices**

<details open>
<summary><strong>🤝 효과적인 협업 전략 (클릭하여 펼치기/접기)</strong></summary>

### 커뮤니케이션 원칙

```yaml
1. 투명성 (Transparency):
   - 모든 작업은 Issue로 추적
   - 진행 상황을 명확히 기록
   - 차단 사항은 즉시 공유

2. 비동기 커뮤니케이션:
   - MR 설명을 상세히 작성
   - 코드 주석으로 의도 설명
   - 문서화를 습관화

3. 존중과 건설적 피드백:
   - 코드 리뷰는 코드에 대한 것
   - 제안 형태로 피드백
   - 긍정적 피드백도 함께

4. 지식 공유:
   - Wiki 활용
   - README 작성
   - 팀 회고 정기 실시
```

</details>

### 📚 **7-1. Wiki 및 문서화**

<details open>
<summary><strong>📖 프로젝트 Wiki 구성 (클릭하여 보기)</strong></summary>

### Wiki 구조

```markdown
## Wiki Home

### 🏠 프로젝트 개요
- [프로젝트 소개](project-intro)
- [팀 구성원](team-members)
- [아키텍처](architecture)

### 🚀 시작하기
- [개발 환경 설정](dev-setup)
- [코딩 컨벤션](coding-conventions)
- [Git 워크플로우](git-workflow)

### 📋 개발 가이드
- [API 문서](api-docs)
- [데이터베이스 스키마](db-schema)
- [배포 가이드](deployment-guide)

### 🔧 운영
- [모니터링](monitoring)
- [장애 대응](incident-response)
- [백업/복구](backup-restore)

### 📊 프로세스
- [스프린트 계획](sprint-planning)
- [코드 리뷰 가이드](code-review-guide)
- [릴리스 프로세스](release-process)

### 📝 회의록
- [주간 스탠드업](weekly-standup)
- [Sprint Retrospective](sprint-retro)
```

### API 문서 예시

```markdown
## User API

### GET /api/users/:id

사용자 정보를 조회합니다.

**Parameters:**
- `id` (required): 사용자 ID

**Response:**
```json
{
  "id": 123,
  "username": "johndoe",
  "email": "john@example.com",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Status Codes:**
- `200`: Success
- `404`: User not found
- `401`: Unauthorized

**Example:**
```bash
curl -H "Authorization: Bearer $TOKEN" \
  https://api.example.com/api/users/123
```

### POST /api/users

새 사용자를 생성합니다.

**Request Body:**
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "secure_password"
}
```

**Response:**
```json
{
  "id": 124,
  "username": "johndoe",
  "email": "john@example.com",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Status Codes:**
- `201`: Created
- `400`: Bad Request (validation error)
- `409`: Conflict (user already exists)
```

</details>

### 🔄 **7-2. 회고 및 지속적 개선**

<details open>
<summary><strong>📊 Sprint Retrospective (클릭하여 보기)</strong></summary>

### 회고 템플릿

```markdown
# Sprint X Retrospective

**일시**: 2024-01-15  
**참석자**: Frontend Team, Backend Team, DevOps

---

## 😊 잘된 점 (What went well)

1. **CI/CD 파이프라인 개선**
   - 빌드 시간이 15분 → 8분으로 단축
   - 담당: @devops-team

2. **코드 리뷰 품질 향상**
   - 평균 리뷰 시간 단축 (24시간 → 12시간)
   - 담당: @tech-lead

3. **테스트 커버리지 증가**
   - 70% → 85%로 향상
   - 담당: @qa-team

---

## 😕 개선할 점 (What needs improvement)

1. **요구사항 변경이 잦았음**
   - 원인: PM과 개발팀 소통 부족
   - 영향: 3개 이슈가 Sprint 중간에 변경됨

2. **기술 부채 누적**
   - 원인: 빠른 개발에 집중하다 보니 리팩토링 미흡
   - 영향: 코드 복잡도 증가

3. **배포 중 장애 발생**
   - 원인: Staging 환경 테스트 불충분
   - 영향: 30분 다운타임

---

## 💡 액션 아이템 (Action items)

| 액션 아이템 | 담당자 | 기한 | 상태 |
|------------|--------|------|------|
| PM과 주 2회 싱크업 미팅 추가 | @product-manager | 다음 Sprint | ⏳ Todo |
| 기술 부채 해소 전용 시간 할당 (금요일 오후) | @tech-lead | 즉시 | ⏳ Todo |
| Staging 환경 자동화 테스트 추가 | @qa-team | 2주 | ⏳ Todo |
| 배포 체크리스트 문서화 | @devops-team | 1주 | ⏳ Todo |

---

## 📈 메트릭

- **완료율**: 85% (17/20 이슈)
- **평균 Lead Time**: 3.5일
- **평균 리뷰 시간**: 12시간
- **배포 빈도**: 주 3회
- **장애 건수**: 1건

---

## 🎯 다음 Sprint 목표

1. 사용자 대시보드 v2 완성
2. API 성능 30% 개선
3. 모바일 앱 베타 출시
```

### 회고 진행 방법

```markdown
## 회고 프로세스 (90분)

### 1단계: 준비 (5분)
- 참석자 확인
- 타이머 설정
- Ground Rules 공유

### 2단계: 데이터 수집 (20분)
- 각자 포스트잇에 의견 작성
  - 초록색: 잘된 점
  - 빨간색: 개선할 점
  - 파란색: 아이디어
- 보드에 붙이기

### 3단계: 인사이트 도출 (30분)
- 비슷한 의견 그룹화
- 투표로 우선순위 결정 (3표씩)
- 상위 3-5개 토론

### 4단계: 액션 아이템 결정 (25분)
- 구체적인 액션 아이템 도출
- 담당자 및 기한 지정
- SMART 원칙 적용
  - Specific (구체적)
  - Measurable (측정 가능)
  - Achievable (달성 가능)
  - Relevant (관련성)
  - Time-bound (기한 설정)

### 5단계: 마무리 (10분)
- 액션 아이템 요약
- 다음 회고 일정 확인
- 회고에 대한 피드백
```

</details>

---

## 🎯 [4단계] 최종 요약

### 💡 사용자 활용 핵심 체크리스트

```markdown
## ✅ 프로젝트 설정
- [ ] Group/Sub-group 구조 설계
- [ ] Project 템플릿 적용
- [ ] README, CONTRIBUTING 작성
- [ ] Issue/MR 템플릿 생성
- [ ] Label 분류 체계 정의

## ✅ Git 워크플로우
- [ ] 브랜치 전략 선택 (GitLab Flow 권장)
- [ ] Protected 브랜치 설정
- [ ] 브랜치 네이밍 규칙 정의
- [ ] Commit 메시지 규칙 적용
- [ ] Pre-commit hooks 설정

## ✅ Merge Request
- [ ] MR 생성 체크리스트 준비
- [ ] 코드 리뷰 가이드라인 수립
- [ ] 승인 정책 설정 (최소 승인자 수)
- [ ] 자동 테스트 연동
- [ ] Squash commits 활성화

## ✅ CI/CD 파이프라인
- [ ] .gitlab-ci.yml 작성
- [ ] 테스트 자동화 (Unit, Integration, E2E)
- [ ] 보안 스캔 통합 (SAST, Dependency)
- [ ] 환경별 배포 설정 (Staging, Production)
- [ ] Secret 관리 (CI/CD Variables)

## ✅ 이슈 관리
- [ ] Milestone 생성 (Sprint 단위)
- [ ] Scrum Board 구성
- [ ] Epic으로 큰 기능 관리
- [ ] 정기 Sprint 리뷰 실시

## ✅ 보안
- [ ] SAST 활성화
- [ ] Dependency Scanning 활성화
- [ ] Secret Detection 활성화
- [ ] Container Scanning 설정
- [ ] 취약점 대응 프로세스 수립

## ✅ 문서화
- [ ] Wiki 구조 설계
- [ ] API 문서 작성
- [ ] 아키텍처 문서화
- [ ] 온보딩 가이드 작성

## ✅ 팀 협업
- [ ] 코드 리뷰 문화 정착
- [ ] 정기 회고 실시
- [ ] 지식 공유 세션
- [ ] 페어 프로그래밍 (선택)
```

### 🚀 단계별 도입 로드맵

```yaml
Week 1-2: 기본 설정
  - Group/Project 구조 생성
  - 브랜치 전략 결정
  - 기본 템플릿 적용
  - 팀원 온보딩

Week 3-4: 워크플로우 정립
  - Git 워크플로우 교육
  - MR 프로세스 확립
  - 코드 리뷰 시작
  - 첫 Sprint 시작

Week 5-6: CI/CD 구축
  - 기본 파이프라인 작성
  - 테스트 자동화
  - Staging 배포 자동화
  - 모니터링 설정

Week 7-8: 보안 및 최적화
  - 보안 스캔 통합
  - 성능 최적화
  - 문서화 강화
  - 프로세스 개선

Week 9+: 지속적 개선
  - 정기 회고
  - 메트릭 추적
  - Best Practices 공유
  - 새로운 기능 도입
```

### 📊 성공 지표 (KPI)

```yaml
개발 속도:
  - Lead Time: < 3일
  - Deployment Frequency: 일 1회 이상
  - MR 처리 시간: < 24시간

품질:
  - 테스트 커버리지: > 80%
  - Code Review 참여율: 100%
  - 프로덕션 버그: < 월 5건
  - MTTR (Mean Time To Recovery): < 1시간

보안:
  - Critical 취약점: 0건
  - High 취약점 해결 시간: < 24시간
  - Secret 노출 사고: 0건

협업:
  - MR 승인율: > 95%
  - 문서화율: > 90% (모든 주요 기능)
  - Sprint 목표 달성률: > 85%
```

---

## 📚 추가 학습 리소스

```markdown
## 공식 문서
- GitLab Docs: https://docs.gitlab.com/
- GitLab CI/CD: https://docs.gitlab.com/ee/ci/
- GitLab Workflow: https://docs.gitlab.com/ee/topics/gitlab_flow.html

## 커뮤니티
- GitLab Forum: https://forum.gitlab.com/
- Stack Overflow: [gitlab] 태그
- Reddit: r/gitlab

## 학습 자료
- GitLab Learn: https://about.gitlab.com/learn/
- GitLab Handbook: https://about.gitlab.com/handbook/
- Udemy GitLab 강의

## 인증
- GitLab Certified Associate
- GitLab Certified DevOps Professional
```

---

**🎉 GitLab 사용자 활용 가이드 완료!**

이제 **GitLab 전체 가이드 (구축 → 운영 → 활용)**가 모두 완성되었습니다!

```
다음 단계를 선택하세요:

A. 특정 주제 심화 (예: "고급 CI/CD 패턴", "멀티 프로젝트 파이프라인")
B. 실전 예제 프로젝트 (End-to-End 데모)
C. 팀별 맞춤 가이드 (Frontend/Backend/DevOps)
D. 트러블슈팅 FAQ 모음
E. 전체 가이드 통합 문서 생성 (PDF/Markdown)
F. 특정 질문
```

어떤 부분을 더 알고 싶으신가요? 😊