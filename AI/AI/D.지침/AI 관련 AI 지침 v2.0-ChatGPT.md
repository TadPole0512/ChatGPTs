# **🗄️ DB 관련 AI 지침 v1.1 — ChatGPT 기반 + Claude 강점 흡수 (Windows · Python 3.9+ · VS Code/Jupyter)**

---

## **🧭 개요(Overview)**

* Overview

  * ▷ 목적

    * LLM이 데이터베이스를 **안전·정확·재현 가능**하게 조회·분석·요약하도록 하는 **엔드투엔드 실무 지침**
  * → 적용 범위

    * RDBMS(PostgreSQL/MySQL/SQL Server/SQLite), NoSQL(MongoDB), 벡터DB(PGVector/FAISS/Chroma)
    * BI 보조, 자연어→SQL, 로그 분석, 사내 지식 질의, 제품 내 “AI 질의” 기능

> **Key takeaway: “읽기 전용 → 스키마 축약 → SQL 초안 → 정적/동적 검증 → 제한 실행 → 결과 요약/시각화 → 감사로그” 순서 고정.**

---

## **👶 초보자 가이드(Claude식 친화적 설명 추가)**

* Overview

  * ▷ 배경

    * “LLM에게 바로 DB를 맡기면 위험하다.” 초보자는 **두 가지만** 기억: **읽기 전용**과 **LIMIT**.
* 10분 퀵 스타트(GUI 우선)

  1. **도구 설치**

     * VS Code, Python 3.9+, DB 클라이언트(SSMS, MySQL Workbench, pgAdmin, DBeaver)
  2. **읽기 전용 계정 준비**

     * DBA에게 `READONLY` 계정 요청 (DDL/DML 금지)
  3. **스키마 축약 보기**

     * 테이블 목록·주요 컬럼만 요약본 확보(ERD 또는 자동 스크립트)
  4. **질문을 명확하게**

     * 기간·필터·출력 컬럼을 한 줄로: “2025-09-01~2025-09-28, 제품별 매출 TOP10, 취소 제외”
  5. **LLM에게 프롬프트**

     * “DDL/DML 금지, LIMIT≤200, 모르면 ‘모른다’라고 말해.” 규칙을 꼭 같이 전달
  6. **생성 SQL을 검토**

     * 금지 키워드(ALTER/DROP/INSERT/UPDATE/DELETE/GRANT/REVOKE) 없는지, 기간/LIMIT 있는지
  7. **샘플 실행**

     * 스테이징/샌드박스에서 먼저 `EXPLAIN` → 본 DB **제한 실행**
  8. **요약/시각화**

     * 결과 200행 이내 표/간단 차트로 카드형 요약, 원본은 CSV 링크로 제공
* 자주 하는 실수 → 간단 해결

  * 기간 미지정 → **반드시** 날짜 범위 넣기
  * NULL/타임존 혼동 → `COALESCE`, `AT TIME ZONE` 명시
  * 컬럼 추측 → **스키마 요약 밖 엔티티 금지**

> **Key takeaway: “읽기 전용 + LIMIT + 기간”만 지켜도 큰 사고 대부분 방지.**

---

## **🧑‍🔧 역할별 맞춤 가이드(Architect/DBA/개발자)**

* Overview

  * ▷ 목적

    * 같은 지침이라도 **역할마다 버튼/체크리스트가 달라야** 현업이 빨라진다.

### 1) DB 아키텍트(설계/표준화)

* 해야 할 일

  * **허용 리스트 기반 정책**: `SELECT`만 허용, 금지 키워드/함수 목록 관리
  * **스키마 요약 파이프라인**: ERD→컬럼 통계→요약 텍스트→LLM 컨텍스트 자동화
  * **데이터 경계**: PII 마스킹 뷰, 뷰/머티리얼라이즈드 뷰로 질의 표준화
* 산출물(템플릿)

  * “LLM 시스템 프롬프트” 표준 YAML
  * “스키마 요약” 자동 생성 스크립트
  * “성능/비용 SLO” 대시보드 위젯 정의

### 2) DBA(운영/보안/성능)

