# 🚀 GitHub 구축/운영/사용을 위한 종합 가이드라인 설계 전략

## 🧠 사고 프로세스 (Thinking Approach)

### 🎯 문제 재정의 (Problem Redefinition)

**원래 질문**: "GitHub 가이드라인을 어떻게 만들어야 하나?"

**재정의된 핵심 질문들**:
1. GitHub **Enterprise vs Cloud** - 어떻게 구분하여 다룰 것인가?
2. **GitLab과의 차이점**을 어떻게 명확히 할 것인가?
3. **GitHub 특화 기능**(Actions, Copilot, Advanced Security)을 어떻게 통합할 것인가?
4. **조직 구조**(Organization/Team/Repository)를 어떻게 설계할 것인가?

### 📊 다차원 분석 (Multi-Dimensional Analysis)

```
차원 1 (배포 모델): GitHub.com → GitHub Enterprise Cloud → GitHub Enterprise Server
차원 2 (사용자 레벨): 개인 개발자 → 팀 → 조직 → 엔터프라이즈
차원 3 (기능 스택): Git 기본 → CI/CD(Actions) → 보안(Advanced Security) → AI(Copilot)
차원 4 (통합 범위): 독립 사용 → IDE 통합 → 전사 DevOps 플랫폼
```

### 🔍 GitLab vs GitHub 핵심 차이점

| 구분 | GitLab | GitHub |
|------|--------|--------|
| **배포 모델** | Self-hosted 우선 | Cloud 우선 |
| **CI/CD** | 통합 (`.gitlab-ci.yml`) | 분리 (GitHub Actions) |
| **프로젝트 구조** | Group/Project 계층 | Organization/Repository 평탄 |
| **가격 모델** | 사용자당 + 기능별 | 사용자당 + 저장소 기반 |
| **강점** | 통합 DevOps 플랫폼 | 오픈소스 커뮤니티 + AI 통합 |

---

## 📋 [1단계] 사전 준비 요약 (Pre-brief Summary)

### 🌟 배경 (Background)

GitHub는 **세계 최대 소스코드 호스팅 플랫폼**이자 **개발자 커뮤니티**입니다. GitLab이 "통합 DevOps 플랫폼"이라면, GitHub는 **"협업 중심 + AI 강화 개발 환경"**입니다.

**핵심 특징**:
- **GitHub.com**: 공개 저장소 무료, 전 세계 1억+ 개발자
- **GitHub Actions**: YAML 기반 CI/CD, 마켓플레이스
- **GitHub Copilot**: AI 코드 자동완성
- **GitHub Advanced Security**: SAST/Dependabot/Secret Scanning
- **GitHub Enterprise**: 클라우드(GHEC) 또는 온프레미스(GHES)

### 🎯 범위 (Scope)

```
🏗️ 배포 선택 (Deployment Options)
   ├── GitHub.com (무료/팀/엔터프라이즈)
   ├── GitHub Enterprise Cloud (GHEC)
   └── GitHub Enterprise Server (GHES)

🔧 관리 영역 (Management)
   ├── 조직/팀 구조 설계
   ├── 권한 및 보안 정책
   ├── 라이선스 관리
   └── 감사 로그 및 컴플라이언스

👥 사용 영역 (Usage)
   ├── Git 워크플로우
   ├── GitHub Actions (CI/CD)
   ├── Issues/Projects/Discussions
   ├── Code Review (Pull Request)
   └── 보안 기능 활용
```

---

## ❓ [2단계] 핵심 질문들 (Key Questions)

### Q1: GitHub.com vs GHEC vs GHES - 어떤 것을 선택해야 하나?

**결정 트리**:
```
시작
 ├─ 온프레미스 필요? (보안/규제)
 │   └─ YES → GHES (GitHub Enterprise Server)
 ├─ 고급 보안/컴플라이언스 필요?
 │   └─ YES → GHEC (GitHub Enterprise Cloud)
 ├─ 팀 규모 50명 이상?
 │   └─ YES → GitHub Team 이상
 └─ 개인/소규모 프로젝트?
     └─ YES → GitHub Free/Pro
```

**비교표**:

| 기능 | GitHub.com Free | Team | GHEC | GHES |
|------|----------------|------|------|------|
| 공개 저장소 | 무제한 | 무제한 | 무제한 | 무제한 |
| 비공개 저장소 | 무제한 | 무제한 | 무제한 | 무제한 |
| Actions 분/월 | 2,000 | 3,000 | 50,000 | 무제한 |
| Advanced Security | ❌ | ❌ | ✅ | ✅ |
| SAML SSO | ❌ | ❌ | ✅ | ✅ |
| 감사 로그 | 제한적 | 제한적 | 고급 | 고급 |
| SLA | ❌ | ❌ | 99.9% | 사용자 관리 |

### Q2: 조직 구조를 어떻게 설계해야 하나?

**권장 구조** (대기업 기준):

```
🏢 Enterprise Account (엔터프라이즈)
   ├── 📦 Organization: Frontend-Team
   │   ├── Team: React-Developers
   │   ├── Team: Vue-Developers
   │   └── Repositories: 
   │       ├── web-app-main (Private)
   │       └── design-system (Internal)
   │
   ├── 📦 Organization: Backend-Team
   │   ├── Team: API-Developers
   │   ├── Team: Database-Admins
   │   └── Repositories:
   │       ├── api-gateway (Private)
   │       └── microservices (Private)
   │
   └── 📦 Organization: DevOps-Platform
       ├── Team: Infrastructure
       ├── Team: Security
       └── Repositories:
           ├── terraform-modules (Internal)
           ├── github-actions-workflows (Internal)
           └── security-policies (Private)
```

**원칙**:
1. **Organization 분리**: 비즈니스 도메인 또는 팀 단위
2. **Team 활용**: 저장소 권한을 개별이 아닌 팀 단위로 부여
3. **저장소 가시성**: Public < Internal < Private
4. **CODEOWNERS**: 자동 리뷰어 지정

### Q3: GitHub Actions를 어떻게 표준화할 것인가?

**접근 방법**:

#### A. 재사용 가능한 워크플로우 구조

```
📁 .github/
   ├── workflows/
   │   ├── 01-reusable-build.yml      (재사용 가능)
   │   ├── 02-reusable-test.yml       (재사용 가능)
   │   ├── 03-reusable-deploy.yml     (재사용 가능)
   │   └── main-pipeline.yml          (호출자)
   └── actions/
       ├── setup-environment/         (커스텀 액션)
       └── notify-slack/              (커스텀 액션)
```

**예시: 재사용 워크플로우**
```yaml
# .github/workflows/reusable-build.yml
name: Reusable Build Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string
      working-directory:
        required: false
        type: string
        default: '.'
    secrets:
      npm-token:
        required: true

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ inputs.working-directory }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: 'npm'
      
      - name: Install Dependencies
        env:
          NPM_TOKEN: ${{ secrets.npm-token }}
        run: npm ci
      
      - name: Build
        run: npm run build
      
      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: ${{ inputs.working-directory }}/dist
```

**호출 예시**:
```yaml
# .github/workflows/main-pipeline.yml
name: Main Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
    with:
      node-version: '20.x'
      working-directory: './frontend'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}
  
  test:
    needs: build
    uses: ./.github/workflows/reusable-test.yml
```

---

## ✅ [3단계] 답변 - GitHub 가이드라인 설계 전략

### 📚 가이드라인 구조 (Table of Contents)

```markdown
# 🚀 GitHub Enterprise 종합 가이드 v2.0

## 🌟 Part 0: GitHub 시작하기
├── 0.1 GitHub vs GitLab vs Bitbucket 비교
├── 0.2 용어사전 (Repository/Organization/Team/Actions)
├── 0.3 아키텍처 개요 (GHEC vs GHES)
└── 0.4 역할별 빠른 시작 가이드

## 🏗️ Part 1: 배포 및 초기 설정 (Deployment)

### 1.1 배포 모델 선택
├── 1.1.A GitHub.com (SaaS)
├── 1.1.B GitHub Enterprise Cloud (GHEC)
└── 1.1.C GitHub Enterprise Server (GHES)
    ├── 하드웨어 요구사항
    ├── 설치 (AWS/Azure/GCP/온프레미스)
    └── 고가용성 (HA) 구성

### 1.2 엔터프라이즈 계정 설정
├── 엔터프라이즈 생성
├── 조직(Organization) 구조 설계
├── 팀(Team) 관리 전략
└── 라이선스 할당

### 1.3 인증 및 권한 관리
├── SAML SSO 연동 (Okta/Azure AD)
├── SCIM 자동 프로비저닝
├── 팀 동기화 (Team Sync)
└── 2단계 인증(2FA) 강제

### 1.4 보안 정책 설정
├── Repository 생성 정책
├── Branch Protection Rules
├── Secret Scanning 활성화
├── Dependabot 설정
└── Code Scanning (SAST)

### 1.5 네트워크 및 통합
├── IP 허용 목록
├── GitHub Connect (GHES ↔ GHEC)
├── Webhook 설정
└── API 토큰 관리

---

## 🔧 Part 2: 운영 및 관리 (Operations)

### 2.1 조직 관리
├── 조직 설정 템플릿
├── Repository 명명 규칙
├── 기본 브랜치 전략 (main/develop)
└── .github 저장소 (조직 프로필)

### 2.2 사용자 및 팀 관리
├── 역할 정의 (Owner/Member/Outside Collaborator)
├── 팀 계층 구조
├── 팀 권한 매트릭스
└── 게스트 액세스 관리

### 2.3 라이선스 및 비용 관리
├── 시트(Seat) 사용량 모니터링
├── Actions 분(Minutes) 최적화
├── Packages/LFS 스토리지 관리
└── 비용 알림 설정

### 2.4 백업 및 복구 (GHES 전용)
├── 자동 백업 스케줄
├── 복구 절차 (RTO/RPO)
├── 재해 복구 테스트
└── 마이그레이션 (GHES → GHEC)

### 2.5 모니터링 및 감사
├── 감사 로그 분석
├── Webhooks 기반 알림
├── GitHub Insights (메트릭)
└── 컴플라이언스 리포트

### 2.6 업그레이드 및 유지보수 (GHES)
├── 업그레이드 계획
├── 핫패치 적용
├── 롤백 절차
└── 다운타임 최소화 전략

---

## 👥 Part 3: 개발자 사용 가이드 (Developer Usage)

### 3.1 Git 기본 워크플로우
├── Git Flow vs GitHub Flow
├── Feature Branch 전략
├── Commit 메시지 규칙 (Conventional Commits)
└── .gitignore 템플릿

### 3.2 Repository 관리
├── README.md 작성 베스트 프랙티스
├── 라이선스 선택 가이드
├── CONTRIBUTING.md 작성
├── Issue/PR 템플릿
└── CODEOWNERS 설정

### 3.3 Pull Request (PR) 프로세스
├── PR 생성 체크리스트
├── 코드 리뷰 가이드
│   ├── 리뷰어 역할
│   ├── 리뷰 체크포인트
│   └── 피드백 작성법
├── Draft PR 활용
├── Auto-merge 설정
└── Squash/Rebase 전략

### 3.4 Issues 및 프로젝트 관리
├── Issue 작성 가이드
├── Labels 체계
├── Milestones 전략
├── GitHub Projects (Kanban)
└── Discussions 활용

### 3.5 GitHub Actions (CI/CD)
├── 기본 개념
│   ├── Workflow/Job/Step 구조
│   ├── Runners (GitHub-hosted vs Self-hosted)
│   ├── Secrets/Variables 관리
│   └── Contexts/Expressions
│
├── 워크플로우 템플릿
│   ├── 언어별 빌드
│   │   ├── Python (Django/Flask/FastAPI)
│   │   ├── Java (Maven/Gradle/Spring Boot)
│   │   ├── Node.js (npm/yarn/pnpm)
│   │   ├── Go
│   │   └── Rust
│   │
│   ├── 테스트 자동화
│   │   ├── 단위 테스트
│   │   ├── 통합 테스트
│   │   └── E2E 테스트 (Playwright/Cypress)
│   │
│   ├── 보안 스캔
│   │   ├── CodeQL (SAST)
│   │   ├── Dependency Review
│   │   ├── Container Scanning
│   │   └── Secret Scanning
│   │
│   └── 배포 전략
│       ├── Docker 이미지 빌드/푸시
│       ├── Kubernetes 배포
│       ├── AWS (ECS/Lambda/S3)
│       ├── Azure (App Service/Functions)
│       └── GCP (Cloud Run/GKE)
│
├── 재사용 가능한 워크플로우
├── Composite Actions 개발
├── Marketplace Actions 활용
└── 성능 최적화
    ├── 캐싱 전략
    ├── 매트릭스 빌드
    ├── 병렬 실행
    └── Self-hosted Runners

### 3.6 GitHub Packages
├── Container Registry (GHCR)
├── npm/Maven/NuGet Registry
├── 패키지 버전 관리
└── 패키지 보안 스캔

### 3.7 GitHub Copilot 활용
├── IDE 통합 (VS Code/JetBrains)
├── Copilot Chat 사용법
├── 코드 제안 수락/거부 전략
└── 조직 정책 설정

### 3.8 보안 기능 활용
├── Dependabot Alerts 대응
├── Security Advisories 발행
├── Secret Scanning 알림 처리
└── 취약점 수정 PR 자동화

---

## 🚀 Part 4: 고급 주제 (Advanced Topics)

### 4.1 GitHub API 자동화
├── REST API vs GraphQL API
├── GitHub CLI (gh) 활용
├── GitHub Apps 개발
└── Webhooks 고급 활용

### 4.2 대규모 모노레포 관리
├── Git LFS 활용
├── Sparse Checkout
├── Submodules vs Subtrees
└── Monorepo 도구 (Nx/Turborepo)

### 4.3 Inner Source 전략
├── Inner Source 개념
├── 조직 간 협업 패턴
├── 기여 가이드 표준화
└── 메트릭 추적

### 4.4 GitHub Enterprise Importer
├── 마이그레이션 계획
├── GitLab/Bitbucket → GitHub
├── 이슈/PR 히스토리 보존
└── 대량 마이그레이션 자동화

### 4.5 커스텀 통합
├── Slack/Teams 통합
├── Jira/Asana 연동
├── Datadog/Prometheus 모니터링
└── 커스텀 대시보드

---

## 📊 Part 5: 베스트 프랙티스 (Best Practices)

### 5.1 보안 베스트 프랙티스
├── 최소 권한 원칙
├── Secrets 관리 (GitHub Secrets/Vault)
├── 의존성 업데이트 자동화
├── SBOM (Software Bill of Materials)
└── 보안 점검 체크리스트

### 5.2 성능 최적화
├── Git 저장소 크기 관리
├── Actions 비용 최적화
├── LFS 대안 (Git Annex)
└── 대용량 파일 처리

### 5.3 협업 문화
├── 효과적인 코드 리뷰 문화
├── 비동기 커뮤니케이션
├── Documentation-Driven Development
└── 오픈소스 기여 장려

### 5.4 DevOps 통합
├── GitOps (ArgoCD/Flux)
├── Infrastructure as Code (Terraform)
├── Feature Flags
└── Observability (로그/메트릭/트레이싱)

---

## 📋 Appendix

### A. 체크리스트 모음
├── 신규 프로젝트 시작 체크리스트
├── PR 생성 전 체크리스트
├── 보안 점검 체크리스트
└── 프로덕션 배포 체크리스트

### B. 트러블슈팅 가이드
├── Git 문제 해결
├── Actions 디버깅
├── 권한 문제 해결
└── 성능 문제 진단

### C. 템플릿 라이브러리
├── .github 저장소 템플릿
├── Workflow 템플릿
├── Issue/PR 템플릿
└── SECURITY.md 템플릿

### D. 참고 자료
├── GitHub 공식 문서
├── GitHub Changelog
├── GitHub Community Forum
└── GitHub Skills (학습 코스)
```

