# 📊 리얼그리드(RealGrid) 사용용 “정확한 답변” 사전 지침 v1.0

> 목적: RealGrid 사용법을 물을 때 **한 번에 정확한 대답**을 받기 위한 **사전 브리핑 표준 + 체크리스트 + 최소 실행 예시** 제공

---

## **A. 원칙 & 프레이밍**

* Overview

  * ▷ 배경

    * RealGrid는 `DataProvider ↔ GridView` 구조, 수많은 옵션/이벤트, 라이선스 및 버전 이슈로 **질문이 쉽게 모호**해진다.
  * ▷ 목표

    * 질문 전에 **환경·버전·데이터·기능 요구**를 표준 템플릿에 고정하고, **미니 재현 코드**를 함께 제출한다.
    * 핵심 API/순서(Provider 생성 → GridView 생성 → setDataSource → fields/columns → 옵션/콜백 → 데이터 주입) 준수. ([docs.realgrid.com][1])

> **Key takeaway: 가장 중요한 건 “사전 브리핑 + 재현 코드 + 설정 순서 고정”이다.**

---

## **B. 사전 브리핑 템플릿 (복붙해서 채우기)**

* How to use

  * ▷ 준비

    * → 아래 템플릿을 **질문 맨 위**에 붙여넣고 빈칸을 채운다.
  * ▷ 절차

    * → 모호한 값은 `TBD-날짜`로 표기, 대안/제약도 함께 기록

```md
# [RealGrid Pre-brief]

1) 목적/화면
- 뷰 타입: (Flat/Tree)  행 수: (평균/최대)  초기 로드시: (페이지네이션/무한스크롤/전체)
- 핵심 기능: (편집/그룹핑/고정열/요약/엑셀 내보내기/필터/정렬/컨텍스트메뉴 등)

2) 기술스택/버전
- 프레임워크: (Vanilla/React/Vue/Angular)
- RealGrid 버전: (예: 2.8.x)  로딩 방식: (CDN/NPM)
- 라이선스 적용: (script lic 파일 / setLicenseKey 사용)  [키 보관 위치]

3) 데이터 계약
- 데이터 소스: (REST/로컬/웹소켓)  인코딩/로케일: (ko-KR/UTC 등)
- 스키마: fields[] (fieldName, dataType), columns[] (name, fieldName, header.text, width…)
- 키 필드: (id)  편집 규칙: (셀/행, 검증, 필수값)

4) 상호작용/서버통신
- 정렬/필터 처리: (클라이언트/서버 위임)
- CRUD: (로컬 편집 → 배치 전송 / 즉시 전송)  트랜잭션/실패 롤백 정책

5) UX/정책
- 포맷팅: 숫자/날짜/소수점 자리수  단축키/접근성  스크롤/셀 이동 정책
- 엑셀 내보내기/가져오기: (파일명/스타일 포함여부/서버 업로드)  *jszip 준비 여부*

6) 성능/제약
- 목표: p95 렌더 X ms, 초기 로드 X ms  최대 행/열 수  가상 스크롤 전략
- 메모리/CPU 제한, 모바일 대응

7) 재현 코드/데이터
- 최소 재현 HTML/JS(또는 React/Vue) 코드 + 샘플 데이터 50행
- 현재 동작/문제 설명(스크린샷/콘솔 로그)
```

> **Key takeaway: “버전·라이선스·로드방식·데이터계약·서버위임·성능”을 고정하면 답변이 빨라진다.**

---

## **C. 결정 트리 (질문 카테고리 3갈래)**

* Overview

  * ▷ 분류

    * A) **기본 사용/초기 세팅**: 설치·라이선스·Provider/GridView 연결·fields/columns 순서
    * B) **데이터/상호작용**: 클라 vs 서버 정렬/필터/페이지, CRUD·검증, 이벤트
    * C) **출력/연동/성능**: 엑셀/리포트, 대용량 최적화, Tree/Grouping
* How to use

  * ▷ 절차

    * → 자신의 질문이 어느 갈래인지 먼저 명시하고, B 섹션 템플릿에 맞춰 증빙(코드/데이터) 첨부

> **Key takeaway: 질문을 “설치/기본” vs “데이터/이벤트” vs “출력/성능”으로 먼저 라벨링.**

---

