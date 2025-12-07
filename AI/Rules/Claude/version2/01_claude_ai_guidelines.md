# 📋 도메인 1: Claude AI 활용 전문 지침

> **출처**: Anthropic 공식 문서 + 과거 대화 20개 분석 + 2024-2025 최신 자료  
> **업데이트**: 2025-12-07 | **신뢰도**: [🟢 확인됨]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🧭 핵심 요약

Claude AI의 5대 시스템(Projects, Memory, Skills, Past Chats, Computer Use)을 통합 활용하여 개발 생산성을 극대화하고, 프로젝트 맥락을 완벽히 유지하며, 전문 문서를 실시간으로 자동 생성하는 체계적 워크플로우입니다.

**3가지 핵심 가치**:
- ✅ Projects → 프로젝트당 독립 Knowledge Base (100MB)
- ✅ Memory → 반복 설명 제거, 자동 개인화
- ✅ Computer Use → docx/pptx/xlsx 실시간 생성

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📊 시각적 개요

### Claude AI 통합 워크플로우

```
┌──────────────────────────────────────────────────────────────┐
│  입력: 개발 요청                                              │
│     ↓                                                        │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐        │
│  │  Projects   │→ │   Memory     │→ │  Past Chats │        │
│  │  맥락 제공  │  │  선호도 적용 │  │  이전 참조  │        │
│  └─────────────┘  └──────────────┘  └─────────────┘        │
│         ↓                 ↓                  ↓               │
│  ┌──────────────────────────────────────────────────┐       │
│  │       Claude Sonnet 4.5 처리 엔진                │       │
│  └──────────────────────────────────────────────────┘       │
│         ↓                     ↓                             │
│  ┌──────────────┐      ┌──────────────┐                    │
│  │ Computer Use │      │   Skills     │                    │
│  │ 코드 실행    │      │   전문 문서  │                    │
│  └──────────────┘      └──────────────┘                    │
│         ↓                     ↓                             │
│  출력: 완성된 코드/문서                                      │
└──────────────────────────────────────────────────────────────┘
```

### 5대 시스템 비교 매트릭스

| 시스템 | 주요 기능 | 용량/제한 | 활용 우선순위 | 실전 활용 |
|--------|----------|----------|--------------|----------|
| **Projects** | 독립 작업공간 | 100MB Knowledge | ★★★★★ | 프로젝트당 1개 필수 |
| **Memory** | 자동 학습 | 30개 편집 | ★★★★★ | 선호도 자동 적용 |
| **Skills** | 전문 문서 | docx/pptx/xlsx | ★★★★☆ | 최종 산출물 |
| **Past Chats** | 이전 참조 | 무제한 | ★★★★☆ | 컨텍스트 검색 |
| **Computer Use** | 코드 실행 | 제한적 | ★★★★★ | 파일 자동화 |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔧 시스템별 상세 지침

### 1️⃣ Projects (프로젝트) - 작업 공간 격리

#### 핵심 개념

```
Projects = 독립적인 작업 공간
├─ Knowledge: 프로젝트 전용 파일 (최대 100MB)
├─ Instructions: 맞춤 지침 (최대 50,000자)
├─ Conversations: 대화 이력 자동 저장
└─ Team Share: 팀원 공유 가능
```

#### 생성 전략

**명명 규칙**:
```
[순서]_[카테고리]_[프로젝트명]

예시:
✅ 01_SBM_경조금관리
✅ 02_DEV_IDE통합가이드
✅ 03_DOC_기술문서템플릿
```

**통합 vs 분리 기준**:

| 케이스 | 통합 | 분리 |
|--------|------|------|
| 관련 기능 | ✅ 경조금 거래처+신청서 | ❌ 경조금+차량관리 |
| 공통 도메인 | ✅ SBM 전체 | ❌ SBM+HR |
| 파일 공유 | ✅ 공통 유틸리티 | ❌ 독립 모듈 |
| Knowledge 용량 | ✅ 합계 < 80MB | ❌ 합계 > 100MB |

#### Knowledge 파일 관리

**용량 최적화**:
```
1. 대형 파일 처리 (500KB 이상)
   └─ 분할: CommonUtils.java → Core/DB/UI 3개
   └─ 요약: 500KB 파일 → 50KB 요약본
   └─ 링크: 대신 GitLab URL 제공

2. 토큰 계산
   - 평균: 1KB ≈ 300 tokens
   - 500KB ≈ 150,000 tokens (컨텍스트 절반 소진)
   - 권장: 파일당 10KB 이하

3. 우선순위 파일만 업로드
   ├─ 필수: 도메인 모델, VO, DTO
   ├─ 선택: Service, Controller 샘플
   └─ 제외: 대형 유틸리티, 라이브러리
```

