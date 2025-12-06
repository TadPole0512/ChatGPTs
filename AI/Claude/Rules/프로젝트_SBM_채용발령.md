# 🎯 프로젝트별 지침 - HR 채용발령 시스템 (v1.0)

## 🔧 프로젝트 지침 (HR 채용발령 시스템)


🎯 실행 규칙

📐 10가지 핵심 공식(변수만 해당)

| # | 공식 | 주요 변수 |
| -- | | |
| 1 | 천재적 통찰력 | GI = (관찰 × 연결 × 패턴 × 통합) / (가정 + 편견) |
| 2 | 다차원 | 5가지 차원: 시간-공간-추상화-인과관계-위계 |
| 3 | 창의적 연결 | 직접 - 간접 - 역설 - 은유 - 시스템 연결 |
| 4 | 문제 재정의 | 180° 뒤집기 - 스케일 이동 - 개념 이동 - 도메인 이동
| 5 | 혁신 솔루션 | 결합-차용-제약→우위-역발상-시스템 재설계
| 6 | 통찰력 증폭 | 5가지 이유 - 만약에 - 어떻게 할 수 있을까?
| 7 <사고의 진화> 학습-경험-성찰-교환-실패 학습
| 8 | 복잡성 해결 | 분해 → 관계 매핑 → 레버리지 포인트 |
| 9 | 직관적 도약 | (침묵 × 경험 × 신뢰) / (논리 × 합리화) |
| 10 | 통합적 지혜 | (지식 + 이해 + 지혜 + 연민 + 행동) × 겸손 × 윤리 |


### 1️⃣ 코드 수정/분석 시 필수 확인사항

```
✅ 사전 체크리스트
- [ ] 요구사항 번호 확인 (예: req-0181-01-hsg)
- [ ] 수정 대상 파일 식별 (JSP/JS 분리 여부)
- [ ] 기존 주석 패턴 유지 (/* ↓↓↓↓↓ ... ↑↑↑↑↑ */)
- [ ] 영향받는 Grid 식별 (masterGrid/multiColumn)
- [ ] 팝업 콜백 체인 확인 (f_popup_callback)
- [ ] 상태관리 필드 확인 (APPOINTMENT_YN, SEQ 등)
```

### 2️⃣ RealGrid 레거시 패턴

**필수 API 흐름**
```javascript
// 1. Grid 초기화 (gf_gridInit 래퍼 사용)
var grid_opt = { grid_id: '...', options: {...} };
masterGrid = gf_gridInit(grid_opt);
masterGridDP = masterGrid.getDataSource();

// 2. 이벤트 바인딩 순서
masterGrid.onCellButtonClicked  // 팝업 오픈
masterGrid.onEditRowChanged     // 셀 변경 후
masterGrid.onEditRowPasted      // 붙여넣기 후

// 3. 커스텀 함수 활용
gf_cellButtonClicked(grid, itemIndex, columnConfig, searchCondition)
gf_editCellPopup(grid, itemIndex, field, columnConfig, oldValue, newValue)
gf_pastePopup(grid, itemIndex, columnConfig)
```

**주의사항**
- `gf_*` 접두사 함수는 프로젝트 공통 유틸 → 시그니처 유지 필수
- `paramReturn` 함수: Grid별 검색조건 생성 중앙화
- `f_popup_callback`: 모든 팝업 결과의 단일 진입점

### 3️⃣ HR 도메인 규칙

**발령 상태 관리**
```javascript
// APPOINTMENT_YN: '0' = 발령대기, '1' = 발령적용
// 발령적용(='1') 시 행 전체 readOnly + 회색 처리
masterGrid.setCellStyleCallback(function(grid, item) {
  if (appointment_yn == '1') {
    ret.editable = false;
    ret.readOnly = true;
    ret.editor = '';
  }
  return ret;
});
```

**주민등록번호 검증**
- 형식: `NNNNNN-NNNNNNN` 또는 `NNNNNNNNNNNNN`
- 검증: 생년월일 유효성 + 체크섬 알고리즘
- 시점: `f_save` 전 모든 신규/수정 행 검증

**필수 필드 초기값**
```javascript
provider.setValue(row, 'COMM_CORPORATION_ID', gv_login_corporation_id);
provider.setValue(row, 'APPOINTMENT_YN', '0');
provider.setValue(row, 'APPOINTMENT_CODE', 'hr013010');
```

### 4️⃣ 팝업 구조 (부서/현장)

**기본 팝업 (주 소속)**
```javascript
var masterColumn = [
  { colId: 'dept_name', popup_code: 'pop_dept', ... },
  { colId: 'PROJECT_FIELD_NAME', popup_code: 'popup_hr_project', ... }
];
```

**겸직 팝업 (req-0181-01-hsg 이후 추가)**
```javascript
var multiColumn = [
  { colId: 'multi_dept_name', popup_code: 'pop_dept', ... },
  { colId: 'MULTI_PROJECT_FIELD_NAME', popup_code: 'POPUP_HR_PROJECT', ... }
];
```

**콜백 처리 원칙**
- `popup` 전역변수로 현재 팝업 식별
- `data` 객체의 키 이름 정확히 매핑 (`dept_code`, `PROJECT_CODE` 등)
- 양방향 필드 동시 업데이트 (코드 + 명칭)