## **D. 헷갈리기 쉬운 핵심 사항 정리 (공식 문서 근거 포함)**

* Overview

  * ▷ 객체/순서

    * **LocalDataProvider**(데이터)와 **GridView**(화면)를 만들고 `gridView.setDataSource(provider)`로 연결 → fields/columns → 옵션/콜백 → `provider.setRows(data)` 순서 권장. ([docs.realgrid.com][1])
  * ▷ 설치/라이선스

    * NPM/CDN/다운로드 모두 가능, **라이선스 필수**. 스크립트 라이선스 파일 또는 `RealGrid.setLicenseKey()` 사용. ([docs.realgrid.com][1])
  * ▷ 정렬/필터

    * 정렬: `gridView.sortingOptions.enabled` / 멀티 정렬 스타일(`exclusive/inclusive` 등). ([docs.realgrid.com][2])
    * 필터: `gridView.setColumnFilters()`, `FilteringOptions.enabled` 등으로 컬럼 단위 필터 구성/토글/숨김. ([docs.realgrid.com][3])
  * ▷ 엑셀 내보내기

    * `gridView.exportGrid({ type:"excel", ... })` 사용, **jszip** 필요(로컬/원격 방식 지원). ([docs.realgrid.com][4])

> **Key takeaway: “Provider↔GridView 연결”과 “정렬/필터/엑셀 핵심 API”를 먼저 고정하라.**

---

## **E. 최소 실행 예시 (Vanilla JS / React) — 그대로 붙여 넣어 재현**

* How to use

  * ▷ 준비

    * → **CDN 방식**: 스타일/스크립트 포함(버전 또는 latest), 라이선스 설정 후 예시 코드 실행. ([docs.realgrid.com][1])

### 1) Vanilla HTML + JS (CDN)

```html
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <!-- RealGrid CSS & JS (버전 고정 예시) -->
  <link href="https://cdn.wooritech.com/realgrid/realgrid.2.8.3/realgrid-style.css" rel="stylesheet"/>
  <script src="https://cdn.wooritech.com/realgrid/realgrid.2.8.3/realgrid.2.8.3.min.js"></script>
  <!-- 엑셀 내보내기용 jszip -->
  <script src="https://cdn.jsdelivr.net/npm/jszip@3.10.1/dist/jszip.min.js"></script>
  <style> #grid { width:100%; height:440px; } </style>
</head>
<body>
  <div id="grid"></div>
  <button id="btnExport">엑셀 내보내기</button>

  <script>
    // 1) 라이선스 (필수)
    RealGrid.setLicenseKey("YOUR_LICENSE_KEY"); // setLicenseKey 또는 lic 스크립트 방식 사용

    // 2) Provider & GridView 생성 + 연결
    const provider = new RealGrid.LocalDataProvider();
    const gridView = new RealGrid.GridView("grid");
    gridView.setDataSource(provider); // 핵심 연결

    // 3) 스키마 정의
    provider.setFields([
      { fieldName: "KorName", dataType: "text" },
      { fieldName: "Gender",  dataType: "text" },
      { fieldName: "Age",     dataType: "number" },
      { fieldName: "Phone",   dataType: "text" }
    ]);
    gridView.setColumns([
      { name: "KorName", fieldName: "KorName", width: 80, header: { text: "이름" } },
      { name: "Gender",  fieldName: "Gender",  width: 60, header: { text: "성별" } },
      { name: "Age",     fieldName: "Age",     width: 60, header: { text: "나이" } },
      { name: "Phone",   fieldName: "Phone",   width: 140, header: { text: "전화번호" } }
    ]);

    // 4) 옵션 (정렬/필터 예시)
    gridView.sortingOptions.enabled = true;         // 정렬 허용
    gridView.sortingOptions.style   = "exclusive";  // 마지막 클릭 기준
    gridView.filteringOptions = { enabled: true };  // 필터 활성화

    // 5) 데이터 주입
    provider.setRows([
      { KorName:"박영호", Gender:"남", Age:71, Phone:"(025)6563-2802" },
      { KorName:"조일형", Gender:"남", Age:62, Phone:"(093)8809-8696" },
      { KorName:"김덕중", Gender:"여", Age:53, Phone:"(064)5483-6874" },
      { KorName:"국영석", Gender:"남", Age:63, Phone:"(044)7055-3032" }
    ]);

    // 6) 엑셀 내보내기 (jszip 필요)
    document.getElementById("btnExport").onclick = () => {
      gridView.exportGrid({
        type: "excel",
        target: "local",
        fileName: "grid.xlsx",
        showProgress: true
      });
    };
  </script>
</body>
</html>
```

