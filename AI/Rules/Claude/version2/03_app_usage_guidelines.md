# 📱 도메인 3: 앱 사용법 최적화 지침

> **출처**: IntelliJ, GitHub Copilot 공식 문서 + 실전 경험  
> **업데이트**: 2025-12-07 | **신뢰도**: [🟢 확인됨]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🧭 핵심 요약

개발 생산성을 극대화하는 핵심 앱/도구 활용법입니다. IntelliJ IDEA, GitHub Copilot, Git/GitLab을 중심으로 실전 워크플로우를 제공합니다.

**3가지 핵심**:
- ✅ IntelliJ 디버깅 마스터 → 버그 해결 속도 3배
- ✅ GitHub Copilot 극한 활용 → 코딩 속도 2배
- ✅ Git 워크플로우 최적화 → 협업 효율 5배

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔧 핵심 도구 가이드

### 1️⃣ IntelliJ IDEA 2024.1.7 Ultimate

#### 필수 단축키 (Windows)

| 기능 | 단축키 | 활용 |
|------|--------|------|
| **검색 어디서나** | `Shift + Shift` | 파일, 클래스, 심볼 통합 검색 |
| **클래스 이동** | `Ctrl + N` | 클래스명으로 빠른 이동 |
| **파일 이동** | `Ctrl + Shift + N` | 파일명으로 빠른 이동 |
| **선언부 이동** | `Ctrl + B` | 메소드/변수 정의로 이동 |
| **호출 추적** | `Ctrl + Alt + H` | 메소드 호출 계층 확인 |
| **리팩토링** | `Ctrl + Alt + Shift + T` | 리팩토링 메뉴 |
| **코드 생성** | `Alt + Insert` | Getter/Setter 자동 생성 |
| **코드 완성** | `Ctrl + Space` | 기본 자동완성 |
| **스마트 완성** | `Ctrl + Shift + Space` | 타입 기반 자동완성 |

#### 디버깅 워크플로우

```
1. 브레이크포인트 설정
   └─ 줄 번호 옆 클릭 (빨간 점)
   └─ 조건부 BP: 우클릭 → Condition 입력

2. 디버그 실행
   └─ Shift + F9 (디버그 모드 시작)

3. 실행 제어
   ├─ F8: Step Over (다음 줄)
   ├─ F7: Step Into (메소드 안으로)
   ├─ Shift + F8: Step Out (메소드 밖으로)
   └─ Alt + F9: Run to Cursor (커서 위치까지)

4. 변수 확인
   ├─ Variables 창: 현재 스코프 변수
   ├─ Watches: 관찰할 표현식 추가
   └─ Evaluate: Alt + F8 (표현식 즉시 평가)

5. Hotswap
   └─ 코드 수정 후 Ctrl + F9 (디버깅 중 적용)
```

#### GitLab 통합

```
1. 프로젝트 Clone
   File → New → Project from Version Control
   └─ GitLab URL 입력

2. 브랜치 관리
   Git 탭 → Branches → New Branch
   └─ feature/경조금-신청서-CRUD

3. 커밋
   Ctrl + K → 변경 파일 선택 → 메시지 작성 → Commit

4. Push
   Ctrl + Shift + K → Push

5. Pull Request
   Git 탭 → + → Create Pull Request
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 2️⃣ GitHub Copilot - AI 코딩 어시스턴트

#### 기본 사용법

```java
// 1. 주석으로 의도 작성
// 사용자 ID로 사용자를 조회하고, 없으면 예외 발생

// 2. Tab 키로 제안 수락
public User getUser(Long userId) {
    return userRepository.findById(userId)
        .orElseThrow(() -> new UserNotFoundException(userId));
}

// 3. Alt + ] / Alt + [ 로 다른 제안 확인
```

#### Copilot Chat 활용

```
/explain: 코드 설명
  "이 메소드가 뭐하는 거야?"

/fix: 버그 수정
  "NullPointerException 고쳐줘"

/tests: 테스트 코드 생성
  "이 서비스 클래스 JUnit 테스트 만들어줘"

/doc: 문서화
  "이 클래스에 JavaDoc 추가해줘"

/refactor: 리팩토링
  "이 메소드를 더 읽기 쉽게 리팩토링해줘"