* 해야 할 일

  * **READ ONLY 롤**/접속 IP 화이트리스트, `statement_timeout`, `work_mem` 상한
  * **감사 로그**: `prompt_hash, schema_hash, sql_text, rowcount, latency_ms, ts`
  * **성능 보호**: 대용량 테이블은 요약뷰 제공, `EXPLAIN`에서 Seq Scan 대량 탐지 시 차단/알림
* 점검표

  * [ ] 타임아웃 ≤ 20s, LIMIT ≤ 200 강제
  * [ ] DDL/DML 차단 규칙 동작
  * [ ] 주별 위반/차단 리포트 발행

### 3) 개발자(애플리케이션/자동화)

* 해야 할 일

  * **프롬프트-체인 버전 고정**(Git), 응답 메타에 버전/해시 삽입
  * **샌드박스→본DB** 2단계 실행, 실패 시 “수정 제안” 리턴
  * **캐시 전략**: `prompt_hash + schema_hash + args` 키로 결과 캐시(TTL)
* 코드 규칙

  * 반드시 **완전 실행형** 샘플, 예제 입력 2개 + 오류 케이스 1개 포함
  * 테스트: 날짜 경계/0행/NULL 비율 체크

> **Key takeaway: Architect=정책/표준, DBA=권한/성능, Dev=자동화/재현성.**

---

## **🖱️ GUI 도구 연계(SSMS / Workbench / pgAdmin / DBeaver)**

* Overview

  * ▷ 목적

    * “노코드/로우코드” 환경에서 **버튼 클릭**으로 안전장치를 켜고 끄는 방법 제시.
* 연결 공통 원칙

  * **읽기 전용 계정**으로 연결
  * **세션 옵션**: READ ONLY, 타임아웃, ROWS/LIMIT 미리보기 모드
* 도구별 설정 요령

  * **SSMS (SQL Server)**

    * 연결 속성 > Additional Connection Parameters:
      `ApplicationIntent=ReadOnly;Connect Timeout=20`
    * 퀵 스크립트: `SET TRANSACTION ISOLATION LEVEL SNAPSHOT;`
  * **MySQL Workbench**

    * Preferences > SQL Editor > DBMS connection keep-alive & SQL execution limit 설정
    * Safe Updates ON, `SELECT ... LIMIT 200` 스니펫 탬플릿 등록
  * **pgAdmin (PostgreSQL)**

    * File > Preferences > Query Tool > `Max rows` = 200, `Statement Timeout` = 20000 ms
    * “Explain” 버튼으로 **먼저 계획 확인 → 실행**
  * **DBeaver (멀티 DB)**

    * Connection settings > General > Read-only connection 체크
    * SQL Editor > Result Sets > Fetch size 200, `Execution timeout` 20s
* GUI 매크로(예시)

  * “안전 SELECT” 스니펫: `/* read-only */ SELECT {cols} FROM {table} WHERE {date_range} LIMIT 200;`

> **Key takeaway: GUI에서도 ‘Read-only + Timeout + Max rows’ 3콤보를 기본값으로.**

---

## **📈 단계별 학습 곡선(기초→중급→고급)**

* Overview

  * ▷ 목적

    * 학습/도입을 **3단계로 쪼개** 실패 확률을 낮춤.
* 단계별 적용

  * **기초**

    * 목표: 안전 장치 이해·적용
    * 과제: ① 스키마 요약 생성 ② LLM에 안전 규칙 전달 ③ LIMIT/기간 포함 쿼리
    * 합격 기준: 금지 키워드 0건, LIMIT/기간 100% 충족
  * **중급**

    * 목표: 성능·의미 검증 자동화
    * 과제: ① `EXPLAIN` 비용 기준 차단 ② 샌드박스→본DB 2단계 ③ 결과 통계로 이상탐지
    * 합격 기준: p95 지연 ≤ 2s, 의미 테스트 90%+
  * **고급**

    * 목표: RAG/요약뷰·캐시·대시보드
    * 과제: ① 뷰 매핑 기반 질의 ② 결과 캐시 ③ 운영 대시보드 구축
    * 합격 기준: 비용 30%↓, 위반율 0.5%↓ 유지

