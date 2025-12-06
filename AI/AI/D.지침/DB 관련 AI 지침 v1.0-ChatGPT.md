# 🗄️ DB 관련 AI 지침 v1.0

> 목적: LLM이 데이터베이스를 **안전하고 정확하며 재현 가능하게** 조회·분석·요약하도록 하는 실무 지침. (Windows · Python 3.9+ · VS Code/Jupyter 기준)

---

## 🧭 개요(Overview)

* ▷ 배경

  * 실무에서 LLM이 SQL을 생성·실행할 때 **정확도 저하(환각)**, **보안 리스크**, **성능 저하**가 빈번.
  * 본 지침은 **스키마 이해 → 질의 생성 → 검증 → 실행 → 요약/시각화**를 **안전장치와 함께** 단계화.
* → 적용 범위

  * RDBMS(PostgreSQL/MySQL/SQL Server/SQLite), NoSQL(MongoDB), 벡터DB(PGVector/FAISS/Chroma)
  * BI 보조, 자연어→SQL, 데이터 품질 점검, 로그 분석, 제품 내 “AI 질의” 기능

> **핵심 한 줄:** “항상 읽기 전용 → 스키마 축약 → SQL 초안 → 정적 분석/시뮬 → 제한 실행 → 결과 검증 → 요약/시각화” 순서를 지켜라.

---

## 🧱 A. 기반 원칙(Policies)

* **안전 우선:** `READ ONLY` 기본, DDL/DML 차단(허용 리스트 방식). 트랜잭션 강제, 타임아웃·행 제한.
* **정확성:** 스키마 요약을 LLM에 제공하고, **few-shot** 예시와 **테스트 케이스**로 자체 검증 루프.
* **재현성:** 모든 프롬프트·스키마 스냅샷·실행 SQL·결과 샘플을 **감사 로그**에 남김.
* **성능:** 인덱스·샘플링·페이징·캐시·Explain Plan 확인을 표준화.
* **보안/개인정보:** 최소 권한, PII 마스킹, 테이블·컬럼 레벨 접근 제어.
* **UX:** 항상 **GUI형 카드/표/체크리스트**로 결과 요약, 코드/로그는 접기(accordion).

> **Key takeaway:** “허용 리스트 + 검증 루프 + 감사 로그” 3종 세트를 기본값으로.

---

## 🧩 B. 시스템 구성(Reference Architecture)

* ▷ 준비물

  * Python 3.9+, `SQLAlchemy`, `psycopg2`/`pymysql`/`pyodbc`, `pandas`, `matplotlib`, 선택: `pgvector`, `openai/anthropic/hf` SDK
* → 흐름(카드형)

  * ① **스키마 수집/축약 카드**: DB→ER/컬럼 통계→LLM 컨텍스트 빌드
  * ② **프롬프트 카드**: 시스템 규칙 + 사용자 질문 + 스키마 요약 + Few-shot
  * ③ **SQL 생성·정적검사 카드**: 금지 키워드, 조인 키 유효성, LIMIT 강제
  * ④ **샌드박스 시뮬 카드**: `EXPLAIN`/`EXPLAIN ANALYZE`(샘플 DB)
  * ⑤ **제한 실행 카드**: READ ONLY 연결, 타임아웃, 최대 행수
  * ⑥ **결과 해석/시각화 카드**: 표/간단 차트, 의미 요약
  * ⑦ **감사 로그 카드**: 프롬프트, 스키마 해시, SQL, 지표 기록

> **Note:** ①~⑦은 각각 실패 시 중단·수정 제안(Stop-the-world) 절차 포함.

---

## 🧠 C. 프롬프트 디자인(LLM Guardrails)