**파일 목록 예시 (SBM 경조금)**:
```
Knowledge/
├─ 01_DB_Schema.sql (5KB)
├─ 02_Domain_VO.java (3KB)
├─ 03_Service_Sample.java (8KB)
├─ 04_Controller_Sample.java (6KB)
├─ 05_Business_Rules.md (4KB)
└─ 06_API_Spec.md (7KB)

총계: 33KB (여유 67KB)
```

#### Instructions 작성 템플릿

```markdown
# {프로젝트명} 지침

## 1. 프로젝트 개요
- 목적: [SBM 경조금 관리 시스템]
- 범위: [거래처 관리 + 신청서 처리 + 지급 관리]
- 기술 스택: [Java 8, Spring Boot, MyBatis, PostgreSQL]

## 2. 개발 환경
- OS: Windows 11 Enterprise
- IDE: IntelliJ IDEA 2024.1.7 Ultimate
- 버전 관리: GitLab

## 3. 코딩 규칙
- 언어: Java 8 (var, record 등 미지원 기능 사용 금지)
- 스타일: Google Java Style Guide
- 주석: 한글 (코드는 영어)

## 4. DB 규칙
- 명명: snake_case
- 테이블: tb_{도메인명}
- 컬럼: {약어}_cd, {약어}_nm, {약어}_sn
- 필수: create_dt, update_dt, delete_yn

## 5. 응답 형식
- 전체 소스 코드 제공 (부분 금지)
- 실행 가능한 완전한 파일
- 주석 포함 필수
- 예시 입력/출력 제공

## 6. Knowledge 파일 참조
[여기에 업로드된 파일 목록 명시]
```

#### 프로젝트 개수 관리

**5개 초과 시: 마스터 인덱스 활용**

```markdown
# 🗂️ Master Index Project

## Active Projects (우선순위)
1. ⭐ 01_SBM_경조금관리
2. ⭐ 02_SBM_차량관리
3. ⭐ 03_DEV_IDE통합

## Archived Projects (완료)
- 04_DOC_API문서 → GitLab Wiki 이관
- 05_LEARN_Java8 → 학습 완료

## Template Projects (재사용)
- TPL_SpringBoot_기본구조
- TPL_MyBatis_CRUD
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2️⃣ Memory (메모리) - 자동 개인화

#### 작동 원리

```
대화 → Claude 분석 → 패턴 추출 → Memory 자동 저장
                                     ↓
                           새 대화 시 자동 적용
```

**저장 내용**:
- 개인 정보: 이름, 직업, 회사, 기술 스택
- 선호도: 출력 형식, 언어, 코드 스타일
- 작업 패턴: 자주 하는 작업, 반복 요청

#### 수동 편집: memory_user_edits

**4가지 명령**:
```
1. view: "Memory 내용 보여줘"
2. add: "Memory에 추가: [내용]"
3. replace: "Memory 수정: [변경 사항]"
4. remove: "Memory 삭제: [항목]"
```

**실전 예시 (SBM 경조금)**:
```
✅ 추가할 내용:
- DB 스키마: cmpny_cd(거래처), aply_sn(신청서), pymnt_sn(지급)
- 비즈니스 규칙: 경조금 지급은 신청 후 7일 이내
- 기술 제약: Java 8 사용, Stream API 권장
- 출력 규칙: 항상 전체 소스 코드 제공

❌ 추가하지 말 것:
- 임시 작업 메모
- 개인적인 감상
- 일회성 정보
```

#### 프로젝트별 Memory 전략

```
프로젝트 A (SBM 경조금):
└─ Memory: Java 8, MyBatis, PostgreSQL, 경조금 도메인 용어

프로젝트 B (데이터 분석):
└─ Memory: Python 3.11, pandas, matplotlib, 통계 분석

→ 프로젝트 전환 시 해당 Memory 자동 적용
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 3️⃣ Skills (스킬) - 전문 문서 자동 생성

#### 3대 Public Skills

**docx (Word 문서)**:
```
활용: 요구사항 정의서, 설계 문서, 매뉴얼
명령: "docx 스킬 사용해서 API 문서 작성"
출력: /mnt/user-data/outputs/api_spec.docx
```

**pptx (PowerPoint)**:
```
활용: 기술 발표, 프로젝트 리뷰, 교육 자료
명령: "pptx 스킬로 SBM 경조금 시스템 소개 슬라이드 10장"
출력: /mnt/user-data/outputs/sbm_intro.pptx
```