* 설정 순서/필드·컬럼 구조/라이선스/엑셀 API는 공식 문서 흐름과 일치. ([docs.realgrid.com][1])

### 2) React 함수 컴포넌트 (NPM)

```bash
npm i realgrid jszip
```

```tsx
import { useEffect, useRef } from "react";
import RealGrid from "realgrid";
import JSZip from "jszip"; // 번들러가 필요시 참조

export default function RealGridExample() {
  const divRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    RealGrid.setLicenseKey("YOUR_LICENSE_KEY");

    // 컨테이너 참조로 생성
    const provider = new RealGrid.LocalDataProvider();
    const gridView = new RealGrid.GridView(divRef.current!);
    gridView.setDataSource(provider);

    provider.setFields([
      { fieldName: "id", dataType: "text" },
      { fieldName: "price", dataType: "number" },
      { fieldName: "createdAt", dataType: "datetime" }
    ]);
    gridView.setColumns([
      { name: "id", fieldName: "id", header: { text: "ID" }, width: 120 },
      { name: "price", fieldName: "price", header: { text: "가격" }, width: 100, editor: { type: "number" } },
      { name: "createdAt", fieldName: "createdAt", header: { text: "생성시각" }, width: 160 }
    ]);

    gridView.sortingOptions.enabled = true;
    gridView.filteringOptions = { enabled: true };

    provider.setRows([
      { id: "A-100", price: 12000, createdAt: "2025-09-01T12:00:00Z" },
      { id: "B-200", price: 9900,  createdAt: "2025-09-02T08:30:00Z" }
    ]);

    // 언마운트 시 리소스 해제
    return () => {
      gridView.destroy();
      provider.clearRows();
    };
  }, []);

  return <div ref={divRef} style={{ width: "100%", height: 440 }} />;
}
```

* NPM 설치/라이선스/Provider↔GridView 연결·설정 순서는 Quick Start 권고 순서에 부합. ([docs.realgrid.com][1])

> **Note:** 공식 문서도 React/Vue용 래퍼 사용 가이드를 언급한다(필요 시 지원팀 문의). ([docs.realgrid.com][1])

> **Key takeaway:** “CDN 한 파일 + React 한 컴포넌트”로 **누구나 재현 가능한 최소 예시**를 항상 동봉하자.

---

## **F. 서버 위임(정렬/필터/페이징) 기준**

* Overview

  * ▷ 왜 필요?

    * 대량 데이터에서 클라이언트만으로 필터/정렬/페이징을 처리하면 성능 문제가 생길 수 있다.
* How to use

  * ▷ 절차

    * → **규모 기준**(예: 5만 행↑)에서 서버 위임 고려
    * → 필드명/연산자 매핑표(컬럼→API 파라미터) 정의
    * → 그리드 이벤트(필터/정렬 변경) → 서버 쿼리 재호출 → `provider.fillJsonData()` 또는 `setRows()` 반영
* 참고: RealGrid의 정렬/필터 API 토글·스타일·조건식 기반 필터 제공(서버 위임 시 상태만 서버 파라미터로 전달). ([docs.realgrid.com][2])

> **Key takeaway:** “그리드 상태를 서버 파라미터로 번역”하는 표를 먼저 만들어라.

---

## **G. 출력/리포트·엑셀 전략**

* How to use

  * ▷ 준비

    * → **jszip 포함** 여부 확인, 파일명·시트명·스타일 포함 설정
    * → 원격 내보내기(서버에서 파일 생성/다운로드) 필요 시 `target:"remote", url` 사용
  * ▷ 절차

    * → 버튼/메뉴에서 `gridView.exportGrid({ type:'excel', ... })` 호출
    * → 대용량/컬럼 병합/그룹 요약 등은 문서의 세부 옵션 참고
* 공식 가이드: 엑셀 내보내기/원격 내보내기/옵션 모델/샘플 코드 제공. ([docs.realgrid.com][4])

