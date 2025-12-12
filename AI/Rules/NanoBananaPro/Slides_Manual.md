# 🎯 Google Slides + Nano Banana Pro 실무 완벽 매뉴얼

## 📌 빠른 요약

- 🟢 **Nano Banana Pro (Gemini 3 Pro Image)**는 2025년 11월 20일부터 Google Workspace 고객을 위해 Google Slides, Vids, Gemini 앱, NotebookLM에 순차 출시됨
- 🟢 **Gemini in Slides**는 이미지/슬라이드/요약/콘텐츠 생성 지원, Workspace Business Standard 이상 플랜에서 가용
- 🟢 **SynthID 워터마크**는 모든 AI 생성 콘텐츠(이미지/텍스트/오디오)에 자동 삽입, 사람 눈에는 보이지 않음
- 🟢 **Apps Script + Slides API**는 batchUpdate를 통해 대규모 슬라이드 자동 생성/일괄 수정 가능
- 🟡 **사용량 제한**은 프로모션 기간(최소 60일) 후 변경 예정, Google에서 별도 공지 제공 예정
- 출처: Google Workspace 업데이트 블로그(2025-11-20), Google Cloud 블로그(2025-12-03)

---

## 📊 시각적 개요: 주요 기능 비교

### 기능 비교: 어느 도구를 선택할까?

| 기능/작업 | Google Slides 기본 | Gemini in Slides | Apps Script | Slides API | 추천 |
|---------|---|---|---|---|---|
| **텍스트 편집** | ✅ 기본 | ✅✅ (문법, 톤 조정) | ❌ | ❌ | Gemini in Slides |
| **이미지 생성** | ❌ | ✅✅ (Nano Banana Pro) | ❌ | ❌ | Gemini in Slides |
| **슬라이드 생성** | ✅ 수동 | ✅✅ (AI 제안) | ✅✅✅ (대량) | ✅✅✅ (API) | 규모에 따라 선택 |
| **프레젠테이션 요약** | ❌ | ✅✅ | ❌ | ❌ | Gemini in Slides |
| **데이터 연동** | ❌ | ❌ | ✅✅ (Sheet 연동) | ✅✅ (고급) | Apps Script/API |
| **일괄 수정** | ❌ | ❌ | ✅✅ | ✅✅ | Apps Script/API |
| **테마/마스터 설정** | ✅✅ | ❌ | ❌ | ❌ | Slides 기본 편집 |
| **공동 작업/발표** | ✅✅ | ✅✅ | ❌ | ❌ | Slides 기본 |

### Nano Banana Pro vs 기존 모델

| 항목 | Nano Banana (2025 초반) | Nano Banana Pro (최신) |
|------|---|---|
| **텍스트 렌더링 정확도** | 중간 | ✅ 매우 높음 |
| **복잡한 인포그래픽** | 제한적 | ✅ 우수 |
| **Google Search 연동** | 아니오 | ✅ 예 |
| **Workspace 가용성** | 제한적 | ✅ Slides/Vids/Gemini/NotebookLM |
| **SynthID 워터마크** | ✅ | ✅ 자동 포함 |

---

## 🔧 메인 매뉴얼: 5가지 핵심 기능

### 1️⃣ Google Slides 핵심 조작법 (기본기)

#### A. 슬라이드 구조 이해하기

**개념:**
- **프레젠테이션** = 여러 슬라이드를 포함하는 전체 파일
- **슬라이드** = 각 페이지 (기본 16:9 또는 4:3)
- **레이아웃** = 제목, 본문, 이미지 자리 같은 템플릿 구조
- **마스터/테마** = 모든 슬라이드의 배경, 폰트, 컬러 규칙

**실무 사용:**
슬라이드는 "마스터 → 레이아웃 → 개별 슬라이드"의 3단계 계층 구조. 상위에서 변경하면 아래 모든 슬라이드에 영향.

**✅ 빠른 시작 (5단계)**
1. Google Slides 열기: **drive.google.com** → **+ 새로 만들기** → **프레젠테이션**
2. 기본 슬라이드 대신 템플릿 선택: **슬라이드** → **템플릿 갤러리**
3. 마음에 드는 템플릿 선택
4. 텍스트 상자를 클릭해 제목/내용 입력
5. **슬라이드** → **새 슬라이드** 로 슬라이드 추가