### 5️⃣ AJAX/트랜잭션 패턴

**조회 (gf_gridSearch)**
```javascript
gf_gridSearch({
  gridView: masterGrid,
  param: { queryId: '...', v_*: ... },
  callback: function() {
    masterGrid.setRowStyleCallback(f_rowStyleCallback);
    // SEQ='1'인 행은 신규 상태로 변경
  }
});
```

**저장 (gf_gridSave)**
```javascript
var param = {
  gridView: masterGrid,
  queryId: 'hr.HR_RECRUIT_APPOINTMENT_PROC',
  function_name: 'f_save',
  callback: f_search
};
gf_gridSave(param);
```

**발령 적용/취소 (커스텀 AJAX)**
```javascript
// 1. 저장 여부 확인 (getAllStateRows)
// 2. 체크된 행 수집 (getCheckedItems)
// 3. ID 목록 쉼표 구분 문자열로 변환
// 4. POST 요청 → 성공 시 재조회
```

### 6️⃣ 디버깅/수정 가이드

**버그 수정 시 템플릿**
```javascript
/*  ↓↓↓↓↓ YYYY-MM-DD [작성자] req-XXXX-XX-XXX : [요구사항 설명] ↓↓↓↓↓  */
// 수정 코드
/*  ↑↑↑↑↑ YYYY-MM-DD [작성자] req-XXXX-XX-XXX : [요구사항 설명] ↑↑↑↑↑  */
```

**주석 원칙**
- 요구사항 번호 기반 추적 가능성 확보
- 변경 전후를 화살표로 명확히 구분
- 한글 설명 필수 (팀 내 소통 언어)

**테스트 체크리스트**
```
- [ ] 발령대기(='0') 상태에서만 수정 가능한가?
- [ ] 팝업 선택 후 코드+명칭 모두 채워지는가?
- [ ] 붙여넣기 시 팝업 재호출되는가?
- [ ] 주민등록번호 검증 통과하는가?
- [ ] 발령 적용 후 행이 readOnly로 변경되는가?
- [ ] 겸직 팝업도 주 소속과 동일하게 작동하는가?
```

### 7️⃣ 금지 패턴

**❌ 절대 하지 말 것**
```javascript
// 1. Grid 재생성 (초기화만 한 번)
masterGrid = new RealGrid.GridView(...); // ❌

// 2. 전역 변수 남발
var tempData = ...; // ❌ (함수 스코프 내 var 사용)

// 3. 콜백 체인 무시
f_save(); f_search(); // ❌ (콜백 파라미터 활용)

// 4. 하드코딩된 상수
if (status == '1') // ⚠️ (APPOINTMENT_YN 사용)
```

**✅ 권장 패턴**
```javascript
// 1. 기존 함수 재사용
gf_gridSearch / gf_gridSave / gf_formCombo

// 2. 중앙화된 설정
paramReturn / masterColumn / multiColumn

// 3. 콜백 기반 흐름
callback: function() { ... }

// 4. 상수 변수화
var APPOINTMENT_WAITING = '0';
var APPOINTMENT_APPLIED = '1';
```

---

## 📝 지침 활용 가이드

### 질문 시 포함할 정보
1. **요구사항 번호** (있는 경우)
2. **대상 화면/파일** (hr_recruit_appointment.jsp/js)
3. **현재 동작** vs **기대 동작**
4. **에러 메시지/콘솔 로그**
5. **수정 범위** (Grid만? 팝업도? 트랜잭션도?)

### 답변 시 제공 형식
```
🎯 요약 (1줄)
- 수정 파일: [파일명]
- 변경 유형: [신규/수정/삭제]

📋 변경 내역
[코드 블록 + 주석]

✅ 테스트 시나리오
1. ...
2. ...

⚠️ 주의사항
- ...
```

---

## 🔍 범용 지침과의 관계

| 영역 | 범용 지침 적용 | 프로젝트 지침 추가 |
|------|----------------|-------------------|
| **코드 품질** | ✅ 보안/성능/아키텍처 원칙 | ✅ 레거시 패턴 유지 |
| **RealGrid** | ✅ 기본 API/구조 | ✅ 커스텀 래퍼 함수 |
| **사고 프로세스** | ✅ 문제 해결 프레임워크 | ✅ HR 도메인 규칙 |
| **질문 처리** | ✅ 단계별 진행/검증 | ✅ 요구사항 번호 추적 |

**적용 우선순위**: 프로젝트 지침 > 범용 지침 (단, 보안/성능 원칙은 항상 준수)

---

## 📌 최종 체크리스트

```
코드 작성/분석 전
- [ ] 요구사항 번호 확인
- [ ] 영향 범위 식별 (Grid/팝업/트랜잭션)
- [ ] 기존 패턴 파악 (주석/함수명/변수명)

코드 작성 중
- [ ] gf_* 함수 재사용
- [ ] 주석 패턴 준수 (↓↓↓...↑↑↑)
- [ ] 전역 변수 최소화
- [ ] 발령 상태별 분기 처리

코드 완성 후
- [ ] 테스트 시나리오 실행
- [ ] 콘솔 에러 확인
- [ ] 주민등록번호 검증 통과
- [ ] 발령 적용/취소 동작 확인
- [ ] 겸직 팝업 동작 확인 (해당 시)
```

---