---

## 🎨 실전 예시 - Part 3.5 "GitHub Actions 심화"

<details>
<summary>🔽 펼치기: 재사용 가능한 워크플로우 패턴</summary>

### 📁 저장소 구조

```
my-organization/
├── github-workflows-library/         # 중앙 워크플로우 저장소
│   └── .github/workflows/
│       ├── reusable-build-nodejs.yml
│       ├── reusable-test-nodejs.yml
│       ├── reusable-deploy-k8s.yml
│       └── reusable-security-scan.yml
│
└── my-application/                   # 실제 애플리케이션
    └── .github/workflows/
        └── ci-cd.yml                 # 재사용 워크플로우 호출
```

### 🔧 재사용 워크플로우: Node.js 빌드

```yaml
# github-workflows-library/.github/workflows/reusable-build-nodejs.yml
name: Reusable Node.js Build

on:
  workflow_call:
    inputs:
      node-version:
        description: 'Node.js version'
        required: true
        type: string
      working-directory:
        description: 'Working directory'
        required: false
        type: string
        default: '.'
      package-manager:
        description: 'Package manager (npm/yarn/pnpm)'
        required: false
        type: string
        default: 'npm'
      cache-dependency-path:
        description: 'Path to package-lock.json or yarn.lock'
        required: false
        type: string
        default: 'package-lock.json'
    
    secrets:
      npm-token:
        description: 'NPM token for private packages'
        required: false
    
    outputs:
      artifact-name:
        description: 'Name of the build artifact'
        value: ${{ jobs.build.outputs.artifact-name }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      artifact-name: ${{ steps.upload.outputs.artifact-name }}
    
    defaults:
      run:
        working-directory: ${{ inputs.working-directory }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: ${{ inputs.package-manager }}
          cache-dependency-path: ${{ inputs.working-directory }}/${{ inputs.cache-dependency-path }}
      
      - name: Configure npm authentication
        if: secrets.npm-token != ''
        run: |
          echo "//registry.npmjs.org/:_authToken=${{ secrets.npm-token }}" > .npmrc
      
      - name: Install dependencies
        run: |
          if [ "${{ inputs.package-manager }}" = "npm" ]; then
            npm ci
          elif [ "${{ inputs.package-manager }}" = "yarn" ]; then
            yarn install --frozen-lockfile
          elif [ "${{ inputs.package-manager }}" = "pnpm" ]; then
            pnpm install --frozen-lockfile
          fi
      
      - name: Build application
        run: |
          if [ "${{ inputs.package-manager }}" = "npm" ]; then
            npm run build
          elif [ "${{ inputs.package-manager }}" = "yarn" ]; then
            yarn build
          elif [ "${{ inputs.package-manager }}" = "pnpm" ]; then
            pnpm build
          fi
      
      - name: Upload build artifacts
        id: upload
        uses: actions/upload-artifact@v4
        with:
          name: build-${{ github.sha }}
          path: ${{ inputs.working-directory }}/dist
          retention-days: 7
```

### 🔧 재사용 워크플로우: 보안 스캔

```yaml
# github-workflows-library/.github/workflows/reusable-security-scan.yml
name: Reusable Security Scan

on:
  workflow_call:
    inputs:
      language:
        description: 'Language for CodeQL (javascript/python/java/go/ruby/cpp/csharp)'
        required: true
        type: string
      working-directory:
        description: 'Working directory'
        required: false
        type: string
        default: '.'
      fail-on-severity:
        description: 'Fail on severity (critical/high/medium/low)'
        required: false
        type: string
        default: 'high'

jobs:
  codeql-analysis:
    name: CodeQL Analysis
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
      actions: read
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: ${{ inputs.language }}
          queries: security-extended
      
      - name: Autobuild
        uses: github/codeql-action/autobuild@v3
      
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
        with:
          category: "/language:${{ inputs.language }}"
  
  dependency-review:
    name: Dependency Review
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    permissions:
      contents: read
      pull-requests: write
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: ${{ inputs.fail-on-severity }}
          comment-summary-in-pr: always
  
  secret-scanning:
    name: Secret Scanning
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: TruffleHog Scan
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
          extra_args: --only-verified
```

### 🔧 재사용 워크플로우: Kubernetes 배포

```yaml
# github-workflows-library/.github/workflows/reusable-deploy-k8s.yml
name: Reusable Kubernetes Deployment

on:
  workflow_call:
    inputs:
      environment:
        description: 'Deployment environment (dev/staging/prod)'
        required: true
        type: string
      cluster-name:
        description: 'Kubernetes cluster name'
        required: true
        type: string
      namespace:
        description: 'Kubernetes namespace'
        required: true
        type: string
      image-tag:
        description: 'Docker image tag'
        required: true
        type: string
      manifest-path:
        description: 'Path to Kubernetes manifests'
        required: false
        type: string
        default: 'k8s'
    
    secrets:
      kube-config:
        description: 'Kubernetes config'
        required: true
      registry-username:
        description: 'Container registry username'
        required: true
      registry-password:
        description: 'Container registry password'
        required: true

jobs:
  deploy:
    name: Deploy to ${{ inputs.environment }}
    runs-on: ubuntu-latest
    environment:
      name: ${{ inputs.environment }}
      url: https://${{ inputs.environment }}.example.com
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'latest'
      
      - name: Configure kubectl
        run: |
          mkdir -p $HOME/.kube
          echo "${{ secrets.kube-config }}" | base64 -d > $HOME/.kube/config
          chmod 600 $HOME/.kube/config
      
      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ secrets.registry-username }}
          password: ${{ secrets.registry-password }}
      
      - name: Render Kubernetes manifests
        uses: azure/k8s-bake@v2
        with:
          renderEngine: 'kustomize'
          kustomizationPath: ${{ inputs.manifest-path }}/overlays/${{ inputs.environment }}
        id: bake
      
      - name: Deploy to Kubernetes
        uses: azure/k8s-deploy@v4
        with:
          namespace: ${{ inputs.namespace }}
          manifests: ${{ steps.bake.outputs.manifestsBundle }}
          images: |
            ghcr.io/${{ github.repository }}:${{ inputs.image-tag }}
          strategy: rolling
          action: deploy
      
      - name: Verify deployment
        run: |
          kubectl rollout status deployment/my-app -n ${{ inputs.namespace }} --timeout=5m
          kubectl get pods -n ${{ inputs.namespace }}
      
      - name: Run smoke tests
        run: |
```yaml
          # 배포 후 헬스체크
          kubectl run smoke-test --image=curlimages/curl:latest --rm -i --restart=Never -- \
            curl -f http://my-app-service.${{ inputs.namespace }}.svc.cluster.local/health || exit 1
      
      - name: Rollback on failure
        if: failure()
        run: |
          echo "Deployment failed, rolling back..."
          kubectl rollout undo deployment/my-app -n ${{ inputs.namespace }}
          kubectl rollout status deployment/my-app -n ${{ inputs.namespace }} --timeout=5m
      
      - name: Notify deployment status
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: |
            Deployment to ${{ inputs.environment }} - ${{ job.status }}
            Cluster: ${{ inputs.cluster-name }}
            Namespace: ${{ inputs.namespace }}
            Image: ${{ inputs.image-tag }}
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 🚀 호출 워크플로우: 통합 CI/CD

```yaml
# my-application/.github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  workflow_dispatch:
    inputs:
      deploy-environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
          - dev
          - staging
          - prod

env:
  NODE_VERSION: '20.x'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # ========================================
  # 1단계: 빌드
  # ========================================
  build:
    name: Build Application
    uses: my-organization/github-workflows-library/.github/workflows/reusable-build-nodejs.yml@main
    with:
      node-version: '20.x'
      working-directory: '.'
      package-manager: 'npm'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}
  
  # ========================================
  # 2단계: 테스트
  # ========================================
  test:
    name: Run Tests
    needs: build
    uses: my-organization/github-workflows-library/.github/workflows/reusable-test-nodejs.yml@main
    with:
      node-version: '20.x'
      test-command: 'npm test'
      coverage-threshold: 80
  
  # ========================================
  # 3단계: 보안 스캔
  # ========================================
  security:
    name: Security Scanning
    needs: build
    uses: my-organization/github-workflows-library/.github/workflows/reusable-security-scan.yml@main
    with:
      language: 'javascript'
      fail-on-severity: 'high'
    permissions:
      security-events: write
      contents: read
      actions: read
  
  # ========================================
  # 4단계: Docker 이미지 빌드 & 푸시
  # ========================================
  docker:
    name: Build & Push Docker Image
    needs: [test, security]
    if: github.event_name == 'push' || github.event_name == 'workflow_dispatch'
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-${{ github.sha }}
          path: ./dist
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILD_DATE=${{ github.event.head_commit.timestamp }}
            VCS_REF=${{ github.sha }}
  
  # ========================================
  # 5단계: 개발 환경 자동 배포
  # ========================================
  deploy-dev:
    name: Deploy to Development
    needs: docker
    if: github.ref == 'refs/heads/develop'
    uses: my-organization/github-workflows-library/.github/workflows/reusable-deploy-k8s.yml@main
    with:
      environment: 'dev'
      cluster-name: 'dev-cluster'
      namespace: 'my-app-dev'
      image-tag: ${{ needs.docker.outputs.image-tag }}
      manifest-path: 'k8s'
    secrets:
      kube-config: ${{ secrets.KUBE_CONFIG_DEV }}
      registry-username: ${{ github.actor }}
      registry-password: ${{ secrets.GITHUB_TOKEN }}
  
  # ========================================
  # 6단계: 스테이징 환경 배포 (승인 필요)
  # ========================================
  deploy-staging:
    name: Deploy to Staging
    needs: docker
    if: github.ref == 'refs/heads/main' || github.event.inputs.deploy-environment == 'staging'
    uses: my-organization/github-workflows-library/.github/workflows/reusable-deploy-k8s.yml@main
    with:
      environment: 'staging'
      cluster-name: 'staging-cluster'
      namespace: 'my-app-staging'
      image-tag: ${{ needs.docker.outputs.image-tag }}
      manifest-path: 'k8s'
    secrets:
      kube-config: ${{ secrets.KUBE_CONFIG_STAGING }}
      registry-username: ${{ github.actor }}
      registry-password: ${{ secrets.GITHUB_TOKEN }}
  
  # ========================================
  # 7단계: 프로덕션 환경 배포 (수동 승인 필수)
  # ========================================
  deploy-prod:
    name: Deploy to Production
    needs: [docker, deploy-staging]
    if: github.event.inputs.deploy-environment == 'prod'
    uses: my-organization/github-workflows-library/.github/workflows/reusable-deploy-k8s.yml@main
    with:
      environment: 'prod'
      cluster-name: 'prod-cluster'
      namespace: 'my-app-prod'
      image-tag: ${{ needs.docker.outputs.image-tag }}
      manifest-path: 'k8s'
    secrets:
      kube-config: ${{ secrets.KUBE_CONFIG_PROD }}
      registry-username: ${{ github.actor }}
      registry-password: ${{ secrets.GITHUB_TOKEN }}
```