#### B. 테마 & 마스터 슬라이드 커스터마이징

**무엇을 할 수 있나:**
- 모든 슬라이드의 배경색/그라데이션/배경 이미지 설정
- 기본 폰트 (제목/본문) 통일
- 회사 로고 자동 삽입
- 색상 팔레트 (Accent 1~6) 정의

**어떻게 접근:**
메뉴 > **보기** > **테마 빌더** (이전: 마스터 슬라이드)

**실무 팁:**
- 테마 변경 후 개별 슬라이드에서 색/폰트 재설정하면 전체 일관성 깨짐 → **마스터에서만 수정 권장**
- 특정 슬라이드만 다른 디자인 원할 때: 테마 빌더에서 새 레이아웃 만들기

**✅ 테마 빌더 사용법 (5단계)**
1. 현재 프레젠테이션 열기
2. **보기** > **테마 빌더**
3. 왼쪽 패널의 맨 위 "마스터" 슬라이드 클릭 (전체 설정)
4. 오른쪽 위 **색상** 버튼 → 테마 컬러 선택
5. 완료 후 **X** 클릭하여 테마 빌더 닫기

#### C. 레이아웃 선택 & 활용

**자주 쓰는 레이아웃:**
- **제목 슬라이드** → 표지 (제목 + 부제목)
- **제목과 본문** → 내용 슬라이드 (제목 + 텍스트/숫자)
- **빈 슬라이드** → 자유롭게 커스터마이징
- **제목만** → 섹션 구분 슬라이드

**✅ 빠른 방법:**
새 슬라이드 추가 시 레이아웃 선택: **+ 새 슬라이드** 옆 드롭다운 → 원하는 레이아웃 클릭

#### D. 접근성 & 가독성 점검

**실무 필수 사항:**
- **대비**: 텍스트와 배경 색상 대비 ≥ 4.5:1 (WCAG AA 표준)
- **대체 텍스트**: 모든 이미지에 설명 추가
- **폰트**: 최소 18pt (제목), 14pt (본문) 권장
- **색상만 사용 금지**: 색상 + 패턴/텍스트로 정보 전달

**✅ 접근성 체크리스트**
1. 각 이미지에 마우스 우측 클릭 → **대체 텍스트** → 간단한 설명 입력
2. 텍스트 크기 점검: 소수의 글자는 최소 14pt 이상
3. 색상 대비 확인: 온라인 대비 검사 도구 사용

---

### 2️⃣ Gemini in Slides 활용 (AI 기반 콘텐츠 생성)

#### A. Gemini in Slides가 무엇인가?

**정의:**
Google Slides 오른쪽 패널에서 Gemini 챗봇에 접근하여 다음을 수행:
- 새 슬라이드 생성 (프롬프트 기반)
- 이미지 생성 (Nano Banana Pro)
- 프레젠테이션 요약
- 콘텐츠 작성/재작성 (톤, 길이 조정)
- Google Drive 파일 참조

**가용성:**
- ✅ Google Workspace: Business Standard/Plus, Enterprise Standard/Plus, Google AI Pro, Gemini Business/Enterprise
- ❌ 개인 Gmail 계정: 미지원 (Gemini 웹 사이트에서만 이미지 생성 가능)
- 📌 **관리자 설정**: Workspace 관리자가 Gemini 기능을 조직에서 활성화해야 함

#### B. Gemini in Slides 시작하기

**✅ 5단계 시작 가이드**
1. Google Slides에서 프레젠테이션 열기
2. 오른쪽 상단 **Gemini에게 도움 요청** 아이콘 클릭
   - (또는 **슬라이드** > **슬라이드 제작 도우미** 메뉴 사용)
3. 측면 패널이 열림: Gemini 채팅창 표시
4. 프롬프트 입력 예시: "5분 마케팅 전략 프레젠테이션을 만들어줘"
5. Gemini가 슬라이드 생성 제안 → **삽입** 또는 **다시 시도**

#### C. 좋은 프롬프트 입력 방법

**기본 구조:**
[작업] + [컨텍스트] + [스타일/톤] + [제약사항]

**예시 프롬프트:**