> **Key takeaway:** 엑셀은 “jszip + exportGrid 옵션”이 핵심. 원격 방식도 지원한다.

---

## **H. 문제 재현·디버깅 패키지 규격**

* Overview

  * ▷ 패키지 구성

    * `index.html`(또는 React 단일 컴포넌트), `data.json`(50~200행), **정확한 버전/라이선스 방식**, 재현 스텝
* How to use

  * ▷ 절차

    * → “1. 열 추가 클릭 → 2. 편집 → 3. 엔터 → 4. 포커스 이동 시 오류 발생” 같은 **정확한 단계 기록**
    * → 콘솔 로그/네트워크 탭 캡처 포함

> **Key takeaway:** “한 파일 + 작은 데이터 + 단계 서술”이 최고의 버그 리포트다.

---

## **I. RealGrid 질문 프롬프트 템플릿**

```md
[역할] 당신은 RealGrid 전문가다.
[목표] 내가 첨부한 재현 코드/데이터로 문제를 재현하고, 수정 패치를 제시하라.
[환경] 프레임워크(React/Vanilla), RealGrid 2.x, 로딩방식(CDN/NPM), 라이선스 방식
[데이터계약] fields/columns 정의/키필드/포맷/검증 규칙
[상호작용] 정렬/필터/페이징 서버 위임 여부, CRUD 정책
[출력] 엑셀 내보내기 요구(파일명/스타일/원격여부)
[제약] 성능 목표(p95), 접근성/국제화, 모바일 대응
[산출물] 1) 원인 분석 2) 수정 코드(diff) 3) 부작용/대안 4) 체크리스트
```

> **Key takeaway:** “역할·환경·데이터·상호작용·출력·제약·산출물” 7요소를 채우면 정답률이 급상승한다.

---

## **J. GUI 절차 요약 (최초 세팅)**

* How to use

  * ▷ 준비

    * → DOM 컨테이너 생성 → CSS/JS 로드(NPM/CDN) → 라이선스 적용
  * ▷ 절차

    * → Step 1: `LocalDataProvider` & `GridView` 생성 → `setDataSource`
    * → Step 2: `fields[]`, `columns[]` 정의
    * → Step 3: `sortingOptions/filteringOptions` 등 옵션/콜백 설정
    * → Step 4: `setRows()`로 데이터 바인딩
    * → Step 5: 엑셀 버튼/메뉴 연결
    * (공식 Quick Start와 권장 순서 동일) ([docs.realgrid.com][1])

> **Note:** 정렬/필터 UI는 옵션 ON만으로 헤더에 핸들이 표시/동작한다(필터는 setColumnFilters로 수동 구성도 가능). ([docs.realgrid.com][2])

---

## **Checklist (Numbered)**

1. **버전/라이선스/로딩방식**(NPM or CDN) 명시 및 적용 확인. ([docs.realgrid.com][1])
2. **Provider↔GridView 연결**(`setDataSource`) 후 **fields/columns** 정의. ([docs.realgrid.com][1])
3. **정렬/필터 옵션** 및 정책(클라/서버)을 결정. ([docs.realgrid.com][2])
4. **데이터 주입**(`setRows`)과 **키 필드/검증** 규칙 확인. ([docs.realgrid.com][1])
5. **엑셀 내보내기**: jszip 포함, `exportGrid` 옵션/파일명/원격 여부 결정. ([docs.realgrid.com][4])
6. **성능/UX 목표**(행·열·지연·모바일)와 **에러 재현 코드** 동봉.
7. **콘솔/네트워크 로그** 및 스크린샷 첨부.

—
필요하면 위 **Pre-brief + 최소 실행 예시(HTML/React)**를 당신 환경(React/Vue/Vanilla, 서버 위임 유무, 엑셀 정책)에 맞게 **즉시 커스터마이즈**해 줄게. 원하는 프레임워크/RealGrid 버전만 알려줘!

[1]: https://docs.realgrid.com/en/tutorial/realgrid-quickstart "Overview - RealGrid"
[2]: https://docs.realgrid.com/en/guides/column/column-sorting "Sorting data - RealGrid"
[3]: https://docs.realgrid.com/en/guides/column/column-filtering "Data Filtering - RealGrid"
[4]: https://docs.realgrid.com/en/guides/excels/excel-export "excel export - RealGrid"