</details>

---

<details>
<summary>🔽 펼치기: 조직 수준의 보안 정책 설정</summary>

### 🛡️ 1. Branch Protection Rules (브랜치 보호 규칙)

**적용 대상**: 모든 프로덕션 브랜치 (`main`, `master`)

```yaml
# .github/settings.yml (Probot Settings 사용 시)
repository:
  name: my-repo
  description: My awesome repository
  topics: [nodejs, github-actions, kubernetes]
  private: true
  has_issues: true
  has_projects: true
  has_wiki: false

branches:
  - name: main
    protection:
      # 최소 리뷰어 수
      required_pull_request_reviews:
        required_approving_review_count: 2
        dismiss_stale_reviews: true
        require_code_owner_reviews: true
        dismissal_restrictions:
          users: []
          teams: [tech-leads]
      
      # 상태 체크 필수
      required_status_checks:
        strict: true
        contexts:
          - "build"
          - "test"
          - "security-scan"
          - "codecov/patch"
          - "codecov/project"
      
      # 강제 푸시 금지
      enforce_admins: true
      
      # 삭제 방지
      required_linear_history: true
      allow_force_pushes: false
      allow_deletions: false
      
      # 대화 해결 필수
      required_conversation_resolution: true
```

### 🔒 2. CODEOWNERS 설정

```plaintext
# .github/CODEOWNERS
# 이 파일은 코드 소유권을 정의하고 자동 리뷰어를 지정합니다

# 기본 소유자 (모든 파일)
* @my-organization/tech-leads

# 프론트엔드
/frontend/** @my-organization/frontend-team
*.tsx @my-organization/react-developers
*.vue @my-organization/vue-developers

# 백엔드
/backend/** @my-organization/backend-team
/api/** @my-organization/api-developers

# 인프라
/terraform/** @my-organization/infrastructure @my-organization/security-team
/k8s/** @my-organization/devops @my-organization/infrastructure
Dockerfile @my-organization/devops
docker-compose.yml @my-organization/devops

# CI/CD
/.github/workflows/** @my-organization/devops @my-organization/tech-leads

# 보안 관련
/security/** @my-organization/security-team
SECURITY.md @my-organization/security-team

# 데이터베이스
/migrations/** @my-organization/database-team @my-organization/backend-team
/schema/** @my-organization/database-team

# 문서
/docs/** @my-organization/tech-writers
*.md @my-organization/tech-writers

# 특정 중요 파일
package.json @my-organization/tech-leads
package-lock.json @my-organization/tech-leads
requirements.txt @my-organization/tech-leads
go.mod @my-organization/tech-leads
```

### 🔐 3. Secret Scanning 커스텀 패턴

```yaml
# .github/secret-scanning.yml
# GitHub Advanced Security에서 사용

custom-patterns:
  - name: Internal API Key
    pattern: 'INTERNAL_API_[A-Z0-9]{32}'
    secret-type: internal_api_key
  
  - name: Database Connection String
    pattern: 'postgresql://[^:]+:[^@]+@[^/]+/[^\s]+'
    secret-type: database_url
  
  - name: AWS Access Key
    pattern: 'AKIA[0-9A-Z]{16}'
    secret-type: aws_access_key_id
  
  - name: Private Key
    pattern: '-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----'
    secret-type: private_key
  
  - name: JWT Token
    pattern: 'eyJ[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*'
    secret-type: jwt_token
```

### 📊 4. Code Scanning (CodeQL) 커스텀 설정

```yaml
# .github/codeql/codeql-config.yml
name: "Custom CodeQL Config"

queries:
  - uses: security-extended
  - uses: security-and-quality

paths-ignore:
  - 'node_modules'
  - 'dist'
  - 'build'
  - '**/*.test.ts'
  - '**/*.spec.ts'

paths:
  - 'src'
  - 'api'

query-filters:
  - exclude:
      id: js/unused-local-variable
  - include:
      severity: error
      tags:
        - security

# 커스텀 쿼리 추가
packs:
  - codeql/javascript-queries
  - my-organization/custom-security-queries
```

### 🚨 5. Dependabot 설정

```yaml
# .github/dependabot.yml
version: 2

updates:
  # NPM 의존성
  - package-ecosystem: "npm"
    directory: "/frontend"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
      timezone: "Asia/Seoul"
    open-pull-requests-limit: 10
    reviewers:
      - "my-organization/frontend-team"
    assignees:
      - "tech-lead"
    labels:
      - "dependencies"
      - "automerge"
    commit-message:
      prefix: "chore(deps)"
      include: "scope"
    # 자동 병합 설정 (패치/마이너 버전만)
    versioning-strategy: increase
    allow:
      - dependency-type: "direct"
    ignore:
      - dependency-name: "react"
        update-types: ["version-update:semver-major"]
  
  # Python 의존성
  - package-ecosystem: "pip"
    directory: "/backend"
    schedule:
      interval: "weekly"
    reviewers:
      - "my-organization/backend-team"
    labels:
      - "dependencies"
      - "python"
  
  # Docker 이미지
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
    reviewers:
      - "my-organization/devops"
    labels:
      - "dependencies"
      - "docker"
  
  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
    reviewers:
      - "my-organization/devops"
    labels:
      - "dependencies"
      - "github-actions"
  
  # Terraform
  - package-ecosystem: "terraform"
    directory: "/terraform"
    schedule:
      interval: "weekly"
    reviewers:
      - "my-organization/infrastructure"
    labels:
      - "dependencies"
      - "terraform"
```

### 🔄 6. Dependabot 자동 병합 워크플로우

```yaml
# .github/workflows/dependabot-auto-merge.yml
name: Dependabot Auto-Merge

on:
  pull_request:
    types: [opened, synchronize, reopened]

permissions:
  contents: write
  pull-requests: write

jobs:
  auto-merge:
    name: Auto-merge Dependabot PRs
    runs-on: ubuntu-latest
    if: github.actor == 'dependabot[bot]'
    
    steps:
      - name: Dependabot metadata
        id: metadata
        uses: dependabot/fetch-metadata@v1
        with:
          github-token: "${{ secrets.GITHUB_TOKEN }}"
      
      - name: Enable auto-merge for patch and minor updates
        if: |
          steps.metadata.outputs.update-type == 'version-update:semver-patch' ||
          steps.metadata.outputs.update-type == 'version-update:semver-minor'
        run: |
          gh pr merge --auto --squash "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Comment on major updates
        if: steps.metadata.outputs.update-type == 'version-update:semver-major'
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '⚠️ **Major version update detected!** Please review carefully before merging.'
            })
```

</details>

---

<details>
<summary>🔽 펼치기: GitHub Enterprise Server (GHES) 설치 가이드</summary>

### 🏗️ GHES 설치 - AWS 환경 기준

#### 📋 1. 사전 요구사항

**하드웨어 요구사항** (사용자 수 기준):

| 사용자 수 | vCPU | RAM | 루트 스토리지 | 데이터 스토리지 |
|----------|------|-----|--------------|----------------|
| 10-500 | 8 | 64 GB | 200 GB | 500 GB |
| 500-2000 | 16 | 128 GB | 200 GB | 1 TB |
| 2000-5000 | 32 | 256 GB | 200 GB | 2 TB |
| 5000+ | 64+ | 512 GB+ | 200 GB | 5 TB+ |

**네트워크 요구사항**:
```plaintext
포트 열기:
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)
- 8080 (관리 콘솔 - 초기 설정 시)
- 8443 (관리 콘솔 HTTPS)
- 9418 (Git 프로토콜 - 선택)
- 122 (SSH - HA 구성 시)
- 1194 (VPN - HA 구성 시)
```

#### ⚡ 2. AWS EC2 인스턴스 생성 (Terraform)

```hcl
# terraform/ghes-instance.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC 및 서브넷 (기존 VPC 사용 시 data source로 변경)
resource "aws_vpc" "ghes_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "ghes-vpc"
  }
}

resource "aws_subnet" "ghes_subnet" {
  vpc_id                  = aws_vpc.ghes_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "ghes-subnet"
  }
}

# 보안 그룹
resource "aws_security_group" "ghes_sg" {
  name        = "ghes-security-group"
  description = "Security group for GitHub Enterprise Server"
  vpc_id      = aws_vpc.ghes_vpc.id
  
  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }
  
  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # 관리 콘솔
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }
  
  # 모든 아웃바운드
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "ghes-sg"
  }
}

# EBS 볼륨 (데이터 스토리지)
resource "aws_ebs_volume" "ghes_data" {
  availability_zone = "${var.aws_region}a"
  size              = var.data_volume_size  # 예: 500
  type              = "gp3"
  iops              = 16000
  throughput        = 1000
  encrypted         = true
  
  tags = {
    Name = "ghes-data-volume"
  }
}

# EC2 인스턴스
resource "aws_instance" "ghes" {
  ami           = var.ghes_ami  # GitHub에서 제공하는 AMI
  instance_type = var.instance_type  # 예: r6i.4xlarge
  subnet_id     = aws_subnet.ghes_subnet.id
  
  vpc_security_group_ids = [aws_security_group.ghes_sg.id]
  
  root_block_device {
    volume_size = 200
    volume_type = "gp3"
    encrypted   = true
  }
  
  user_data = file("${path.module}/user-data.sh")
  
  tags = {
    Name = "github-enterprise-server"
  }
}

# 데이터 볼륨 연결
resource "aws_volume_attachment" "ghes_data_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ghes_data.id
  instance_id = aws_instance.ghes.id
}

# Elastic IP
resource "aws_eip" "ghes_eip" {
  domain   = "vpc"
  instance = aws_instance.ghes.id
  
  tags = {
    Name = "ghes-eip"
  }
}

# Route53 DNS 레코드 (선택)
resource "aws_route53_record" "ghes" {
  zone_id = var.route53_zone_id
  name    = "github.example.com"
  type    = "A"
  ttl     = 300
  records = [aws_eip.ghes_eip.public_ip]
}

# S3 백업 버킷
resource "aws_s3_bucket" "ghes_backups" {
  bucket = "ghes-backups-${var.environment}"
  
  tags = {
    Name = "ghes-backups"
  }
}

resource "aws_s3_bucket_versioning" "ghes_backups" {
  bucket = aws_s3_bucket.ghes_backups.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ghes_backups" {
  bucket = aws_s3_bucket.ghes_backups.id
  
  rule {
    id     = "delete-old-backups"
    status = "Enabled"
    
    expiration {
      days = 90
    }
  }
}

# 출력
output "ghes_public_ip" {
  value = aws_eip.ghes_eip.public_ip
}

output "ghes_dns" {
  value = "https://github.example.com"
}

output "management_console" {
  value = "https://github.example.com:8443/setup"
}
```

#### 🔧 3. 초기 설정 스크립트

```bash
#!/bin/bash
# user-data.sh - EC2 인스턴스 초기화 스크립트

set -e

# 로그 파일
LOG_FILE="/var/log/ghes-init.log"
exec > >(tee -a ${LOG_FILE})
exec 2>&1

echo "=== GitHub Enterprise Server 초기화 시작 ==="
echo "시작 시간: $(date)"

# 데이터 볼륨 마운트 대기
echo "데이터 볼륨 대기 중..."
while [ ! -b /dev/xvdf ]; do
  sleep 5
done

# 데이터 볼륨 파일시스템 생성 (처음만)
if ! blkid /dev/xvdf; then
  echo "데이터 볼륨 포맷 중..."
  mkfs.ext4 /dev/xvdf
fi

# 마운트 포인트 생성
mkdir -p /data

# /etc/fstab에 추가
if ! grep -q "/dev/xvdf" /etc/fstab; then
  echo "/dev/xvdf /data ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# 마운트
mount -a

echo "=== 초기화 완료 ==="
echo "관리 콘솔: https://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8443/setup"
```