* ▷ 시스템 프롬프트(템플릿)

  ```
  역할: 당신은 "DB 안전 질의 보조원"이다.
  규칙:
  - DDL/DML 금지(ALTER, DROP, INSERT, UPDATE, DELETE, TRUNCATE 금지).
  - 반드시 LIMIT 200 이하 포함. 시간 제한 20s 가정, 인덱스 활용 권고.
  - 모르는 컬럼/테이블 추정 금지. 스키마 요약 밖 엔티티 사용 금지.
  - 출력 형식:
    1) SQL(코드블록 단일)
    2) 자연어 검증 체크리스트(근거 포함)
    3) 예상 결과 컬럼/타입
  ```
* → 사용자 프롬프트(템플릿)

  ```
  질문: {자연어 질문}
  기간: {예: 2025-07-01~2025-09-01}
  스키마 요약: {자동 주입}
  예시 쿼리: {few-shot N개}
  제약: LIMIT<=200, 20s, 읽기 전용
  요구 출력: [SQL] + [검증 포인트] + [예상 컬럼]
  쿼리 출력 : Claude_Knauf-SQL-Style.md을 반드시 지킬 것
  ```
* → Few-shot 예시(요약)

  * “지난달 상품별 매출 TOP10” 질문 → 그룹·정렬·LIMIT, 널 처리, 타임존 명시
  * “신규 vs 복귀 사용자 Cohort” → 윈도우 함수, 파티션 키, 날짜 버킷

> **핵심:** 스키마 밖 추론 금지 + 금지 키워드 + 형식 강제.

---

## 🔒 D. 보안/권한/감사

* ▷ 최소 권한

  * 전용 `READONLY` 롤, `SET TRANSACTION READ ONLY;` 강제, 뷰/머티리얼라이즈드 뷰로 노출 최소화.
* → 쿼리 허용 리스트

  * 허용 문 패턴 정규식 + 금지 키워드(DDL/DML/권한/함수) 필터.
* → 개인정보 보호

  * PII 컬럼(`email`, `phone`, `ssn`, `address`)은 뷰에서 해시/마스킹, 샘플링(5%) 제공.
* → 감사/로깅

  * `prompt_hash, schema_hash, sql_text, plan_digest, rowcount, latency_ms, user_id, ts` 저장.

> **Key takeaway:** 보안은 “권한 ↓, 노출 ↓, 기록 ↑”로 설계.

---

## ⚙️ E. 실행 파이프라인(코드 전체 예시 · PostgreSQL)

```python
# Python 3.9+, pip install sqlalchemy psycopg2-binary pandas
import os, re, json, hashlib, time
from contextlib import contextmanager
import pandas as pd
from sqlalchemy import create_engine, text

ALLOWED = re.compile(r"^\s*SELECT\b", re.IGNORECASE | re.DOTALL)
FORBIDDEN = re.compile(r"\b(INSERT|UPDATE|DELETE|ALTER|DROP|TRUNCATE|GRANT|REVOKE|CREATE)\b", re.IGNORECASE)

def hash_text(s:str)->str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()[:16]

def validate_sql(sql:str):
    if not ALLOWED.search(sql): raise ValueError("Only SELECT allowed")
    if FORBIDDEN.search(sql): raise ValueError("DDL/DML forbidden")
    if "limit" not in sql.lower(): raise ValueError("LIMIT <= 200 required")
    m = re.search(r"limit\s+(\d+)", sql, re.IGNORECASE)
    if not m or int(m.group(1))>200: raise ValueError("LIMIT must be ≤ 200")

@contextmanager
def readonly_engine():
    # READONLY 전용 계정 사용
    url = os.getenv("PG_URL_READONLY")  # e.g. postgresql+psycopg2://ro:***@host:5432/db
    eng = create_engine(url, connect_args={"options": "-c statement_timeout=20000"})
    try:
        with eng.begin() as conn:
            conn.execute(text("SET TRANSACTION READ ONLY;"))
            yield conn
    finally:
        eng.dispose()

def run_sql(sql:str)->pd.DataFrame:
    validate_sql(sql)
    t0 = time.time()
    with readonly_engine() as conn:
        df = pd.read_sql(text(sql), conn)
    latency = int((time.time()-t0)*1000)
    return df, latency

def log_audit(prompt:str, schema:str, sql:str, latency:int, rows:int):
    rec = {
        "prompt_hash": hash_text(prompt),
        "schema_hash": hash_text(schema),
        "sql": sql, "latency_ms": latency, "rowcount": rows, "ts": pd.Timestamp.utcnow().isoformat()
    }
    with open("audit_log.jsonl", "a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=False)+"\n")

# === 사용 예시 ===
PROMPT = "지난달 카테고리별 매출 TOP10 알려줘 (VAT 제외)."
SCHEMA_SUMMARY = """
tables:
  orders(order_id, user_id, order_ts, amount, vat, status)
  order_items(order_id, product_id, qty, price)
  products(product_id, category, brand)
notes:
  - order_ts는 UTC. KST=UTC+9로 변환 필요
  - 취소건 status='CANCELLED' 제외
"""
SQL = """
SELECT p.category
     , SUM(oi.qty*oi.price) - SUM(o.vat) AS net_sales
  FROM orders o
       JOIN order_items oi USING(order_id)
       JOIN products p USING(product_id)
 WHERE o.status!='CANCELLED'
   AND o.order_ts >= DATE_TRUNC('month', NOW() AT TIME ZONE 'UTC' - INTERVAL '1 month')
   AND o.order_ts <  DATE_TRUNC('month', NOW() AT TIME ZONE 'UTC')
 GROUP BY 1
 ORDER BY 2 DESC
LIMIT 10;
"""

if __name__ == "__main__":
    df, ms = run_sql(SQL)
    log_audit(PROMPT, SCHEMA_SUMMARY, SQL, ms, len(df))
    print(df.head().to_markdown(index=False))
```