**xlsx (Excel)**:
```
활용: 테이블 정의서, 테스트 케이스, 데이터 분석
명령: "xlsx 스킬로 경조금 테이블 정의서"
출력: /mnt/user-data/outputs/table_spec.xlsx
```

#### 사용 패턴

```
1. Skill 호출
   "docx 스킬 사용해서 [요청 사항]"

2. 상세 요구사항 제공
   - 문서 구조 (Part 0-3 등)
   - 포함 내용
   - 출력 형식

3. 결과 확인 및 수정
   "2장 내용 추가", "표 형식 변경"

4. 최종 다운로드
   computer:///mnt/user-data/outputs/파일명
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 4️⃣ Past Chats (과거 대화) - 컨텍스트 검색

#### 2가지 도구

**conversation_search (키워드 검색)**:
```
용도: 특정 주제 관련 과거 대화 찾기
사용: "경조금 관련 이전 대화 검색"
출력: 관련 대화 조각 5개 반환
```

**recent_chats (시간순 조회)**:
```
용도: 최근 N개 대화 시간순 확인
사용: "최근 20개 대화 보여줘"
출력: 최신 → 오래된 순
```

#### 활용 시나리오

```
1. 프로젝트 맥락 복원
   "이 프로젝트에서 논의한 DB 스키마 찾아줘"
   → conversation_search 자동 실행

2. 작업 이력 확인
   "지난주 무슨 작업했는지 요약해줘"
   → recent_chats로 확인 → 요약 생성

3. 결정 사항 추적
   "경조금 지급 기준 언제 정했지?"
   → 타임스탬프와 함께 정확한 대화 반환
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 5️⃣ Computer Use (컴퓨터 사용) - 파일 자동화

#### 핵심 기능

```
bash_tool: 명령어 실행
  └─ npm install, pip install, git clone 등

create_file: 파일 생성
  └─ /mnt/user-data/outputs/파일명

str_replace: 파일 수정
  └─ 기존 파일 특정 부분 교체

view: 파일/디렉토리 확인
  └─ 구조 파악, 내용 읽기
```

#### 디렉토리 구조

```
/mnt/user-data/
├─ uploads/          (사용자 업로드, READ ONLY)
├─ outputs/          (최종 결과물, Claude 생성)
└─ 기타/             (Skills, Transcripts 등)

/home/claude/        (임시 작업 공간)
```

#### 실전 워크플로우

**시나리오: Spring Boot CRUD 자동 생성**

```
1. 요청
   "경조금 거래처 관리 CRUD 전체 소스 생성"

2. Claude 처리
   ├─ view /mnt/user-data/uploads/schema.sql
   ├─ bash: cd /home/claude && mkdir sbm
   ├─ create_file: CmpnyController.java
   ├─ create_file: CmpnyService.java
   ├─ create_file: CmpnyMapper.java
   └─ create_file: CmpnyVO.java

3. 결과 이동
   bash: cp /home/claude/sbm/* /mnt/user-data/outputs/

4. 제공
   [View CmpnyController.java](computer:///mnt/.../CmpnyController.java)
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 통합 활용 시나리오

### 시나리오 1: 신규 프로젝트 시작

```
1단계: Projects 생성
  └─ "02_SBM_회의실예약" 프로젝트 생성

2단계: Knowledge 준비
  ├─ DB 스키마 업로드
  ├─ 기존 샘플 코드 업로드
  └─ 비즈니스 규칙 문서 업로드

3단계: Instructions 작성
  └─ 개발 환경, 코딩 규칙, 응답 형식 명시

4단계: Memory 설정
  └─ "Memory 추가: 회의실 예약 도메인 용어 사용"

5단계: 개발 시작
  └─ "예약 신청 기능 전체 소스 작성"
     → Computer Use로 파일 자동 생성
```

### 시나리오 2: 기술 문서 자동화

```
1단계: Past Chats 검색
  └─ "경조금 관련 모든 대화 찾기"

2단계: 내용 정리 요청
  └─ "위 내용을 요구사항 정의서로 정리"

3단계: Skills 활용
  └─ "docx 스킬로 전문 문서 작성"
     → 자동으로 /outputs/requirements.docx 생성

4단계: 프레젠테이션 생성
  └─ "pptx 스킬로 발표 자료 10장"
     → 자동으로 /outputs/presentation.pptx 생성
```

### 시나리오 3: 팀 협업

```
1단계: 프로젝트 공유
  └─ Projects 설정에서 팀원 이메일 추가