#### 🌐 4. 웹 UI를 통한 설정

```plaintext
1. 브라우저에서 https://<PUBLIC_IP>:8443/setup 접속

2. 라이선스 업로드
   - GitHub Enterprise Server 라이선스 파일 (.ghl) 업로드

3. 관리자 비밀번호 설정
   - 강력한 비밀번호 입력 (최소 8자, 대소문자/숫자/특수문자 포함)

4. 기본 설정
   ├── Hostname: github.example.com
   ├── Protocol: HTTPS
   ├── SSL Certificate: Let's Encrypt 자동 또는 커스텀 업로드
   └── 타임존: Asia/Seoul

5. 인증 설정
   ├── Built-in: 기본 인증
   ├── LDAP: Active Directory 연동
   └── SAML: Okta/Azure AD 연동

6. 이메일 설정
   ├── SMTP 서버: smtp.gmail.com:587
   ├── 인증 정보 입력
   └── 테스트 이메일 발송

7. S3 백업 설정
   ├── AWS Region: ap-northeast-2
   ├── S3 Bucket: ghes-backups-prod
   ├── IAM Credentials 입력
   └── 백업 스케줄: 매일 02:00 (KST)

8. 설정 완료 및 재시작
```

#### ✅ 5. 설치 검증

```bash
#!/bin/bash
# verify-ghes-installation.sh

echo "=== GHES 설치 검증 ==="

# 1. 서비스 상태 확인
echo "1. 서비스 상태 확인..."
ssh -p 122 admin@github.example.com 'ghe-cluster-status -v'

# 2. 웹 UI 접속 테스트
echo "2. 웹 UI 테스트..."
HTTP_CODE=$(curl -sk -o /dev/null -w '%{http_code}' https://github.example.com)
if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "302" ]; then
  echo "✅ 웹 UI 정상"
else
  echo "❌ 웹 UI 오류 (HTTP $HTTP_CODE)"
  exit 1
fi

# 3. API 테스트
echo "3. API 테스트..."
API_RESPONSE=$(curl -sk https://github.example.com/api/v3/meta)
if echo "$API_RESPONSE" | jq -e '.verifiable_password_authentication' > /dev/null; then
  echo "✅ API 정상"
else
  echo "❌ API 오류"
  exit 1
fi

# 4. Git 프로토콜 테스트
echo "4. Git 프로토콜 테스트..."
git ls-remote https://github.example.com/test/test.git > /dev/null 2>&1
if [ $? -eq 0 ] || [ $? -eq 128 ]; then  # 128은 저장소가 없는 경우
  echo "✅ Git 프로토콜 정상"
else
  echo "❌ Git 프로토콜 오류"
fi

# 5. SSL 인증서 확인
echo "5. SSL 인증서 확인..."
CERT_EXPIRY=$(echo | openssl s_client -servername github.example.com -connect github.example.com:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
echo "인증서 만료일: $CERT_EXPIRY"

# 6. 디스크 사용량
echo "6. 디스크 사용량..."
ssh -p 122 admin@github.example.com 'df -h /data'

echo ""
echo "=== 검증 완료 ==="
```

#### 🔄 6. 백업 및 복구 자동화

```bash
#!/bin/bash
# backup-ghes.sh - 자동 백업 스크립트

BACKUP_HOST="github.example.com"
BACKUP_USER="admin"
BACKUP_PORT=122
S3_BUCKET="s3://ghes-backups-prod"
RETENTION_DAYS=90

# 백업 실행
echo "$(date): 백업 시작"
ssh -p $BACKUP_PORT $BACKUP_USER@$BACKUP_HOST 'ghe-backup'

# S3 동기화 (이미 ghe-backup에서 처리하지만 추가 안전장치)
aws s3 sync /data/user/common/ghe-backup/ $S3_BUCKET/ --delete

# 오래된 백업 삭제
find /data/user/common/ghe-backup/* -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;

echo "$(date): 백업 완료"
```

**Cron 설정**:
```bash
# crontab -e
0 2 * * * /usr/local/bin/backup-ghes.sh >> /var/log/ghes-backup.log 2>&1
```

---

## 🎨 Part 4: GitHub 특화 기능 활용

<details>
<summary>🔽 펼치기: GitHub Copilot 조직 관리</summary>

### 🤖 GitHub Copilot 엔터프라이즈 설정

#### 📋 1. 조직 수준 정책 설정

```yaml
# .github/copilot-policy.yml
organization: my-organization

# Copilot 활성화 설정
copilot:
  enabled: true
  
  # 사용자 그룹별 액세스 제어
  user_access:
    # 모든 멤버에게 허용
    - type: all_members
      enabled: true
    
    # 특정 팀만 허용
    # - type: selected_teams
    #   teams:
    #     - engineering
    #     - product
  
  # 기능별 설정
  features:
    # 코드 제안
    suggestions:
      enabled: true
      
    # Copilot Chat
    chat:
      enabled: true
      # 웹/모바일/IDE 모두 허용
      platforms: [web, mobile, ide]
    
    # CLI 통합
    cli:
      enabled: true
    
    # Pull Request 요약
    pull_request_summaries:
      enabled: true
      auto_generate: true
  
  # 콘텐츠 제외 설정
  content_exclusions:
    # 공개 코드와 매칭 차단
    block_public_code_matches: true
    
    # 특정 저장소 제외
    excluded_repositories:
      - internal-secrets
      - legacy-codebase
    
    # 파일 패턴 제외
    excluded_file_patterns:
      - "*.env"
      - "*.key"
      - "*.pem"
      - "secrets/**"
      - "credentials/**"
  
  # 사용량 및 감사
  telemetry:
    # 사용 데이터 수집 (개인정보 제외)
    enabled: true
    
    # 프롬프트 및 제안 로깅 (보안 감사용)
    audit_logging: true

# 정책 위반 시 동작
enforcement:
  # 위반 시 경고만
  mode: warn  # warn | block
  
  # 알림 대상
  notifications:
    - security-team@example.com
    - compliance@example.com
```

#### 🔒 2. 보안 가이드라인

**개발자 교육 자료**:

```markdown
# 🤖 GitHub Copilot 안전 사용 가이드

## ✅ DO (권장 사항)

### 1. 코드 제안 검증
- ✅ Copilot 제안을 **항상 검토**한 후 수락
- ✅ 보안에 민감한 코드는 **수동으로 작성**
- ✅ 생성된 코드에 **단위 테스트** 작성
- ✅ 코드 리뷰에서 Copilot 사용 여부 명시

### 2. 민감 정보 보호
- ✅ `.env` 파일은 `.gitignore`에 추가
- ✅ 하드코딩된 비밀번호/키 절대 금지
- ✅ GitHub Secrets 사용
- ✅ Pre-commit hook으로 시크릿 스캔

### 3. 라이선스 확인
- ✅ 생성된 코드의 라이선스 호환성 확인
- ✅ 공개 코드 매칭 알림 확인
- ✅ 조직 라이선스 정책 준수

## ❌ DON'T (금지 사항)

### 1. 민감 정보 노출
- ❌ API 키를 주석에 포함
- ❌ 데이터베이스 비밀번호 하드코딩
- ❌ 고객 개인정보를 예시로 사용
- ❌ 내부 시스템 URL/IP를 공개 저장소에 커밋

### 2. 무분별한 사용
- ❌ 제안을 검토 없이 자동 수락
- ❌ 이해하지 못한 코드 병합
- ❌ 보안 취약점 무시
- ❌ 테스트 없이 프로덕션 배포

### 3. 정책 위반
- ❌ 제외된 저장소에서 Copilot 사용
- ❌ 감사 로그 비활성화
- ❌ 조직 정책 우회

## 🔍 예시: 안전한 사용 패턴

### Bad ❌
```python
# Copilot이 제안한 코드를 그대로 사용
api_key = "sk-1234567890abcdef"  # 하드코딩!
db_password = "admin123"  # 취약한 비밀번호!
```

### Good ✅
```python
# 환경 변수 사용
import os
from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv("API_KEY")
db_password = os.getenv("DB_PASSWORD")

if not api_key or not db_password:
    raise ValueError("필수 환경 변수가 설정되지 않았습니다")
```

## 📊 사용량 모니터링

개발자는 개인 대시보드에서 다음을 확인할 수 있습니다:
- 제안 수락률
- 생산성 향상 통계
- 공개 코드 매칭 알림

관리자는 조직 대시보드에서 다음을 확인할 수 있습니다:
- 팀별 사용 현황
- 비용 분석
- 정책 위반 사항
```

#### 📊 3. 사용량 모니터링 대시보드

```python
#!/usr/bin/env python3
# scripts/copilot-usage-report.py

import os
import requests
from datetime import datetime, timedelta
import pandas as pd
import matplotlib.pyplot as plt

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
ORG_NAME = "my-organization"

headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28"
}

def get_copilot_usage(days=30):
    """Copilot 사용 데이터 가져오기"""
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)
    
    url = f"https://api.github.com/orgs/{ORG_NAME}/copilot/usage"
    params = {
        "since": start_date.isoformat(),
        "until": end_date.isoformat()
    }
    
    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    
    return response.json()

def get_copilot_seats():
    """Copilot 시트 할당 현황"""
    url = f"https://api.github.com/orgs/{ORG_NAME}/copilot/billing/seats"
    
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    
    return response.json()

def generate_usage_report():
    """사용량 리포트 생성"""
    print("📊 GitHub Copilot 사용량 리포트 생성 중...")
    
    # 사용 데이터
    usage_data = get_copilot_usage(days=30)
    
    # 시트 데이터
    seats_data = get_copilot_seats()
    
    # DataFrame 생성
    df_usage = pd.DataFrame(usage_data)
    df_usage['date'] = pd.to_datetime(df_usage['day'])
    
    # 통계 계산
    total_suggestions = df_usage['total_suggestions_count'].sum()
    total_acceptances = df_usage['total_acceptances_count'].sum()
    acceptance_rate = (total_acceptances / total_suggestions * 100) if total_suggestions > 0 else 0
    
    total_seats = seats_data['total_seats']
    active_users = len([s for s in seats_data['seats'] if s['last_activity_at']])
    
    # 리포트 출력
    print("\n" + "="*60)
    print("🤖 GitHub Copilot 사용 현황")
    print("="*60)
    print(f"기간: {df_usage['date'].min().date()} ~ {df_usage['date'].max().date()}")
    print(f"\n📈 전체 통계:")
    print(f"  - 총 시트 수: {total_seats}")
    print(f"  - 활성 사용자: {active_users} ({active_users/total_seats*100:.1f}%)")
    print(f"  - 총 제안 횟수: {total_suggestions:,}")
    print(f"  - 총 수락 횟수: {total_acceptances:,}")
    print(f"  - 수락률: {acceptance_rate:.2f}%")
    
    # 일별 트렌드 그래프
    plt.figure(figsize=(12, 6))
    
    plt.subplot(1, 2, 1)
    plt.plot(df_usage['date'], df_usage['total_suggestions_count'], label='제안', marker='o')
    plt.plot(df_usage['date'], df_usage['total_acceptances_count'], label='수락', marker='s')
    plt.xlabel('날짜')
    plt.ylabel('횟수')
    plt.title('일별 Copilot 사용량')
    plt.legend()
    plt.xticks(rotation=45)
    plt.grid(True, alpha=0.3)
    
    plt.subplot(1, 2, 2)
    acceptance_rates = (df_usage['total_acceptances_count'] / df_usage['total_suggestions_count'] * 100).fillna(0)
    plt.plot(df_usage['date'], acceptance_rates, color='green', marker='o')
    plt.xlabel('날짜')
    plt.ylabel('수락률 (%)')
    plt.title('일별 수락률')
    plt.xticks(rotation=45)
    plt.grid(True, alpha=0.3)
    plt.axhline(y=acceptance_rate, color='r', linestyle='--', label=f'평균: {acceptance_rate:.2f}%')
    plt.legend()
    
    plt.tight_layout()
    plt.savefig('copilot-usage-report.png', dpi=300)
    print(f"\n📊 그래프 저장: copilot-usage-report.png")
    
    # CSV 저장
    df_usage.to_csv('copilot-usage-data.csv', index=False)
    print(f"📁 데이터 저장: copilot-usage-data.csv")
    
    # 활성도가 낮은 사용자 알림
    print("\n⚠️  활성도가 낮은 사용자 (30일간 미사용):")
    inactive_users = [s for s in seats_data['seats'] if not s['last_activity_at']]
    if inactive_users:
        for user in inactive_users[:10]:  # 상위 10명만 표시
            print(f"  - {user['assignee']['login']}")
        if len(inactive_users) > 10:
            print(f"  ... 외 {len(inactive_users)-10}명")
    else:
        print("  없음")
    
    print("\n" + "="*60)

if __name__ == "__main__":
    try:
        generate_usage_report()
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        exit(1)
```