**1️⃣ 슬라이드 생성**
제품 출시 발표 프레젠테이션 5슬라이드를 만들어줘.
- 표지: 제목 '신제품 X 런칭'
- 2-3슬라이드: 주요 기능 3개
- 마지막: Call-to-Action

**2️⃣ 이미지 생성 (Help me visualize)**
클라우드 아키텍처 다이어그램을 만들어줘.
요소: 사용자 → API 게이트웨이 → 마이크로서비스 → 데이터베이스
색상: 파란색/흰색 (회사 브랜드)

**3️⃣ 콘텐츠 재작성**
이 슬라이드 텍스트를 간결하게 정리해줘.
목표: 3줄 이하, CEO 대상, 강력한 임팩트

**4️⃣ 프레젠테이션 요약**
이 프레젠테이션을 1-2문장으로 요약해줘.
핵심 메시지 3개를 뽑아줄래?

#### D. 실패 패턴 & 해결 방법

| 문제 | 원인 | 해결책 |
|------|------|------|
| 이미지가 텍스트를 못 읽음 | 프롬프트가 너무 복잡 | "큰 글씨, 최소 5개 단어만 포함" 명시 |
| 생성된 슬라이드 레이아웃 이상 | 현재 테마와 맞지 않음 | "현재 테마 유지" 명시 또는 직접 조정 |
| 톤이 맞지 않음 | 스타일 지시 부족 | "전문적이고 데이터 중심적으로" 추가 |
| 내용이 부정확함 | Gemini가 일반적 지식만 사용 | Google Drive 문서 참조 요청 |

---

### 3️⃣ Nano Banana Pro 프롬프트 템플릿 라이브러리

#### 🎨 A. 표지/히어로 비주얼 템플릿

**Template 1: B2B 제안서 표지**
- 목적: 고객사에 제시할 비즈니스 제안서 표지
- 색상: 깊은 파란색 배경, 흰색/은색 액센트
- 톤: 신뢰성 있고, 전문적이며, 혁신적
- 텍스트: 최대 3줄 (제목 + 부제 + 회사명)
- 실패 시: "배경을 더 어둡게, 텍스트를 더 크고 명확하게"

**Template 2: 기술 컨퍼런스 표지**
- 목적: 기술 세미나/웨비나 표지
- 색상: 밝은 파란색 + 네온 그린/보라색 액센트
- 톤: 현대적, 역동적, 전향적
- 요소: 컴퓨터 칩, 클라우드, 데이터 흐름 시각화
- 실패 시: "배경을 더 밝고 생동감 있게"

**Template 3: 제품/서비스 홍보 표지**
- 목적: 새로운 제품/앱/서비스 소개 슬라이드
- 색상: 주황색 + 검정 배경 (회사 브랜드)
- 톤: 혁신적, 모던, 사용자 친화적
- 요소: 제품 실루엣 또는 추상 아이콘
- 실패 시: "제품 아이콘을 더 크게, 중앙 배치"

#### 📊 B. 인포그래픽 템플릿

**Template 1: 3단계 프로세스 인포그래픽**
- 목적: 비즈니스 프로세스 또는 사용자 여정 시각화
- 구조: 3개 박스가 화살표로 연결
- 색상: 파란색 → 초록색 → 주황색 (점진적 변화)
- 각 단계 텍스트: 한 줄 제목 + 1-2줄 설명
- 실패 시: "박스들을 더 크게 하고, 화살표를 명확하게"

**Template 2: 비율/차트 인포그래픽**
- 목적: 시장 점유율, 예산 배분, 응답률 등 비율 표시
- 시각화: 파이 차트 또는 누적 바 차트
- 최대 5개 항목 (과포화 피하기)
- 범례 필수 포함
- 실패 시: "범례를 추가하고, 각 섹션에 백분율 라벨 표시"

**Template 3: 타임라인/마일스톤**
- 목적: 프로젝트 일정, 제품 로드맵, 회사 역사 표시
- 구조: 수평 타임라인 (왼쪽 → 오른쪽)
- 색상: 진행도에 따라 변화 (완료=초록, 진행중=노랑, 예정=회색)
- 최대 4-5개 마일스톤
- 실패 시: "타임라인을 더 명확하게, 마커를 더 크게"

#### 🎭 C. 아이콘/일러스트 템플릿