> **Key takeaway: ‘안전 → 검증 → 최적화’ 순서로 난이도를 올린다.**

---

## **🧱 기반 원칙(Policies)**

* 안전: `READ ONLY` 기본, DDL/DML 차단, 타임아웃·행 제한
* 정확: 스키마 요약 주입, **few-shot** 예시/테스트 케이스로 자체 검증 루프
* 재현: 프롬프트·스키마·SQL·결과 샘플 **감사로그**
* 성능: 인덱스/샘플링/페이징/캐시/`EXPLAIN` 확인
* UX: **카드/표/체크리스트** 우선, 코드/로그는 접기

> **Key takeaway: “허용 리스트 + 검증 루프 + 감사 로그”는 비가역 규칙.**

---

## **🧠 프롬프트 표준(Claude의 설명 친화성 일부 흡수)**

* 시스템 프롬프트(요지)

  * 역할: **DB 안전 질의 보조원**
  * 규칙: DDL/DML 금지, LIMIT≤200, 20s 가정, 스키마 밖 추정 금지
  * 출력:

    1. SQL(단일 코드블록)
    2. 검증 체크리스트(근거 포함)
    3. 예상 결과 컬럼/타입
    4. **초보자 설명 2줄**(용어 풀어서)
* 사용자 프롬프트(요지)

  * “질문/기간/필터/출력 컬럼 + 스키마 요약 + 예시 쿼리 + 제약(LIMIT/Timeout/Read-only)”

> **Key takeaway: “정답”만이 아니라 “왜 이런 쿼리인지” **초보자 설명**을 붙인다.**

---

## **⚙️ 실행 파이프라인(완전 실행형 예시 · PostgreSQL)**

```python
# pip install sqlalchemy psycopg2-binary pandas
# run_safe_sql.py
import os, re, json, time, hashlib
import pandas as pd
from sqlalchemy import create_engine, text

ALLOWED = re.compile(r"^\s*SELECT\b", re.I|re.S)
FORBIDDEN = re.compile(r"\b(INSERT|UPDATE|DELETE|ALTER|DROP|TRUNCATE|GRANT|REVOKE|CREATE)\b", re.I)

def _h(s:str)->str: return hashlib.sha256(s.encode()).hexdigest()[:16]

def validate_sql(sql:str):
    if not ALLOWED.search(sql): raise ValueError("Only SELECT is allowed")
    if FORBIDDEN.search(sql):   raise ValueError("DDL/DML forbidden")
    m = re.search(r"limit\s+(\d+)", sql, re.I)
    if not m or int(m.group(1))>200: raise ValueError("LIMIT ≤ 200 required")

def connect_readonly():
    url = os.getenv("PG_URL_READONLY")  # e.g. postgresql+psycopg2://ro:***@host/db
    return create_engine(url, connect_args={"options":"-c statement_timeout=20000"}).begin()

def run_sql(prompt:str, schema_summary:str, sql:str, out_csv="result.csv"):
    validate_sql(sql)
    t0=time.time()
    with connect_readonly() as conn:
        conn.execute(text("SET TRANSACTION READ ONLY;"))
        df = pd.read_sql(text(sql), conn)
    ms=int((time.time()-t0)*1000)
    df.to_csv(out_csv, index=False, encoding="utf-8")
    audit = {
        "prompt_hash":_h(prompt),
        "schema_hash":_h(schema_summary),
        "sql":sql, "rowcount":len(df), "latency_ms":ms, "ts":pd.Timestamp.utcnow().isoformat()
    }
    with open("audit_log.jsonl","a",encoding="utf-8") as f: f.write(json.dumps(audit,ensure_ascii=False)+"\n")
    return df, ms

if __name__=="__main__":
    PROMPT="2025-09-01~2025-09-28 카테고리별 매출 TOP10"
    SCHEMA="tables: orders(...), order_items(...), products(...); notes: order_ts=UTC"
    SQL="""SELECT p.category, SUM(oi.qty*oi.price)-SUM(o.vat) AS net_sales
             FROM orders o JOIN order_items oi USING(order_id) JOIN products p USING(product_id)
            WHERE o.status!='CANCELLED'
              AND o.order_ts >= '2025-09-01' AND o.order_ts < '2025-09-29'
            GROUP BY 1 ORDER BY 2 DESC LIMIT 10;"""
    df, latency = run_sql(PROMPT, SCHEMA, SQL)
    print(df.head().to_markdown(index=False)); print("latency(ms)=", latency)
```