</details>

---

<details>
<summary>🔽 펼치기: GitHub Advanced Security (GHAS) 통합</summary>

### 🛡️ GitHub Advanced Security 완전 활용

#### 1. 조직 수준 보안 정책

```yaml
# .github/security-policy.yml
# 조직 전체 보안 설정

security:
  # Secret Scanning
  secret_scanning:
    enabled: true
    push_protection: true  # 푸시 전 시크릿 차단
    
    # 알림 설정
    notifications:
      on_commit: true
      on_push: true
      recipients:
        - security-team
        - repository-admins
    
    # 커스텀 패턴
    custom_patterns:
      - name: "Internal API Token"
        pattern: "INTERNAL_[A-Z0-9]{32}"
      - name: "Database URL"
        pattern: "(postgresql|mysql)://[^\\s]+"
  
  # Dependency Scanning (Dependabot)
  dependency_scanning:
    enabled: true
    
    # 자동 보안 업데이트
    security_updates:
      enabled: true
      auto_merge: true  # 패치/마이너만
      
    # 알림
    alerts:
      severity_threshold: "medium"  # medium 이상만 알림
      notify:
        - security-team
        - tech-leads
  
  # Code Scanning (CodeQL)
  code_scanning:
    enabled: true
    
    # 기본 워크플로우
    default_setup: true
    
    # 스캔 트리거
    triggers:
      - push
      - pull_request
      - schedule  # 매주 일요일 02:00
    
    # 결과 처리
    results:
      fail_on: ["error", "high"]
      dismiss_alerts: false
      
    # 언어별 설정
    languages:
      - javascript
      - python
      - java
      - go
  
  # Pull Request 보안 체크
  pull_request_checks:
    # 보안 취약점 발견 시 머지 차단
    block_on_vulnerability: true
    
    # 필수 리뷰어 (보안 관련 파일)
    required_reviewers:
      paths:
        - "**/*.key"
        - "**/*.pem"
        - "**/secrets/**"
      teams:
        - security-team
  
  # 컴플라이언스
  compliance:
    # SOC2 감사 로그
    audit_log:
      retention_days: 365
      export_to_s3: true
    
    # GDPR
    data_residency: "eu"  # EU 데이터 센터만 사용
    
    # 보안 인증
    certifications:
      - SOC2
      - ISO27001
```

#### 2. 저장소별 보안 워크플로우

```yaml
# .github/workflows/security-full-scan.yml
name: 🛡️ Full Security Scan

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  schedule:
    # 매주 일요일 02:00 (KST)
    - cron: '0 17 * * 0'  # UTC 기준
  workflow_dispatch:

permissions:
  contents: read
  security-events: write
  actions: read
  issues: write

jobs:
  # ========================================
  # 1. Secret Scanning
  # ========================================
  secret-scan:
    name: 🔐 Secret Scanning
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: TruffleHog Secret Scan
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
          extra_args: --only-verified --json
      
      - name: GitLeaks Scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Upload results
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: results.sarif
          category: secret-scanning
  
  # ========================================
  # 2. Dependency Scanning
  # ========================================
  dependency-scan:
    name: 📦 Dependency Scanning
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: high
          allow-licenses: MIT, Apache-2.0, BSD-3-Clause
          deny-licenses: GPL-3.0, AGPL-3.0
      
      - name: OWASP Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'my-project'
          path: '.'
          format: 'SARIF'
      
      - name: Upload OWASP results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: reports/dependency-check-report.sarif
  
  # ========================================
  # 3. Code Scanning (SAST)
  # ========================================
  codeql:
    name: 🔍 CodeQL Analysis
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        language: [javascript, python]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          queries: security-extended,security-and-quality
          config-file: .github/codeql/config.yml
      
      - name: Autobuild
        uses: github/codeql-action/autobuild@v3
      
      - name: Perform Analysis
        uses: github/codeql-action/analyze@v3
        with:
          category: "/language:${{ matrix.language }}"
  
  # ========================================
  # 4. Container Scanning
  # ========================================
  container-scan:
    name: 🐳 Container Security
    runs-on: ubuntu-latest
    if: hashFiles('Dockerfile') != ''
    steps:
      - uses: actions/checkout@v4
      
      - name: Build image
        run: docker build -t test-image:${{ github.sha }} .
      
      - name: Trivy Scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: test-image:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
      
      - name: Upload Trivy results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: trivy-results.sarif
          category: container-scanning
      
      - name: Grype Scan
        uses: anchore/scan-action@v3
        with:
          image: test-image:${{ github.sha }}
          fail-build: true
          severity-cutoff: high
  
  # ========================================
  # 5. Infrastructure Scanning (IaC)
  # ========================================
  iac-scan:
    name: 🏗️ Infrastructure Scanning
    runs-on: ubuntu-latest
    if: hashFiles('**/*.tf', '**/*.yml', '**/*.yaml') != ''
    steps:
      - uses: actions/checkout@v4
      
      - name: Checkov Scan
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform,kubernetes,dockerfile
          output_format: sarif
          output_file_path: checkov-results.sarif
      
      - name: Upload Checkov results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: checkov-results.sarif
          category: iac-scanning
      
      - name: TFSec Scan (Terraform)
        if: hashFiles('**/*.tf') != ''
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          sarif_file: tfsec-results.sarif
      
      - name: Upload TFSec results
        if: hashFiles('**/*.tf') != ''
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: tfsec-results.sarif
  
  # ========================================
  # 6. License Compliance
  # ========================================
  license-check:
    name: ⚖️ License Compliance
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: FOSSA Scan
        uses: fossas/fossa-action@main
        with:
          api-key: ${{ secrets.FOSSA_API_KEY }}
      
      - name: License Finder
        run: |
          gem install license_finder
          license_finder report --decisions-file=.license_finder.yml
  
  # ========================================
  # 7. Security Report 생성
  # ========================================
  security-report:
    name: 📊 Security Report
    needs: [secret-scan, dependency-scan, codeql, container-scan, iac-scan]
    if: always()
    runs-on: ubuntu-latest
    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@v4
      
      - name: Generate Report
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = {
              timestamp: new Date().toISOString(),
              repository: context.repo.repo,
              commit: context.sha,
              scan_results: {
                secret_scanning: '${{ needs.secret-scan.result }}',
                dependency_scanning: '${{ needs.dependency-scan.result }}',
                code_scanning: '${{ needs.codeql.result }}',
                container_scanning: '${{ needs.container-scan.result }}',
                iac_scanning: '${{ needs.iac-scan.result }}'
              }
            };
            
            // GitHub Issue 생성 (실패 시)
            const failed = Object.values(report.scan_results).some(r => r === 'failure');
            if (failed) {
              await github.rest.issues.create({
                owner: context.repo.owner,
                repo: context.repo.repo,
                title: `🚨 Security Scan Failed - ${context.sha.substr(0,7)}`,
                body: `보안 스캔에서 문제가 발견되었습니다.\n\n\`\`\`json\n${JSON.stringify(report, null, 2)}\n\`\`\``,
                labels: ['security', 'urgent']
              });
            }
      
      - name: Comment PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '✅ 보안 스캔 완료! 상세 결과는 Security 탭에서 확인하세요.'
            });
```

#### 3. 보안 알림 자동화

```yaml
# .github/workflows/security-alerts.yml
name: 🚨 Security Alert Handler

on:
  repository_vulnerability_alert:
    types: [create]

jobs:
  alert-handler:
    name: Handle Security Alert
    runs-on: ubuntu-latest
    steps:
      - name: Get alert details
        id: alert
        uses: actions/github-script@v7
        with:
          script: |
            const alert = context.payload.alert;
            return {
              package: alert.security_advisory.package.name,
              severity: alert.security_advisory.severity,
              cve: alert.security_advisory.cve_id,
              summary: alert.security_advisory.summary
            };
      
      - name: Create urgent issue
        if: steps.alert.outputs.severity == 'critical' || steps.alert.outputs.severity == 'high'
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `🚨 [${steps.alert.outputs.severity.toUpperCase()}] Security Alert: ${steps.alert.outputs.package}`,
              body: `
              ## 🔴 긴급 보안 취약점 발견
              
              **패키지**: ${steps.alert.outputs.package}
              **심각도**: ${steps.alert.outputs.severity}
              **CVE**: ${steps.alert.outputs.cve}
              
              ### 요약
              ${steps.alert.outputs.summary}
              
              ### 조치 사항
              - [ ] 취약점 분석
              - [ ] 패키지 업데이트 PR 생성
              - [ ] 보안 테스트 수행
              - [ ] 프로덕션 배포
              
              **담당자**: @security-team
              **기한**: 24시간 이내
              `,
              labels: ['security', 'critical', 'urgent'],
              assignees: ['security-lead']
            });
      
      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: custom
          custom_payload: |
            {
              text: `🚨 보안 취약점 발견`,
              attachments: [{
                color: 'danger',
                fields: [
                  { title: 'Package', value: '${{ steps.alert.outputs.package }}', short: true },
                  { title: 'Severity', value: '${{ steps.alert.outputs.severity }}', short: true },
                  { title: 'CVE', value: '${{ steps.alert.outputs.cve }}', short: true },
                  { title: 'Repository', value: '${{ github.repository }}', short: true }
                ]
              }]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_SECURITY }}
```

</details>

---

## 📊 Part 5: 조직 거버넌스 및 규정 준수

<details>
<summary>🔽 펼치기: 감사 로그 및 컴플라이언스</summary>

### 📝 감사 로그 수집 및 분석

#### 1. 감사 로그 자동 수집

```python
#!/usr/bin/env python3
# scripts/collect-audit-logs.py

import os
import requests
import json
from datetime import datetime, timedelta
import boto3

# 설정
GITHUB_TOKEN = os.getenv("GITHUB_PAT_ADMIN")
ENTERPRISE = "my-enterprise"
S3_BUCKET = "github-audit-logs"
S3_PREFIX = "logs/"

headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}

def get_audit_log_events(start_date, end_date):
    """엔터프라이즈 감사 로그 가져오기"""
    url = f"https://api.github.com/enterprises/{ENTERPRISE}/audit-log"
    
    all_events = []
    page = 1
    
    while True:
        params = {
            "phrase": f"created:{start_date.isoformat()}..{end_date.isoformat()}",
            "per_page": 100,
            "page": page
        }
        
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        
        events = response.json()
        if not events:
            break
        
        all_events.extend(events)
        page += 1
        
        print(f"페이지 {page-1} 수집 완료: {len(events)}개 이벤트")
    
    return all_events

def analyze_security_events(events):
    """보안 관련 이벤트 분석"""
    security_events = {
        "failed_logins": [],
        "permission_changes": [],
        "secret_access": [],
        "repo_deletions": [],
        "unusual_activity": []
    }
    
    for event in events:
        action = event.get("action")
        actor = event.get("actor")
        
        # 로그인 실패
        if action == "org.login_failed":
            security_events["failed_logins"].append(event)
        
        # 권한 변경
        elif action in ["org.add_member", "org.remove_member", "org.update_member"]:
            security_events["permission_changes"].append(event)
        
        # 비밀 접근
        elif "secret" in action:
            security_events["secret_access"].append(event)
        
        # 저장소 삭제
        elif action == "repo.destroy":
            security_events["repo_deletions"].append(event)
        
        # 비정상 활동 (예: 심야 시간대 민감한 작업)
        timestamp = datetime.fromisoformat(event.get("@timestamp").replace("Z", "+00:00"))
        if timestamp.hour >= 22 or timestamp.hour <= 6:  # 22:00 ~ 06:00
            if action in ["repo.destroy", "org.remove_member", "org.remove_outside_collaborator"]:
                security_events["unusual_activity"].append(event)
    
    return security_events