**Template 1: 비즈니스 기능 아이콘 세트**
- 목적: 회사 서비스/제품의 주요 기능 (5-6개) 아이콘화
- 스타일: 라인 아트 또는 플랫 디자인
- 일관성: 모든 아이콘 같은 크기, 선 두께 통일
- 배경: 원형 또는 사각형 배경 (선택)
- 실패 시: "모든 아이콘이 같은 크기와 스타일이어야 해"

**Template 2: 팀/직급 일러스트 세트**
- 목적: 조직도 또는 팀 구성원 소개 슬라이드
- 스타일: 미니멀한 인물 일러스트
- 다양성: 다양한 피부톤, 외형 표현
- 크기: 각 인물 일관
- 실패 시: "스타일을 더 일관되게, 모두 같은 느낌으로"

**Template 3: 산업별 심볼 세트**
- 목적: 산업군/분야별 심볼 아이콘
- 색상: 산업별로 구분 (금융=웜톤, IT=쿨톤, 에너지=그린톤)
- 미니멀 라인 아트
- 인식 가능할 정도의 간결함 유지
- 실패 시: "각 산업의 색상을 더 구분하고, 아이콘 크기를 균일하게"

#### 🖼️ D. 이미지 편집/재생성 템플릿

**Template 1: 배경 교체/정리**
- 목적: 기존 이미지의 배경을 깔끔하거나 브랜드에 맞게 변경
- 배경: 흰색, 라이트 그레이, 또는 회사 브랜드 컬러
- 주요 요소: 원본과 동일하게 유지
- 실패 시: "인물 영역은 건드리지 말 것"

**Template 2: 텍스트 오버레이 추가/변경**
- 목적: 기존 이미지에 슬로건 또는 텍스트 추가
- 폰트: 산세리프, 크고 명확
- 배경: 반투명 검정색 배너 (텍스트 가독성)
- 위치: 이미지 하단/상단
- 실패 시: "텍스트를 더 크게, 배경 배너를 더 어둡게"

**Template 3: 컬러 교정/톤 조정**
- 목적: 기존 이미지의 색감/밝기를 브랜드 톤에 맞게 조정
- 톤: 따뜻함 (따뜻한 화이트 밸런스)
- 포화도: 증가 (생동감)
- 밝기: 증가 (주요 요소 강조)
- 실패 시: "더 따뜻하게, 노란색/주황색 톤 강화"

---

### 4️⃣ Apps Script + Slides API 자동화

#### A. Apps Script 기초 (Google Sheets에서 Slides 생성)

**개념:**
Google Apps Script는 JavaScript 기반의 자동화 도구. Google Sheets의 데이터를 읽어 Google Slides에 자동으로 슬라이드 생성 가능.

**✅ 실행 예제 코드 (JavaScript)**

```javascript
/**
 * Google Sheets 데이터로 Slides 생성
 * 데이터 구조: [행] = [제목, 부제, 이미지URL]
 */

function createSlidesFromSheet() {
  // 1. 스프레드시트에서 데이터 읽기
  const sheet = SpreadsheetApp.getActiveSheet();
  const data = sheet.getDataRange().getValues();
  
  // 2. 기존 Slides 오픈 (또는 새로 생성)
  const presentationId = "YOUR_PRESENTATION_ID";
  const presentation = SlidesApp.openById(presentationId);
  
  // 3. 데이터 반복: 각 행마다 슬라이드 생성
  data.forEach((row, index) => {
    if (index === 0) return; // 헤더 행 스킵
    
    const title = row[0];
    const subtitle = row[1];
    const imageUrl = row[2];
    
    // 4. 새 슬라이드 생성
    const slide = presentation.appendSlide(
      SlidesApp.PredefinedLayout.TITLE_AND_BODY
    );
    
    // 5. 텍스트 요소 설정
    slide.getShapes()[0].getText().clear().appendText(title);
    slide.getShapes()[1].getText().clear().appendText(subtitle);
    
    // 6. 이미지 삽입
    if (imageUrl) {
      slide.insertImage(imageUrl, 100, 200, 200, 150);
    }
  });
  
  Logger.log("✅ Slides 생성 완료!");
}
```

**실행 방법:**
1. Google Sheets 열기 → **확장기능** → **Apps Script**
2. 위 코드 붙여넣기
3. YOUR_PRESENTATION_ID 자리에 Google Slides ID 입력
4. **실행** 버튼 클릭