```

#### 프롬프트 작성 팁

```
❌ 나쁜 예:
"사용자 관련 코드 만들어줘"

✅ 좋은 예:
"Spring Boot UserService 클래스를 만들어줘. 
요구사항:
- UserRepository 의존성 주입
- getUser(Long id): 사용자 조회, 없으면 UserNotFoundException
- createUser(UserCreateRequest): 사용자 생성, 이메일 중복 체크
- updateUser(Long id, UserUpdateRequest): 사용자 수정
- deleteUser(Long id): 논리 삭제 (deleteYn = 'Y')
- 모든 메소드에 @Transactional
- 모든 public 메소드에 JavaDoc"
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 3️⃣ Git/GitLab 워크플로우

#### Branch 전략 (Git Flow)

```
main (프로덕션)
  ↓
develop (개발)
  ↓
feature/경조금-신청서-CRUD (기능 개발)
hotfix/경조금-계산-오류 (긴급 수정)
```

#### 커밋 메시지 컨벤션

```
<type>(<scope>): <subject>

<body>

<footer>

Type:
- feat: 새 기능
- fix: 버그 수정
- docs: 문서만 변경
- style: 코드 포맷팅
- refactor: 리팩토링
- test: 테스트 추가
- chore: 빌드/설정 변경

예시:
feat(경조금): 신청서 CRUD API 구현

- CmpnyAplyController 추가
- CmpnyAplyService 추가
- CmpnyAplyMapper XML 작성

Closes #123
```

#### Pull Request 체크리스트

```markdown
## 변경 사항
- [ ] 신청서 등록 API
- [ ] 신청서 조회 API
- [ ] 신청서 수정 API
- [ ] 신청서 삭제 API

## 테스트
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 작성
- [ ] Postman으로 수동 테스트

## 문서
- [ ] API 명세 업데이트
- [ ] README 업데이트

## 리뷰어
@팀장 @선배개발자
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✅ 생산성 체크리스트

### IntelliJ IDEA

- [ ] 필수 단축키 10개 암기
- [ ] Live Template 설정 (psvm, sout 등)
- [ ] 플러그인 설치 (GitLab, SonarLint, Lombok)
- [ ] 코드 스타일 설정 (Google Java Style)
- [ ] 디버깅 조건부 BP 활용

### GitHub Copilot

- [ ] Copilot Chat 4가지 명령 숙지
- [ ] 주석 기반 코드 생성 연습
- [ ] 테스트 코드 자동 생성 활용
- [ ] 리팩토링 제안 검토 습관

### Git/GitLab

- [ ] Git Flow 브랜치 전략 적용
- [ ] 커밋 메시지 컨벤션 준수
- [ ] PR 템플릿 작성
- [ ] 코드 리뷰 참여

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📖 참고 자료

### 공식 문서 [🟢 확인됨]

- IntelliJ IDEA 사용법: https://www.jetbrains.com/idea/learn/
- GitHub Copilot 가이드: https://docs.github.com/en/copilot
- Git 공식 문서: https://git-scm.com/doc

### 한국어 자료 [🟢 확인됨]

- IntelliJ 단축키 모음: https://gmlwjd9405.github.io/2019/05/21/intellij-shortcut.html
- Git Flow 전략: https://techblog.woowahan.com/2553/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 💡 추가 팁

### IntelliJ 숨은 기능

```
1. Multiple Cursors
   └─ Alt + J: 같은 단어 추가 선택
   └─ Alt + Shift + J: 선택 해제
   └─ Ctrl + Alt + Shift + J: 모든 같은 단어 선택

2. Postfix Completion
   list.for → for (String item : list) {}
   condition.if → if (condition) {}

3. Scratch Files
   Ctrl + Alt + Shift + Insert → 임시 파일 생성
```

### Copilot 고급 활용

```
1. Context 제공
   // 파일 상단에 컨텍스트 주석
   // 이 파일은 경조금 신청서 Service입니다.
   // 사용 기술: Spring Boot, MyBatis, PostgreSQL
   
2. 예시 코드 참조
   // 기존 코드를 주석으로 복사 → Copilot이 패턴 학습
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**📌 하루 30분씩 단축키 연습으로 1달이면 마스터!**