def upload_to_s3(data, filename):
    """S3에 업로드"""
    s3 = boto3.client('s3')
    key = f"{S3_PREFIX}{filename}"
    
    s3.put_object(
        Bucket=S3_BUCKET,
        Key=key,
        Body=json.dumps(data, indent=2),
        ContentType='application/json',
```python
        ServerSideEncryption='AES256',
        Metadata={
            'collected_at': datetime.utcnow().isoformat(),
            'event_count': str(len(data))
        }
    )
    
    print(f"✅ S3에 업로드 완료: s3://{S3_BUCKET}/{key}")

def generate_compliance_report(events, security_events):
    """컴플라이언스 리포트 생성"""
    report = {
        "report_date": datetime.utcnow().isoformat(),
        "period": {
            "start": events[0].get("@timestamp") if events else None,
            "end": events[-1].get("@timestamp") if events else None
        },
        "summary": {
            "total_events": len(events),
            "unique_actors": len(set(e.get("actor") for e in events if e.get("actor"))),
            "security_incidents": sum(len(v) for v in security_events.values())
        },
        "security_breakdown": {
            "failed_logins": len(security_events["failed_logins"]),
            "permission_changes": len(security_events["permission_changes"]),
            "secret_access": len(security_events["secret_access"]),
            "repo_deletions": len(security_events["repo_deletions"]),
            "unusual_activity": len(security_events["unusual_activity"])
        },
        "top_actions": {},
        "top_actors": {}
    }
    
    # 상위 액션 분석
    action_counts = {}
    for event in events:
        action = event.get("action", "unknown")
        action_counts[action] = action_counts.get(action, 0) + 1
    
    report["top_actions"] = dict(sorted(action_counts.items(), key=lambda x: x[1], reverse=True)[:10])
    
    # 상위 사용자 분석
    actor_counts = {}
    for event in events:
        actor = event.get("actor", "unknown")
        actor_counts[actor] = actor_counts.get(actor, 0) + 1
    
    report["top_actors"] = dict(sorted(actor_counts.items(), key=lambda x: x[1], reverse=True)[:10])
    
    return report

def send_alert_if_needed(security_events):
    """심각한 보안 이벤트 발생 시 알림"""
    alerts = []
    
    # 5회 이상 로그인 실패
    if len(security_events["failed_logins"]) >= 5:
        alerts.append({
            "severity": "high",
            "type": "failed_logins",
            "message": f"{len(security_events['failed_logins'])}회의 로그인 실패 감지",
            "details": security_events["failed_logins"][:5]
        })
    
    # 저장소 삭제
    if security_events["repo_deletions"]:
        alerts.append({
            "severity": "critical",
            "type": "repo_deletion",
            "message": f"{len(security_events['repo_deletions'])}개 저장소 삭제됨",
            "details": security_events["repo_deletions"]
        })
    
    # 비정상 시간대 활동
    if security_events["unusual_activity"]:
        alerts.append({
            "severity": "medium",
            "type": "unusual_activity",
            "message": f"심야 시간대 {len(security_events['unusual_activity'])}건의 민감한 작업 감지",
            "details": security_events["unusual_activity"]
        })
    
    if alerts:
        # Slack 알림
        webhook_url = os.getenv("SLACK_WEBHOOK_SECURITY")
        for alert in alerts:
            payload = {
                "text": f"🚨 보안 알림: {alert['message']}",
                "attachments": [{
                    "color": "danger" if alert["severity"] == "critical" else "warning",
                    "fields": [
                        {"title": "심각도", "value": alert["severity"], "short": True},
                        {"title": "유형", "value": alert["type"], "short": True},
                        {"title": "세부 정보", "value": json.dumps(alert["details"][:3], indent=2), "short": False}
                    ]
                }]
            }
            requests.post(webhook_url, json=payload)
        
        print(f"⚠️  {len(alerts)}개의 보안 알림 발송됨")

def main():
    print("=== GitHub 감사 로그 수집 시작 ===\n")
    
    # 어제 로그 수집
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=1)
    
    print(f"수집 기간: {start_date.date()} ~ {end_date.date()}")
    
    # 로그 수집
    print("\n1️⃣ 감사 로그 수집 중...")
    events = get_audit_log_events(start_date, end_date)
    print(f"✅ 총 {len(events)}개 이벤트 수집 완료")
    
    # 보안 이벤트 분석
    print("\n2️⃣ 보안 이벤트 분석 중...")
    security_events = analyze_security_events(events)
    print(f"✅ 보안 이벤트 분석 완료")
    
    # 컴플라이언스 리포트 생성
    print("\n3️⃣ 컴플라이언스 리포트 생성 중...")
    report = generate_compliance_report(events, security_events)
    print(f"✅ 리포트 생성 완료")
    
    # S3 업로드
    print("\n4️⃣ S3에 업로드 중...")
    date_str = start_date.strftime("%Y-%m-%d")
    upload_to_s3(events, f"raw/{date_str}_audit_log.json")
    upload_to_s3(report, f"reports/{date_str}_compliance_report.json")
    
    # 보안 알림
    print("\n5️⃣ 보안 알림 확인 중...")
    send_alert_if_needed(security_events)
    
    # 요약 출력
    print("\n" + "="*60)
    print("📊 요약")
    print("="*60)
    print(f"총 이벤트: {report['summary']['total_events']}")
    print(f"고유 사용자: {report['summary']['unique_actors']}")
    print(f"보안 인시던트: {report['summary']['security_incidents']}")
    print("\n보안 이벤트 상세:")
    for key, value in report['security_breakdown'].items():
        print(f"  - {key}: {value}")
    print("="*60)
    
    print("\n✅ 감사 로그 수집 완료")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        exit(1)
```

#### 2. Cron 작업 설정

```bash
# /etc/cron.d/github-audit-logs
# 매일 오전 2시에 전날 감사 로그 수집

0 2 * * * ubuntu /usr/bin/python3 /opt/scripts/collect-audit-logs.py >> /var/log/github-audit.log 2>&1
```

#### 3. 컴플라이언스 대시보드 (Grafana)

```yaml
# grafana-dashboard-audit.json
{
  "dashboard": {
    "title": "GitHub Audit & Compliance Dashboard",
    "panels": [
      {
        "title": "일별 이벤트 추이",
        "type": "graph",
        "datasource": "Athena",
        "targets": [
          {
            "rawSql": "SELECT date_trunc('day', timestamp) as time, count(*) as events FROM audit_logs GROUP BY 1 ORDER BY 1"
          }
        ]
      },
      {
        "title": "보안 인시던트",
        "type": "stat",
        "datasource": "Athena",
        "targets": [
          {
            "rawSql": "SELECT count(*) FROM audit_logs WHERE action IN ('repo.destroy', 'org.remove_member') AND timestamp > now() - interval '7' day"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {"value": 0, "color": "green"},
                {"value": 5, "color": "yellow"},
                {"value": 10, "color": "red"}
              ]
            }
          }
        }
      },
      {
        "title": "상위 액션",
        "type": "table",
        "datasource": "Athena",
        "targets": [
          {
            "rawSql": "SELECT action, count(*) as count FROM audit_logs WHERE timestamp > now() - interval '30' day GROUP BY 1 ORDER BY 2 DESC LIMIT 10"
          }
        ]
      },
      {
        "title": "로그인 실패 (지역별)",
        "type": "worldmap",
        "datasource": "Athena",
        "targets": [
          {
            "rawSql": "SELECT country, count(*) as metric FROM audit_logs WHERE action = 'org.login_failed' GROUP BY 1"
          }
        ]
      }
    ]
  }
}
```

</details>

---

<details>
<summary>🔽 펼치기: 규정 준수 자동화 (SOC2, ISO27001)</summary>

### 🏛️ SOC2/ISO27001 준수 체크리스트

#### 1. 자동 컴플라이언스 체크

```python
#!/usr/bin/env python3
# scripts/compliance-checker.py

import os
import requests
from typing import Dict, List

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
ORG_NAME = "my-organization"

headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}

class ComplianceChecker:
    def __init__(self):
        self.violations = []
        self.warnings = []
        self.passed = []
    
    def check_org_settings(self):
        """조직 설정 검증"""
        print("🔍 조직 설정 검증 중...")
        
        url = f"https://api.github.com/orgs/{ORG_NAME}"
        response = requests.get(url, headers=headers)
        org = response.json()
        
        # 2FA 강제
        if not org.get("two_factor_requirement_enabled"):
            self.violations.append({
                "category": "Authentication",
                "rule": "SOC2-AC-01",
                "message": "2FA가 강제되지 않음",
                "severity": "CRITICAL",
                "remediation": "Organization Settings > Authentication > Require two-factor authentication"
            })
        else:
            self.passed.append("2FA 강제 활성화됨")
        
        # 멤버 기본 권한
        default_permission = org.get("default_repository_permission")
        if default_permission in ["admin", "write"]:
            self.violations.append({
                "category": "Access Control",
                "rule": "SOC2-AC-02",
                "message": f"기본 권한이 너무 높음: {default_permission}",
                "severity": "HIGH",
                "remediation": "Organization Settings > Member privileges > Base permissions: read"
            })
        else:
            self.passed.append("기본 권한 적절함")
        
        # 외부 협력자 제한
        if org.get("members_can_create_public_repositories"):
            self.warnings.append({
                "category": "Data Protection",
                "rule": "ISO27001-A.9.4.1",
                "message": "멤버가 공개 저장소 생성 가능",
                "severity": "MEDIUM",
                "remediation": "민감 정보 유출 위험 - 정책 검토 필요"
            })
    
    def check_repositories(self):
        """저장소별 보안 설정 검증"""
        print("🔍 저장소 보안 설정 검증 중...")
        
        url = f"https://api.github.com/orgs/{ORG_NAME}/repos"
        params = {"type": "all", "per_page": 100}
        
        repos = []
        page = 1
        while True:
            response = requests.get(url, headers=headers, params={**params, "page": page})
            batch = response.json()
            if not batch:
                break
            repos.extend(batch)
            page += 1
        
        for repo in repos:
            repo_name = repo["full_name"]
            
            # Private 저장소 체크
            if not repo["private"]:
                # 공개 저장소는 민감 정보 없어야 함
                self.warnings.append({
                    "category": "Data Classification",
                    "rule": "SOC2-CC-06",
                    "message": f"공개 저장소: {repo_name}",
                    "severity": "LOW",
                    "remediation": "민감 정보 포함 여부 확인"
                })
            
            # Branch Protection
            default_branch = repo.get("default_branch", "main")
            protection_url = f"https://api.github.com/repos/{repo_name}/branches/{default_branch}/protection"
            protection_response = requests.get(protection_url, headers=headers)
            
            if protection_response.status_code == 404:
                self.violations.append({
                    "category": "Change Management",
                    "rule": "SOC2-CC-08",
                    "message": f"Branch Protection 미설정: {repo_name}",
                    "severity": "HIGH",
                    "remediation": f"Repository Settings > Branches > Add rule for {default_branch}"
                })
            else:
                protection = protection_response.json()
                
                # 리뷰 필수 체크
                if not protection.get("required_pull_request_reviews"):
                    self.violations.append({
                        "category": "Change Management",
                        "rule": "SOC2-CC-08",
                        "message": f"PR 리뷰 필수 아님: {repo_name}",
                        "severity": "MEDIUM",
                        "remediation": "Branch Protection Rules > Require pull request reviews"
                    })
                
                # Status Check 필수
                if not protection.get("required_status_checks"):
                    self.warnings.append({
                        "category": "Quality Assurance",
                        "rule": "ISO27001-A.14.2.8",
                        "message": f"Status Check 미설정: {repo_name}",
                        "severity": "MEDIUM",
                        "remediation": "CI/CD 파이프라인 필수 체크 설정"
                    })
            
            # Dependabot Alerts
            alerts_url = f"https://api.github.com/repos/{repo_name}/vulnerability-alerts"
            alerts_response = requests.get(alerts_url, headers=headers)
            
            if alerts_response.status_code == 404:
                self.violations.append({
                    "category": "Vulnerability Management",
                    "rule": "SOC2-CC-07",
                    "message": f"Dependabot Alerts 비활성화: {repo_name}",
                    "severity": "HIGH",
                    "remediation": "Repository Settings > Security > Enable Dependabot alerts"
                })
    
    def check_security_features(self):
        """고급 보안 기능 검증"""
        print("🔍 고급 보안 기능 검증 중...")
        
        # Secret Scanning
        url = f"https://api.github.com/orgs/{ORG_NAME}"
        response = requests.get(url, headers=headers)
        org = response.json()
        
        # Advanced Security 라이선스 확인
        # (실제 API는 엔터프라이즈 수준에서만 접근 가능)
        
        self.passed.append("고급 보안 기능 확인 완료")
    
    def check_access_logs(self):
        """접근 로그 검증"""
        print("🔍 접근 로그 및 감사 추적 검증 중...")
        
        # 최근 감사 로그 확인
        url = f"https://api.github.com/orgs/{ORG_NAME}/audit-log"
        params = {"per_page": 1}
        
        response = requests.get(url, headers=headers, params=params)
        
        if response.status_code == 200 and response.json():
            self.passed.append("감사 로그 수집 활성화")
        else:
            self.violations.append({
                "category": "Logging and Monitoring",
                "rule": "SOC2-CC-07",
                "message": "감사 로그 접근 불가 또는 비활성화",
                "severity": "CRITICAL",
                "remediation": "엔터프라이즈 계정에서 감사 로그 활성화"
            })
    
    def generate_report(self) -> Dict:
        """컴플라이언스 리포트 생성"""
        total_checks = len(self.violations) + len(self.warnings) + len(self.passed)
        compliance_score = (len(self.passed) / total_checks * 100) if total_checks > 0 else 0
        
        report = {
            "timestamp": datetime.utcnow().isoformat(),
            "organization": ORG_NAME,
            "compliance_score": round(compliance_score, 2),
            "summary": {
                "total_checks": total_checks,
                "passed": len(self.passed),
                "warnings": len(self.warnings),
                "violations": len(self.violations)
            },
            "violations": self.violations,
            "warnings": self.warnings,
            "passed": self.passed,
            "certification_status": {
                "SOC2": "COMPLIANT" if len(self.violations) == 0 else "NON_COMPLIANT",
                "ISO27001": "COMPLIANT" if len(self.violations) == 0 else "NON_COMPLIANT"
            }
        }
        
        return report
    
    def run_all_checks(self):
        """모든 검증 실행"""
        print("\n" + "="*60)
        print("🏛️  GitHub 컴플라이언스 검증 시작")
        print("="*60 + "\n")
        
        self.check_org_settings()
        self.check_repositories()
        self.check_security_features()
        self.check_access_logs()
        
        report = self.generate_report()
        
        # 결과 출력
        print("\n" + "="*60)
        print("📊 검증 결과")
        print("="*60)
        print(f"컴플라이언스 점수: {report['compliance_score']:.2f}%")
        print(f"✅ 통과: {report['summary']['passed']}")
        print(f"⚠️  경고: {report['summary']['warnings']}")
        print(f"❌ 위반: {report['summary']['violations']}")
        
        if self.violations:
            print("\n🚨 심각한 위반 사항:")
            for v in self.violations[:5]:
                print(f"\n  [{v['severity']}] {v['message']}")
                print(f"  규칙: {v['rule']}")
                print(f"  조치: {v['remediation']}")
        
        if self.warnings:
            print("\n⚠️  경고 사항:")
            for w in self.warnings[:5]:
                print(f"\n  [{w['severity']}] {w['message']}")
        
        print("\n" + "="*60)
        
        # JSON 리포트 저장
        with open(f"compliance-report-{datetime.utcnow().strftime('%Y%m%d')}.json", "w") as f:
            json.dump(report, f, indent=2)
        
        return report

if __name__ == "__main__":
    from datetime import datetime
    import json
    
    checker = ComplianceChecker()
    report = checker.run_all_checks()
    
    # 위반 사항이 있으면 exit code 1
    if report['summary']['violations'] > 0:
        exit(1)
```

#### 2. 주간 컴플라이언스 리포트 자동화

```yaml
# .github/workflows/weekly-compliance-report.yml
name: 📋 Weekly Compliance Report

on:
  schedule:
    # 매주 월요일 오전 9시 (KST)
    - cron: '0 0 * * 1'  # UTC 기준
  workflow_dispatch:

jobs:
  compliance-check:
    name: Run Compliance Checks
    runs-on: ubuntu-latest
    permissions:
      contents: read
      issues: write
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install requests boto3
      
      - name: Run compliance checker
        id: compliance
        env:
          GITHUB_TOKEN: ${{ secrets.ORG_ADMIN_TOKEN }}
        run: |
          python scripts/compliance-checker.py
          echo "report_file=compliance-report-$(date +%Y%m%d).json" >> $GITHUB_OUTPUT
      
      - name: Upload to S3
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          aws s3 cp ${{ steps.compliance.outputs.report_file }} \
            s3://compliance-reports/github/
      
      - name: Create Issue if violations found
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = JSON.parse(fs.readFileSync('${{ steps.compliance.outputs.report_file }}'));
            
            let body = `## 🚨 컴플라이언스 위반 발견\n\n`;
            body += `**점수**: ${report.compliance_score}%\n`;
            body += `**위반 사항**: ${report.summary.violations}개\n\n`;
            
            body += `### 주요 위반 사항\n\n`;
            for (const violation of report.violations.slice(0, 10)) {
              body += `#### [${violation.severity}] ${violation.message}\n`;
              body += `- **규칙**: ${violation.rule}\n`;
              body += `- **조치 방법**: ${violation.remediation}\n\n`;
            }
            
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `🏛️ Weekly Compliance Report - ${new Date().toISOString().split('T')[0]}`,
              body: body,
              labels: ['compliance', 'urgent'],
              assignees: ['compliance-officer']
            });
      
      - name: Send Slack notification
        uses: 8398a7/action-slack@v3
        with:
          status: custom
          custom_payload: |
            {
              text: `📋 주간 컴플라이언스 리포트`,
              attachments: [{
                color: '${{ job.status }}' === 'success' ? 'good' : 'danger',
                fields: [
                  { title: '조직', value: 'my-organization', short: true },
                  { title: '상태', value: '${{ job.status }}', short: true },
                  { title: '리포트', value: 'S3에 업로드됨', short: false }
                ]
              }]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_COMPLIANCE }}