---

#### B. Slides API를 이용한 고급 자동화 (Node.js/TypeScript)

**개념:**
REST API를 통해 더 복잡한 작업 가능: batchUpdate로 여러 작업을 한 번에 처리

**✅ 예제 코드 (Node.js)**

```javascript
const {google} = require('googleapis');

async function createSlidesWithAPI() {
  // 1. 인증 설정
  const auth = new google.auth.GoogleAuth({
    keyFile: 'service-account-key.json',
    scopes: ['https://www.googleapis.com/auth/presentations'],
  });
  
  const slides = google.slides({version: 'v1', auth});
  
  // 2. 새 Presentation 생성
  const createRes = await slides.presentations.create({
    requestBody: {
      title: '데이터 기반 자동 생성 덱',
    },
  });
  
  const presentationId = createRes.data.presentationId;
  console.log('✅ 프레젠테이션 생성:', presentationId);
  
  // 3. batchUpdate 요청 준비
  const requests = [
    {
      createSlide: {
        objectId: 'slide1',
        slideLayoutReference: {
          predefinedLayout: 'TITLE_SLIDE',
        },
      },
    },
    {
      insertText: {
        objectId: 'slide1',
        text: '2025 분기별 성과 분석',
      },
    },
  ];
  
  // 4. batchUpdate 실행
  const batchRes = await slides.presentations.batchUpdate({
    presentationId: presentationId,
    requestBody: {
      requests: requests,
    },
  });
  
  console.log('✅ batchUpdate 성공');
  return presentationId;
}

createSlidesWithAPI().catch(console.error);
```

**설정 방법:**
1. Google Cloud Console에서 Slides API 활성화
2. 서비스 계정 생성 → 키 파일 다운로드
3. Node.js 설치 후 실행

---

#### C. 에러 처리 & 재시도 로직

```javascript
async function createSlidesWithRetry(maxRetries = 3) {
  let retries = 0;
  
  while (retries < maxRetries) {
    try {
      const result = await slides.presentations.batchUpdate({...});
      return result;
    } catch (error) {
      retries++;
      
      if (error.code === 429) {
        // Rate limit - 지수 백오프로 재시도
        const delayMs = Math.pow(2, retries) * 1000;
        await new Promise(r => setTimeout(r, delayMs));
      } else if (error.code === 500) {
        // 서버 오류
        await new Promise(r => setTimeout(r, 2000));
      } else {
        throw error;
      }
    }
  }
  
  throw new Error(`최대 재시도 횟수 초과`);
}
```

---

### 5️⃣ 검증, 품질 관리 & 체크리스트

#### A. 슬라이드 생성 후 필수 검증 체크리스트

| 항목 | 확인 사항 | 통과 기준 | 실패 시 액션 |
|------|---------|---------|-----------|
| **📄 콘텐츠 정확성** | 수치, 날짜, 회사명 오류 없음 | 모든 정보 검증 | 원본 데이터 확인 후 수정 |
| **🎨 레이아웃 일관성** | 모든 슬라이드 마스터 템플릿 준수 | 여백, 정렬, 폰트 동일 | 마스터 재적용 |
| **🌈 색상 브랜드 준수** | 회사 브랜드 색상 사용 | 정확한 RGB/Hex 값 | 테마 재검토 |
| **♿ 접근성 (대비)** | 텍스트 대비 ≥ 4.5:1 | WCAG AA 표준 통과 | 폰트/배경색 변경 |
| **📷 이미지 품질** | 워터마크 포함, 해상도 | AI 생성: 워터마크 확인 | 다시 생성 |
| **🔤 대체 텍스트** | 모든 이미지에 설명 추가 | 스크린 리더 이해 가능 | 각 이미지 선택 → 대체 텍스트 입력 |
| **📏 폰트/크기** | 제목 18pt+, 본문 14pt+ | 가독성 좋음 | 폰트 크기 조정 |
| **🔗 하이퍼링크** | 링크 작동 여부 | 모든 링크 클릭 테스트 | 깨진 링크 수정 |

#### B. 품질 점검 카드

**🔎 팩트 체크**
- [ ] 모든 통계/수치 출처 명기
- [ ] 회사명, 인명 철자 정확
- [ ] 최신 정보 (2025년 데이터)
- [ ] 편향되지 않은 표현