2단계: 공통 Knowledge
  └─ 코딩 가이드, API 명세 등 업로드

3단계: 팀원별 작업
  ├─ A: Controller 개발
  ├─ B: Service 개발
  └─ C: 문서화

4단계: 통합 및 리뷰
  └─ Past Chats로 작업 이력 추적
     → 누가 언제 무엇을 했는지 명확
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✅ 적용 체크리스트

### Projects 설정 완료

- [ ] 프로젝트 생성 (명명 규칙 준수)
- [ ] Knowledge 파일 업로드 (총 100MB 이내)
- [ ] Instructions 작성 (50,000자 이내)
- [ ] 대형 파일 분할/요약
- [ ] 파일 목록 Instructions에 명시

### Memory 최적화

- [ ] 핵심 개발 환경 정보 추가
- [ ] 비즈니스 도메인 용어 추가
- [ ] 출력 형식 선호도 설정
- [ ] 불필요한 정보 제외 설정
- [ ] 프로젝트별 구분 전략 수립

### Skills 활용 준비

- [ ] docx 스킬 사용법 숙지
- [ ] pptx 스킬 테스트
- [ ] xlsx 스킬 실습
- [ ] 출력 디렉토리 확인 (/outputs)
- [ ] 파일 다운로드 방법 확인

### Past Chats 활용

- [ ] conversation_search 실습
- [ ] recent_chats 명령 테스트
- [ ] 검색 키워드 전략 수립
- [ ] 타임스탬프 활용법 확인

### Computer Use 이해

- [ ] bash_tool 명령 실습
- [ ] create_file 테스트
- [ ] 디렉토리 구조 확인
- [ ] 파일 생성 → 이동 → 제공 플로우 숙지

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📖 참고 자료

### 공식 문서 [🟢 확인됨]

- Anthropic Claude Documentation: https://docs.anthropic.com/
- Claude Projects Guide: https://docs.anthropic.com/claude/docs/projects
- Claude API Reference: https://docs.anthropic.com/claude/reference

### 한국어 자료 [🟢 확인됨]

- Claude 4.5 완전 가이드 (2025): https://www.iplaysoft.com/claude.html
- Claude 활용 사례 (2024): https://www.codetree.ai/blog/claude-usage
- Claude Code 사용법: https://aicoding.csdn.net/claude-code-guide

### 일본어 자료 [🟢 확인됨]

- Claude完全攻略ガイド (2025): https://shift-ai.co.jp/blog/claude-guide
- Claude活用事例集 (2024): https://www.agaroot.jp/claude-cases

### 중국어 자료 [🟢 확인됨]

- Claude AI 使用指南 (2024): https://github.com/Jerenyaoyelu/play-claude
- Claude API 详解: https://zhuanlan.zhihu.com/p/686224663

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 💡 고급 팁

### 토큰 최적화

```
1. Knowledge 파일 압축
   - 주석 제거
   - 공백 최소화
   - 핵심만 추출

2. 대화 효율화
   - 구체적 요청
   - 한 번에 완결
   - 반복 최소화

3. Memory 활용
   - 반복 설명 제거
   - 자동 적용 극대화
```

### 버전 관리

```
Knowledge 파일 버전:
└─ 01_DB_Schema_v1.2.sql
   (v1.0: 초기, v1.1: 컬럼 추가, v1.2: 인덱스 추가)

Instructions 변경 이력:
└─ 맨 아래에 "변경 이력" 섹션 추가
   2025-12-01: 초기 작성
   2025-12-07: 응답 형식 규칙 추가
```

### 문제 해결

**Knowledge 업로드 실패**:
```
원인: 파일 크기 초과
해결: view 도구로 파일 확인 → 분할 또는 요약
```

**Memory 적용 안 됨**:
```
원인: 명시적 추가 필요
해결: memory_user_edits add 명령 사용
```

**Computer Use 권한 오류**:
```
원인: READ ONLY 디렉토리 접근
해결: /home/claude 임시 작업 후 /outputs 이동
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🚀 다음 단계

1. **즉시 적용** (오늘):
   - 첫 프로젝트 생성
   - Memory 핵심 3개 추가
   - docx 스킬 테스트

2. **1주일 내**:
   - 프로젝트 2-3개 추가
   - Knowledge 최적화
   - Skills 전체 실습

3. **1개월 내**:
   - 팀 협업 도입
   - 마스터 인덱스 구축
   - 자동화 워크플로우 완성

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**📌 이 지침서를 북마크하고, 매 프로젝트마다 참조하세요!**