```

</details>

---

## 🎯 최종 체크리스트 및 요약

### ✅ GitHub 가이드라인 핵심 체크리스트

```markdown
## 🏗️ 배포 단계
- [ ] 배포 모델 선택 (GitHub.com/GHEC/GHES)
- [ ] 하드웨어/클라우드 리소스 프로비저닝
- [ ] 초기 설정 (인증/네트워크/백업)
- [ ] SSL/TLS 인증서 설정
- [ ] 고가용성 구성 (프로덕션 환경)

## 🔧 조직 관리
- [ ] 엔터프라이즈/조직 구조 설계
- [ ] 팀 및 권한 체계 수립
- [ ] SAML SSO/SCIM 연동
- [ ] 2FA 강제 활성화
- [ ] 라이선스 할당 및 관리

## 🛡️ 보안 정책
- [ ] Branch Protection Rules 설정
- [ ] CODEOWNERS 파일 작성
- [ ] Secret Scanning 활성화
- [ ] Dependabot 설정
- [ ] CodeQL/SAST 활성화
- [ ] IP 허용 목록 구성

## 🚀 CI/CD (GitHub Actions)
- [ ] 재사용 가능한 워크플로우 라이브러리 구축
- [ ] Secrets 관리 전략 수립
- [ ] Self-hosted Runners 설정 (필요시)
- [ ] Actions 사용량 모니터링
- [ ] 워크플로우 템플릿 표준화

## 🤖 AI 기능 (Copilot)
- [ ] Copilot 조직 정책 설정
- [ ] 콘텐츠 제외 규칙 정의
- [ ] 개발자 교육 및 가이드라인
- [ ] 사용량 모니터링 대시보드
- [ ] 보안 가이드라인 배포

## 📊 모니터링 & 감사
- [ ] 감사 로그 자동 수집
- [ ] 보안 알림 자동화
- [ ] 컴플라이언스 대시보드 구축
- [ ] 주간/월간 리포트 자동화
- [ ] 인시던트 대응 프로세스

## 👥 사용자 교육
- [ ] Git/GitHub 기본 교육
- [ ] PR 프로세스 가이드
- [ ] 보안 베스트 프랙티스
- [ ] Copilot 안전 사용법
- [ ] 문제 해결 FAQ
```

---

### 🧠 적용한 사고 공식 설명

이 GitHub 가이드라인을 작성하면서 다음 공식들을 종합적으로 활용했습니다:

#### 1. **복잡도 해결 매트릭스 (CS)**
```
GitHub 시스템을 다음과 같이 분해:
- 배포 레이어 (GitHub.com/GHEC/GHES)
- 관리 레이어 (조직/팀/권한)
- 사용 레이어 (Git/Actions/Copilot/Security)
- 통합 레이어 (API/Webhooks/third-party)
```

#### 2. **다차원 분석 (MDA)**
```
시간축: 초기 구축 → 안정화 → 확장 → 최적화
공간축: 개인 → 팀 → 조직 → 엔터프라이즈
추상화: 인프라 → 플랫폼 → 애플리케이션 → 사용자
인과관계: 요구사항 → 설계 → 구현 → 검증 → 개선
```

#### 3. **문제 재정의 알고리즘 (PR)**
```
원래 문제: "GitHub 가이드를 어떻게 만드나?"
↓
재정의: "GitLab과 차별화되는 GitHub 특화 기능(Actions/Copilot/GHAS)을
        어떻게 조직 수준에서 표준화하고 거버넌스할 것인가?"
```

#### 4. **창의적 연결 매트릭스 (CC)**
```
GitLab 가이드의 구조를 참고하되:
+ GitHub만의 특징 (Copilot AI, Marketplace, Social Coding)
+ 클라우드 우선 접근 (GHEC 중심)
+ 컴플라이언스 자동화 (SOC2/ISO27001)
→ GitHub 고유의 가이드라인 체계
```

#### 5. **통합 지혜 공식 (IW)**
```
지식(K): GitHub 공식 문서 + 실무 경험
이해(U): GitLab과의 차이점 명확화
지혜(W): 조직 규모별 최적 전략
동정심(C): 초보자도 이해 가능한 설명
실행(A): 즉시 적용 가능한 스크립트
겸손(H): "상황에 따라 다를 수 있음" 명시
윤리(E): 보안/컴플라이언스 우선
```

---

### 🚀 다음 단계 제안

이제 다음 중 하나를 선택하여 더 상세한 가이드를 작성할 수 있습니다:

1. **특정 시나리오 심화**
   - "대규모 모노레포 관리 전략"
   - "GitHub Actions 비용 최적화 가이드"
   - "멀티 클라우드 GitHub Enterprise 구성"

2. **역할별 가이드**
   - "신입 개발자를 위한 GitHub 첫걸음"
   - "DevOps 엔지니어를 위한 Actions 마스터"
   - "보안 담당자를 위한 GHAS 완벽 가이드"

3. **마이그레이션 가이드**
   - "GitLab → GitHub 무중단 마이그레이션"
   - "SVN/Bitbucket → GitHub 전환 전략"
   - "온프레미스 → GitHub Enterprise Cloud 이전"

4. **실전 시나리오**
   - "스타트업을 위한 GitHub 빠른 시작 (30분 완성)"
   - "금융권을 위한 GitHub 컴플라이언스 설정"
   - "오픈소스 프로젝트 운영 베스트 프랙티스"

어떤 주제를 더 깊이 다루기를 원하시나요? 또는 GitLab과 GitHub를 **비교 분석한 통합 가이드**를 만들 수도 있습니다!

---

## 📚 보너스: GitLab vs GitHub 통합 의사결정 가이드

<details>
<summary>🔽 펼치기: GitLab vs GitHub - 어떤 것을 선택할까?</summary>

### 🎯 의사결정 트리

```
시작: DevOps 플랫폼 선택
│
├─ Q1: 온프레미스가 필수인가?
│  ├─ YES → GitLab 우선 고려
│  │  └─ 이유: GitLab Self-Managed가 더 성숙
│  └─ NO → 다음 질문으로
│
├─ Q2: 주요 우선순위는?
│  ├─ 통합 DevOps 플랫폼 → GitLab
│  │  └─ 단일 도구에서 모든 것 (CI/CD/보안/모니터링)
│  ├─ 오픈소스 커뮤니티 → GitHub
│  │  └─ 세계 최대 개발자 커뮤니티
│  └─ AI 코딩 도구 → GitHub
│     └─ Copilot이 압도적 우위
│
├─ Q3: 팀 규모 및 구조는?
│  ├─ 소규모 (< 50명) → GitHub
│  │  └─ 간단한 시작, 낮은 진입장벽
│  ├─ 중규모 (50-500명) → 둘 다 가능
│  │  └─ 요구사항에 따라 선택
│  └─ 대규모 (500명+) → GitLab
│     └─ 복잡한 조직 구조 관리 용이
│
├─ Q4: 기존 도구 통합은?
│  ├─ Jenkins/CircleCI 사용 중 → GitHub
│  │  └─ Actions로 쉽게 전환
│  ├─ 자체 CI/CD 있음 → GitHub
│  │  └─ Git 저장소로만 사용
│  └─ 처음부터 구축 → GitLab
│     └─ 내장 CI/CD가 강력
│
└─ Q5: 예산은?
   ├─ 제한적 → GitHub
   │  └─ 공개 저장소 무료, 저렴한 시작
   ├─ 충분함 → GitLab Ultimate
   │  └─ 고급 기능 포함
   └─ 엔터프라이즈 → 둘 다 검토
      └─ POC로 비교