> **Note:** 운영에서는 CSV/Parquet 저장 + BI 연동, 위젯으로 p95 지연/행수/차단건 노출.

---

## **🔍 검증 루프(정적/동적/의미)**

* 정적: 금지 키워드, 스키마 밖 엔티티, LIMIT/기간 확인
* 동적: `EXPLAIN` 비용 과다/대량 Seq Scan 탐지 → 개선 프롬프트 유도
* 의미: 날짜 경계(월초/월말)/0행/NULL 비율 테스트, 결과 통계로 이상 탐지

> **Key takeaway: 검증 3단계 없이는 본 DB 실행 금지.**

---

## **📦 RAG/뷰/캐시(중급~고급)**

* RAG: 데이터 딕셔너리/뷰 설명서를 임베딩, **질문→뷰 매핑** 후 SQL 최소화
* 요약뷰: 자주 쓰는 집계는 뷰/머티리얼라이즈드 뷰
* 캐시: `prompt_hash + schema_hash + args` 키, TTL 기반

> **Key takeaway: “질문 재작성 + 재순위화 + 근거 인용”만으로 품질이 크게 오른다.**

---

## **✅ Checklist (Numbered)**

1. READ ONLY 연결과 타임아웃(≤20s), LIMIT(≤200) 강제
2. 스키마 요약 최신화 및 프롬프트 주입
3. 금지 키워드/허용 리스트 필터 작동
4. `EXPLAIN`으로 샌드박스 시뮬 후 본 DB 제한 실행
5. 결과 의미 검증(경계/0행/NULL 비율) 통과
6. 감사로그(`prompt_hash/schema_hash/sql/rowcount/latency/ts`) 기록
7. GUI 도구에서 Read-only/Max rows/Timeout 프리셋 적용
8. 캐시·요약뷰·대시보드로 비용/지연 최적화
9. 프롬프트·체인 버전 고정 및 변경 로그 남김

또는

Check the environment
Apply settings
Perform validation

---

## **부록 A. 프롬프트 템플릿(즉시 사용)**

* **정확 답변(초보자 설명 포함)**

```
역할: 너는 DB 안전 질의 보조원.
규칙: DDL/DML 금지, LIMIT≤200, 20s, 스키마 밖 추정 금지.
출력: [SQL] + [검증 포인트(근거)] + [예상 컬럼/타입] + [초보자 설명 2줄].

[질문] 2025-09-01~2025-09-28 기간, 취소 제외, 카테고리별 매출 TOP10
[스키마 요약] ...
[예시] ...
```

* **RAG(근거 인용)**

```
목표: 출처 인용 답변
절차: 질문 재작성 → 검색쿼리 3개 → Top-k 스니펫 요약 → 출처 링크
출력: 카드요약(한줄 결론) + 근거표(스니펫/링크) + 한계/추가질문
```

---

## **부록 B. 도구/환경**

| 범주         | 권장 도구           | 설정 핵심                                             |
| ---------- | --------------- | ------------------------------------------------- |
| SQL Server | SSMS            | ReadOnly, Connect Timeout=20, Snapshot Isolation  |
| MySQL      | Workbench       | Safe Updates, LIMIT 템플릿, Execution timeout        |
| PostgreSQL | pgAdmin         | Max rows 200, Statement Timeout 20s, Explain 선실행  |
| 멀티 DB      | DBeaver         | Read-only connection, Fetch size 200, Timeout 20s |
| Python     | VS Code/Jupyter | `sqlalchemy`, `psycopg2/pymysql/pyodbc`, `pandas` |

---

## **끝맺음**

* 본 지침은 **ChatGPT 기반의 체계**에 **Claude식 친화적 설명/역할별 플레이북/GUI 연동/단계별 학습곡선**을 결합했다.
* 그대로 가져다 **즉시 적용**하고, 팀 표준에 맞춰 버전업하라.