> **Tip:** 운영에서는 결과를 CSV/Parquet로 저장하고 BI에 전달, 상위 3개 지표를 카드형 위젯으로 노출.

---

## 🔍 F. 검증 루프(정확도 확보)

* ▷ 정적 검증

  * 금지 키워드/스키마 외 엔티티 탐지, LIMIT/타임아웃, 조인 키 존재성.
* → 동적 검증

  * `EXPLAIN` 비용 과다(Seq Scan 대량) 시 인덱스/조건식 개선 프롬프트 재생성.
  * 샘플 데이터셋(스테이징)에서 **시뮬 실행 → 본 DB 실행** 2단계.
* → 의미 검증

  * **테스트 케이스**: ① 기간=1일 ② 기간=0행 ③ 경계값(월말/월초) → 예상 결과와 일치 여부.
  * 결과 통계(널 비율·중복·범위)로 **이상 탐지**.

> **핵심:** “정적→동적→의미” 3단계 검증 없이는 본 DB 실행 금지.

---

## 📈 G. 성능/비용 관리

* ▷ 쿼리 가이드

  * 항상 **컬럼 선택(SELECT 리스트 최적화)**, 필요 컬럼만.
  * 날짜 범위 강제, 서브쿼리 대신 조인/CTE 비교 후 선택.
  * 윈도우 함수 사용 시 파티션 크기/정렬 키 검토.
* → 페이징/샘플링

  * 시각화 목적: `LIMIT 200`, 상세는 “전체 다운로드” 버튼으로 지연 실행.
* → 캐시

  * `prompt_hash + schema_hash + args`로 **결과 캐시**, TTL 설정.

> **Note:** SLA(대기시간·행수·비용) 카드로 모니터링.

---

## 🗃️ H. 스키마 요약 자동화(예시 코드)

```python
# pip install sqlalchemy pandas
# 스키마 메타데이터를 요약해 LLM 컨텍스트에 주입
from sqlalchemy import create_engine, inspect
import pandas as pd, json, os

def summarize_schema(url:str)->str:
    eng = create_engine(url)
    insp = inspect(eng)
    lines=[]
    for t in insp.get_table_names():
        cols = insp.get_columns(t)
        pk = [c['name'] for c in insp.get_pk_constraint(t).get('constrained_columns',[])]
        lines.append(f"- {t}({', '.join([c['name'] for c in cols])}); PK={pk}")
    eng.dispose()
    return "tables:\n" + "\n".join(lines)

if __name__=="__main__":
    print(summarize_schema(os.getenv("PG_URL_READONLY")))
```