```

### 📊 기능별 상세 비교

#### 1. 코어 기능

| 기능 | GitLab | GitHub | 승자 |
|------|--------|--------|------|
| Git 저장소 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 🤝 동등 |
| 코드 리뷰 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub |
| Issue 추적 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | GitLab |
| Wiki/문서 | ⭐⭐⭐⭐ | ⭐⭐⭐ | GitLab |
| 검색 기능 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub |

#### 2. CI/CD

| 기능 | GitLab | GitHub | 승자 |
|------|--------|--------|------|
| 통합 CI/CD | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | GitLab |
| 설정 복잡도 | ⭐⭐⭐ (중간) | ⭐⭐⭐⭐ (쉬움) | GitHub |
| 성능 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub |
| 비용 | ⭐⭐⭐ | ⭐⭐⭐⭐ | GitHub |
| 러너 관리 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | GitLab |
| 마켓플레이스 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub |

#### 3. 보안

| 기능 | GitLab | GitHub | 승자 |
|------|--------|--------|------|
| SAST | ⭐⭐⭐⭐⭐ (내장) | ⭐⭐⭐⭐⭐ (CodeQL) | 🤝 동등 |
| DAST | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ (서드파티) | GitLab |
| 컨테이너 스캔 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | GitLab |
| Secret Scanning | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub |
| Dependency Scanning | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 🤝 동등 |
| 보안 대시보드 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | GitLab |

#### 4. AI 기능

| 기능 | GitLab | GitHub | 승자 |
|------|--------|--------|------|
| 코드 제안 | ⭐⭐⭐ (Duo) | ⭐⭐⭐⭐⭐ (Copilot) | GitHub |
| Chat | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub |
| PR 요약 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub |
| 성숙도 | ⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub |

#### 5. 협업 & 커뮤니티

| 기능 | GitLab | GitHub | 승자 |
|------|--------|--------|------|
| 개발자 수 | ~3천만 | ~1억+ | GitHub |
| 오픈소스 프로젝트 | 많음 | 압도적 | GitHub |
| Discussions | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub |
| Sponsors | ❌ | ⭐⭐⭐⭐⭐ | GitHub |
| Social Coding | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub |

### 💰 비용 비교 (2025년 기준)

#### GitLab 가격

```
Free Tier (무료)
├── 공개/비공개 저장소 무제한
├── CI/CD 400분/월
├── 5GB 스토리지
└── ❌ 고급 보안 기능 없음

Premium ($29/user/월)
├── CI/CD 10,000분/월
├── 고급 CI/CD (부모-자식 파이프라인)
├── Code Owners
├── Multiple Approvers
└── ⚠️  보안 스캔 제한적

Ultimate ($99/user/월)
├── CI/CD 50,000분/월
├── 보안 스캔 전체 (SAST/DAST/컨테이너)
├── 컴플라이언스 관리
├── Portfolio Management
└── ✅ 엔터프라이즈급 모든 기능
```

#### GitHub 가격

```
Free (무료)
├── 공개 저장소 무제한
├── 비공개 저장소 무제한
├── Actions 2,000분/월
├── Packages 500MB
└── ❌ 고급 보안 기능 없음

Team ($4/user/월)
├── Actions 3,000분/월
├── Packages 2GB
├── Protected Branches
├── Code Owners
└── ⚠️  보안 기능 없음

Enterprise Cloud ($21/user/월)
├── Actions 50,000분/월
├── Packages 50GB
├── SAML SSO
├── Advanced Security (+$49/committer)
│   ├── CodeQL (SAST)
│   ├── Secret Scanning
│   ├── Dependabot
│   └── Security Overview
├── Audit Log
└── ✅ 엔터프라이즈 기능

GitHub Copilot
├── Individual: $10/월
├── Business: $19/user/월
└── Enterprise: $39/user/월
```

### 💡 실제 비용 계산 예시

#### 시나리오 1: 50명 개발팀

**GitLab Ultimate**
```
50명 × $99 = $4,950/월 ($59,400/년)
+ Self-hosted 인프라 비용 (선택)
= 약 $60,000/년
```

**GitHub Enterprise Cloud + Advanced Security + Copilot**
```
50명 × $21 = $1,050/월 (Enterprise)
50명 × $49 = $2,450/월 (Advanced Security)
50명 × $39 = $1,950/월 (Copilot Enterprise)
= $5,450/월 ($65,400/년)
```

**결론**: GitLab이 약간 저렴하지만, Copilot 포함 시 비슷함

#### 시나리오 2: 200명 개발팀

**GitLab Ultimate**
```
200명 × $99 = $19,800/월 ($237,600/년)
```

**GitHub (같은 구성)**
```
200명 × ($21 + $49 + $39) = $21,800/월 ($261,600/년)
```

**결론**: 규모가 커질수록 GitLab이 약 10% 저렴

### 🎯 최종 추천

#### GitHub를 선택해야 하는 경우

✅ **다음 중 하나라도 해당하면 GitHub**
- 오픈소스 프로젝트를 운영하거나 기여
- AI 코딩 도구(Copilot)가 필수
- 스타트업 또는 빠른 시작 필요
- 기존 GitHub 사용 중 (이미 익숙함)
- 클라우드 우선 전략
- 커뮤니티/채용에서 GitHub 프로필 중요
- 간단한 CI/CD만 필요

#### GitLab을 선택해야 하는 경우

✅ **다음 중 하나라도 해당하면 GitLab**
- 온프레미스 배포 필수 (규제/보안)
- 단일 통합 DevOps 플랫폼 원함
- DAST, Container Scanning 등 풀스택 보안 필요
- 복잡한 멀티 프로젝트/팀 구조
- GitLab CI/CD의 고급 기능 필요 (DAG, 동적 파이프라인)
- 자체 관리형 인프라 선호
- 비용 최적화 중요 (대규모 팀)

### 🤝 하이브리드 전략

**많은 기업이 실제로 사용하는 패턴:**

```
📦 GitLab (내부)
├── 비공개 프로젝트
├── 프로덕션 CI/CD
├── 보안 스캔
└── 컴플라이언스 관리

🌐 GitHub (외부)
├── 오픈소스 프로젝트
├── 커뮤니티 협업
├── 채용/브랜딩
└── Copilot 사용
```

**예시: Netflix, Spotify, Uber**
- 내부: GitLab Enterprise (또는 자체 구축)
- 외부: GitHub에 오픈소스 공개
- 전략: "Best of Both Worlds"

### 🔄 마이그레이션 고려사항

#### GitLab → GitHub

**쉬운 것**
- Git 저장소 (완벽 이전)
- Issue 기본 내용
- 마일스톤

**어려운 것**
- CI/CD 파이프라인 (완전 재작성 필요)
- GitLab 특화 기능 (Epics, Value Stream)
- Merge Request 세부 메타데이터

**도구**
```bash
# GitHub Enterprise Importer 사용
gh gei migrate-repo \
  --source-repo gitlab.com/org/repo \
  --target-repo github.com/org/repo \
  --gitlab-token $GITLAB_TOKEN \
  --github-token $GITHUB_TOKEN
```

#### GitHub → GitLab

**쉬운 것**
- Git 저장소
- Issue/PR 기본 내용
- Wiki

**어려운 것**
- GitHub Actions → GitLab CI (YAML 문법 다름)
- GitHub Apps 통합
- Copilot 대체 (GitLab Duo는 아직 부족)

**도구**
```bash
# GitLab Project Import
# GitLab UI에서 GitHub 토큰으로 직접 가져오기
```

### 📊 의사결정 매트릭스

최종 점수를 매겨보세요:

```
[ ] 온프레미스 필수 (+10 GitLab)
[ ] 통합 DevOps (+10 GitLab)
[ ] AI 코딩 필수 (+10 GitHub)
[ ] 오픈소스 중심 (+10 GitHub)
[ ] 대규모 조직 (+5 GitLab)
[ ] 빠른 시작 (+5 GitHub)
[ ] 비용 민감 (+5 GitLab, 대규모)
[ ] 커뮤니티 중요 (+10 GitHub)
[ ] 풀스택 보안 (+5 GitLab)
[ ] CI/CD 고급 기능 (+5 GitLab)

총점:
GitLab: _____
GitHub: _____

→ 높은 점수 쪽 선택
→ 비슷하면 POC 후 결정
```

</details>

---

## 🎓 학습 로드맵

<details>
<summary>🔽 펼치기: GitHub 마스터 되기 (4주 과정)</summary>

### 📅 Week 1: 기초 다지기

**Day 1-2: Git 기본**
```bash
# 필수 Git 명령어 마스터
git init, clone, add, commit, push, pull
git branch, checkout, merge
git log, diff, status
git stash, cherry-pick, rebase

# 실습 프로젝트
- 개인 저장소 생성
- 브랜치 전략 실습
- Merge vs Rebase 비교
```

**Day 3-4: GitHub 기본**
```markdown
- GitHub 계정 설정
- SSH 키 등록
- 저장소 생성 및 관리
- README, .gitignore 작성
- Issues, Labels 사용법
```

**Day 5-7: 협업 워크플로우**
```markdown
- Fork & Pull Request 흐름
- 코드 리뷰 방법
- CODEOWNERS 설정
- Branch Protection Rules
- PR 템플릿 작성
```

### 📅 Week 2: GitHub Actions 마스터

**Day 8-9: Actions 기초**
```yaml
# 첫 워크플로우 작성
- Workflow 구조 이해
- Triggers (on:)
- Jobs, Steps
- Actions Marketplace 활용
```

**Day 10-11: CI/CD 구축**
```yaml
# 언어별 빌드 파이프라인
- Node.js/Python/Java 빌드
- 테스트 자동화
- Docker 이미지 빌드
- 배포 자동화 (AWS/GCP/Azure)
```

**Day 12-14: 고급 Actions**
```yaml
# 재사용 가능한 워크플로우
- Composite Actions 개발
- Reusable Workflows
- Matrix 빌드
- 캐싱 전략
- Self-hosted Runners
```

### 📅 Week 3: 보안 & 컴플라이언스

**Day 15-16: GitHub Advanced Security**
```markdown
- Secret Scanning 설정
- Dependabot 활성화
- CodeQL 분석
- Security Advisories 발행
```

**Day 17-18: 조직 관리**
```markdown
- Organization 구조 설계
- Team 권한 관리
- SAML SSO 연동
- 감사 로그 수집
```

**Day 19-21: 컴플라이언스**
```python
# 자동화 스크립트 작성
- 컴플라이언스 체커
- 정책 위반 탐지
- 리포트 자동 생성
- 알림 자동화
```

### 📅 Week 4: AI & 고급 기능

**Day 22-24: GitHub Copilot**
```markdown
- Copilot 설치 및 설정
- 효과적인 프롬프트 작성
- Copilot Chat 활용
- 조직 정책 관리
```

**Day 25-26: GitHub API & 자동화**
```python
# GitHub API 마스터
- REST API vs GraphQL
- GitHub CLI (gh)
- 커스텀 GitHub Apps
- Webhooks 활용
```

**Day 27-28: 프로젝트 완성**
```markdown
# 최종 프로젝트
- 전체 DevOps 파이프라인 구축
- 보안 자동화
- 모니터링 대시보드
- 문서화
```

### 🎯 학습 리소스

```markdown
## 공식 문서
- [GitHub Docs](https://docs.github.com)
- [GitHub Skills](https://skills.github.com)
- [GitHub Blog](https://github.blog)

## 무료 코스
- GitHub Learning Lab
- Microsoft Learn - GitHub
- Udemy 무료 GitHub 코스

## 커뮤니티
- GitHub Community Forum
- Stack Overflow [github] 태그
- Reddit r/github

## 실습 플랫폼
- GitHub Skills (인터랙티브 튜토리얼)
- Katacoda GitHub 시나리오
- Lab.github.com
```

</details>

---

## 🎉 최종 정리

### ✨ 핵심 요약

이 종합 가이드는 **GitHub 구축/운영/사용의 모든 측면**을 다룹니다:

1. **배포 전략** - GitHub.com, GHEC, GHES 선택 기준
2. **조직 관리** - Enterprise/Organization/Team 구조 설계
3. **보안 강화** - GHAS 활용, 컴플라이언스 자동화
4. **CI/CD 자동화** - GitHub Actions 재사용 패턴
5. **AI 통합** - Copilot 조직 정책 및 모니터링
6. **거버넌스** - 감사 로그, SOC2/ISO27001 준수

### 🔄 GitLab vs GitHub - 간단 요약

```
GitLab: 통합 DevOps 플랫폼, 온프레미스 강점
GitHub: AI + 커뮤니티, 클라우드 우선

→ 조직 상황에 맞게 선택
→ 하이브리드도 가능
```

### 📚 다음 스텝

원하시는 부분을 지정해주시면:
- 특정 섹션 심화 확장
- 실전 시나리오 추가
- 역할별 맞춤 가이드
- 마이그레이션 상세 가이드
- 문제 해결 (Troubleshooting) 섹션

무엇이든 추가로 작성해드리겠습니다! 🚀