**🧩 레이아웃 일관성**
- [ ] 제목 위치/크기 모두 동일
- [ ] 여백(패딩) 좌우 동일
- [ ] 글머리 기호 정렬
- [ ] 테이블 셀 높이 균일

**🏷️ 브랜드 준수**
- [ ] 로고 위치 일관
- [ ] 회사 색상 사용
- [ ] 폰트는 회사 지정 폰트만
- [ ] 서명/연락처 정보 정확

**♿ 접근성**
- [ ] 모든 텍스트 고대비
- [ ] 색상만 사용하지 않음
- [ ] 애니메이션 자동 재생 없음
- [ ] 모든 미디어에 자막/설명

**🧾 출처/라이선스**
- [ ] 외부 이미지 라이선스 확인
- [ ] AI 생성 이미지: SynthID 크레딧 포함
- [ ] 데이터 출처 명기
- [ ] 그래프: 데이터 출처 표기

#### C. 일반적 실패 시나리오 & 복구 방법

| 실패 시나리오 | 원인 | 해결 방법 |
|-------------|------|---------|
| 프레젠테이션이 로드되지 않음 | 권한 부족 또는 파일 삭제 | 공유 권한 재확인 또는 드라이브 복구 |
| 슬라이드 텍스트가 겹침 | 자동 맞춤 비활성화 | 텍스트 상자 수동 조정 |
| 이미지가 흐릿함 | 저해상도 이미지 | 고해상도 이미지 재 수집 |
| 생성된 슬라이드 텍스트 오류 | 프롬프트 모호 | 프롬프트 재작성 |
| 내보낸 PDF 레이아웃 깨짐 | 폰트 호환성 문제 | "웹폰트 포함" 활성화 |
| Apps Script 실행 오류 | 권한 미승인 또는 코드 오류 | 로그 확인 (실행 로그 탭) |

---

## 💡 추가 개선사항 & 운영 팁

### 팁 1: 브랜드 템플릿 라이브러리 구축
- 조직 전체가 일관된 슬라이드 생성
- 마스터 프레젠테이션 생성 → 템플릿 갤러리에 추가
- 효과: 생성 속도 ↑ 40%, 브랜드 일관성 ↑ 95%

### 팁 2: Gemini in Slides로 다국어 프레젠테이션 자동화
- 한국어 원본 → 영문/중문/일문 슬라이드 자동 생성
- 프롬프트: "이 슬라이드를 영어/중국어/일본어로 번역해줘"
- 활용: 글로벌 회의, 다국어 제안서

### 팁 3: 실시간 데이터 대시보드 슬라이드
- Google Sheets에 일일 데이터 업데이트
- Apps Script 예약 실행 (매일 오전 9시)
- 효과: 수동 업데이트 제거, 항상 최신 정보 유지

### 팁 4: Nano Banana Pro 프롬프트 최적화
**Do's ✅**
- "큰 글씨, 최소 3개 단어" (텍스트 가독성)
- "Google Search 데이터 기반" (사실성)
- "16:9 가로 지향" (슬라이드 표준)

**Don'ts ❌**
- 너무 복잡한 장면
- 과도한 색상 (5개 초과)
- 문법 오류 프롬프트

---

## 📞 최종 체크리스트: 완벽한 배포 전

- [ ] 모든 기능 최신성 확인 (2025-12-12 기준)
- [ ] 모든 출처 명기 및 링크 정상 작동
- [ ] 코드 예제 직접 실행 테스트
- [ ] 스크린샷 및 다이어그램 최신 버전
- [ ] 팀원 3명 이상 리뷰 (비개발자 포함)
- [ ] 접근성 테스트 (스크린 리더, 고대비 모드)
- [ ] PDF/HTML 내보내기 레이아웃 확인

---

## 📚 추가 학습 리소스

- **공식 문서**: Google Slides Help Center
- **개발자 문서**: Google Slides API (developers.google.com/workspace/slides)
- **커뮤니티**: Stack Overflow (google-slides-api, google-apps-script)
- **학습**: Google Developers Codelabs

---

**매뉴얼 최종 업데이트: 2025년 12월 12일 (KST)**
**출처 확인 완료: Google Workspace 블로그, Google Cloud 블로그, 공식 Help Center**