---

## 🧪 I. 품질지표 & 테스트

* 정확 실행률(에러 없이 실행)
* 의미 정확도(골드 쿼리 대비 동일 결과 %)
* 보안 위반 감지율(금지 패턴 차단)
* 성능(중앙값 지연시간, 95p, 평균 행수)
* 재현성(동일 프롬프트 해시 동일 결과율)

> **권장:** 주간 리그레션 테스트(50~200개 질의 세트) 자동화.

---

## 🧰 J. 대안 설계(상황별 옵션)

1. **Option A: 직접 SQL 생성(빠름/유연)**

   * 장점: 구현 간단, 비용 낮음
   * 위험: 환각·보안 리스크 → 본 지침의 검증/허용리스트 필수
2. **Option B: ORM/API 레이어(안전/일관)**

   * LLM은 **“쿼리 의도 DSL”**만 출력 → 서버가 ORM으로 변환
   * 장점: 스키마 변경 내성↑, 보안정책 중앙화
3. **Option C: 하이브리드(RAG + SQL)**

   * 사전 집계뷰/데이터 딕셔너리를 임베딩하여 **질문→뷰 매핑** 후 SQL 최소화

> **선택 기준:** 데이터 민감도↑ → B/C 권장, 탐색型 분석 → A/C.

---

## 📦 K. 배포/MLOps 체크

* 비밀 관리: `.env`/KMS/Parameter Store, 로테이션
* 관측성: 구조화 로그 + 추적ID + 대시보드(지연/오류/차단 건)
* 카나리 릴리스: 허용 사용자 소수 → 점진 확대
* 롤백: 허용리스트·스키마 스냅샷 버전 관리

---

## 🚫 금지 규칙(반드시 준수)

* DDL/DML/권한 변경 생성·실행 금지
* 스키마에 없는 테이블/컬럼 추정 금지
* LIMIT/타임아웃 없는 쿼리 금지
* PII 원문 조회/내보내기 금지

---

## 🧑 💻 부록: MongoDB & 벡터DB 간단 예시

* **MongoDB 질의 가드(의사코드)**

  * 허용: `find`, `aggregate`(stage 화이트리스트: `$match,$project,$limit,$group,$sort`)
  * 금지: `$out,$merge` 등 쓰기 스테이지
* **PGVector 예시**

  ```sql
  -- 임베딩 컬럼에 HNSW 인덱스
  CREATE INDEX IF NOT EXISTS idx_docs_embedding ON docs USING hnsw (embedding vector_l2_ops);
  -- LLM은 '검색 의도'만 생성, 실제 SQL은 서버 템플릿로 안전 구성
  SELECT id, title FROM docs
  ORDER BY embedding <-> :query_embedding
  LIMIT 20;
  ```

---

## ✅ 최종 체크리스트

1. READ ONLY 연결/롤이 설정되어 있는가?
2. 스키마 요약을 최신화하고 프롬프트에 주입했는가?
3. 금지 키워드/허용 리스트 필터가 적용되는가?
4. LIMIT≤200, 타임아웃≤20s가 강제되는가?
5. EXPLAIN/스테이징 시뮬 후 본 DB를 실행하는가?
6. 결과에 대한 의미 검증/샘플 테스트를 통과했는가?
7. 프롬프트·스키마·SQL·결과가 감사 로그로 남는가?
8. PII 마스킹/최소권한/접근제어가 활성화되어 있는가?
9. 성능·비용 지표를 대시보드로 관측하는가?
10. UI는 카드/표/차트로 요약되어 있는가?

---

## 📌 요약(One-liner)

**LLM×DB는 “허용리스트+검증루프+감사로그”를 표준으로 하고, 언제나 읽기 전용·LIMIT·타임아웃을 강제하라.**
