# 🗄️ DB-Focused AI Guidelines v1.0

> Purpose: Practical guidance to help an LLM **query, analyze, and summarize databases safely, accurately, and reproducibly**. (Assumes Windows · Python 3.9+ · VS Code/Jupyter)

---

## 🧭 Overview

* ▷ Background

  * In practice, when an LLM generates/executes SQL, **accuracy degradation (hallucination)**, **security risks**, and **performance drops** occur frequently.
  * These guidelines stage the workflow **with safeguards**: **understand schema → generate query → validate → execute → summarize/visualize**.
* → Scope

  * RDBMS (PostgreSQL/MySQL/SQL Server/SQLite), NoSQL (MongoDB), Vector DBs (PGVector/FAISS/Chroma)
  * BI assistance, natural language → SQL, data quality checks, log analytics, in-product “AI query” features

> **One-line core:** “Always follow: read-only → schema summarization → SQL draft → static analysis/simulation → constrained execution → result validation → summarization/visualization.”

---

## 🧱 A. Policies (Foundational Principles)

* **Safety first:** `READ ONLY` by default, block DDL/DML (allowlist approach). Enforce transactions, timeouts, and row limits.
* **Accuracy:** Provide schema summaries to the LLM; use **few-shot** examples and **test cases** for a self-check loop.
* **Reproducibility:** Log **all prompts, schema snapshots, executed SQL, and sample results** as an **audit trail**.
* **Performance:** Standardize index checks, sampling, paging, caching, and Explain Plan review.
* **Security/Privacy:** Least privilege, PII masking, table/column-level access control.
* **UX:** Always present results via **GUI-style cards/tables/checklists**; fold code/logs using accordions.

> **Key takeaway:** Default to the trio: **allowlist + validation loop + audit log**.

---

## 🧩 B. Reference Architecture (System Composition)

* ▷ Prerequisites

  * Python 3.9+, `SQLAlchemy`, `psycopg2`/`pymysql`/`pyodbc`, `pandas`, `matplotlib`, optional: `pgvector`, `openai/anthropic/hf` SDKs
* → Flow (card-style)

  * ① **Schema collection/summarization card**: DB → ER/column stats → build LLM context
  * ② **Prompt card**: system rules + user question + schema summary + few-shot
  * ③ **SQL generation & static checks card**: banned keywords, join-key validity, enforce LIMIT
  * ④ **Sandbox simulation card**: `EXPLAIN`/`EXPLAIN ANALYZE` (on a sample DB)
  * ⑤ **Constrained execution card**: read-only connection, timeout, max rows
  * ⑥ **Result interpretation/visualization card**: table/simple charts, meaning summary
  * ⑦ **Audit log card**: record prompt, schema hash, SQL, metrics

> **Note:** Each of ①–⑦ includes a stop-the-world fail-fast procedure with remediation suggestions.

---

## 🧠 C. Prompt Design (LLM Guardrails)

* ▷ System prompt (template)

  ```
  Role: You are a "DB Safe Query Assistant".
  Rules:
  - DDL/DML are forbidden (no ALTER, DROP, INSERT, UPDATE, DELETE, TRUNCATE).
  - Always include LIMIT ≤ 200. Assume 20s time limit; prefer indexed access.
  - Do not guess unknown columns/tables. Do not use entities outside the schema summary.
  - Output format:
    1) SQL (single code block)
    2) Natural-language verification checklist (with rationale)
    3) Expected result columns/types
  ```
* → User prompt (template)

  ```
  Question: {natural-language question}
  Period: {e.g., 2025-07-01~2025-09-01}
  Schema summary: {auto-injected}
  Example queries: {N few-shot examples}
  Constraints: LIMIT≤200, 20s, read-only
  Required output: [SQL] + [Verification Points] + [Expected Columns]
  Query output: Must strictly follow Claude_Knauf-SQL-Style.md
  ```
* → Few-shot examples (summary)

  * “Top 10 sales by product last month” → grouping/sorting/LIMIT, null handling, timezone explicit
  * “New vs. returning user cohort” → window functions, partition keys, date bucketing

> **Essentials:** No out-of-schema reasoning + banned keywords + enforced output format.

---

## 🔒 D. Security / Permissions / Audit

* ▷ Least privilege

  * Dedicated `READONLY` role; enforce `SET TRANSACTION READ ONLY;`; minimize exposure via (materialized) views.
* → Query allowlist

  * Allow regex patterns for permitted statements + filter out banned keywords (DDL/DML/privilege/function changes).
* → Privacy

  * Mask PII columns (`email`, `phone`, `ssn`, `address`) in views; provide sampled data (5%).
* → Audit/Logging

  * Store `prompt_hash, schema_hash, sql_text, plan_digest, rowcount, latency_ms, user_id, ts`.

> **Key takeaway:** Design security as **privilege ↓, exposure ↓, logging ↑**.

---

## ⚙️ E. Execution Pipeline (Complete Code Example · PostgreSQL)

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
    # Use a READONLY account
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

# === Example usage ===
PROMPT = "Give me last month's top 10 sales by category (VAT excluded)."
SCHEMA_SUMMARY = """
tables:
  orders(order_id, user_id, order_ts, amount, vat, status)
  order_items(order_id, product_id, qty, price)
  products(product_id, category, brand)
notes:
  - order_ts is UTC. Convert to KST=UTC+9 if needed
  - Exclude cancellations: status='CANCELLED'
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

> **Tip:** In production, persist results as CSV/Parquet for BI, and surface the top 3 KPIs via card widgets.

---

## 🔍 F. Validation Loop (Ensuring Accuracy)

* ▷ Static validation

  * Detect banned keywords/out-of-schema entities; enforce LIMIT/timeout; verify join-key existence.
* → Dynamic validation

  * If `EXPLAIN` cost is high (e.g., large Seq Scans), regenerate prompts to improve indexes/predicates.
  * Two-step run: **simulate on a sample (staging) dataset → run on prod DB**.
* → Semantic validation

  * **Test cases**: ① period=1 day ② period=0 rows ③ boundary (month-end/start) → must match expected results.
  * Use result stats (null ratios, duplicates, ranges) for **anomaly detection**.

> **Essentials:** Do **not** run on prod without the **three-stage validation: static → dynamic → semantic**.

---

## 📈 G. Performance & Cost Management

* ▷ Query guidance

  * Always **select only needed columns** (optimize SELECT lists).
  * Enforce date ranges; compare JOINs/CTEs vs. subqueries and choose accordingly.
  * When using window functions, review partition sizes and sort keys.
* → Paging/Sampling

  * For visualization: `LIMIT 200`; offer “download all” as a deferred action for details.
* → Caching

  * **Result cache** keyed by `prompt_hash + schema_hash + args`, with TTL.

> **Note:** Monitor via an SLA card (latency, rows, cost).

---

## 🗃️ H. Automated Schema Summarization (Example Code)

```python
# pip install sqlalchemy pandas
# Summarize schema metadata and inject into the LLM context
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

## 🧪 I. Quality Metrics & Tests

* Correct execution rate (runs without errors)
* Semantic accuracy (percent matching a gold query’s result)
* Security violation detection rate (blocked forbidden patterns)
* Performance (median latency, p95, average row count)
* Reproducibility (same prompt hash → same result rate)

> **Recommendation:** Automate weekly regression tests with 50–200 query sets.

---

## 🧰 J. Alternative Designs (By Situation)

1. **Option A: Direct SQL generation (fast/flexible)**

   * Pros: Simple to implement, low cost
   * Risks: Hallucinations/security → use these guidelines’ validation/allowlists strictly
2. **Option B: ORM/API layer (safe/consistent)**

   * LLM outputs a **“query intent DSL”** only → server converts to ORM
   * Pros: More resilient to schema changes; centralized security policy
3. **Option C: Hybrid (RAG + SQL)**

   * Embed pre-aggregated views/data dictionary to **map questions → views**, minimizing raw SQL

> **Selection rule of thumb:** Higher data sensitivity → favor B/C; exploratory analytics → favor A/C.

---

## 📦 K. Deployment/MLOps Checklist

* Secrets management: `.env`/KMS/Parameter Store, with rotation
* Observability: structured logs + trace IDs + dashboards (latency/errors/blocks)
* Canary release: small allowlisted user group → gradual expansion
* Rollback: version control for allowlists & schema snapshots

---

## 🚫 Prohibited Rules (Must Comply)

* Do not generate/execute DDL/DML/privilege changes
* Do not infer tables/columns not in the schema
* No queries without LIMIT/timeouts
* No exporting or raw retrieval of PII

---

## 🧑 💻 Appendix: MongoDB & Vector DB Quick Examples

* **MongoDB query guard (pseudocode)**

  * Allow: `find`, `aggregate` (stage allowlist: `$match,$project,$limit,$group,$sort`)
  * Forbid: `$out,$merge` and other write stages
* **PGVector example**

  ```sql
  -- HNSW index on the embedding column
  CREATE INDEX IF NOT EXISTS idx_docs_embedding ON docs USING hnsw (embedding vector_l2_ops);
  -- LLM generates only the 'search intent'; server composes safe SQL from templates
  SELECT id, title FROM docs
  ORDER BY embedding <-> :query_embedding
  LIMIT 20;
  ```

---

## ✅ Final Checklist

1. Is a READ ONLY connection/role configured?
2. Is the schema summary up to date and injected into the prompt?
3. Are forbidden-keyword filters/allowlists applied?
4. Are LIMIT≤200 and timeout≤20s enforced?
5. Do you run on prod only **after** EXPLAIN/staging simulation?
6. Did the results pass semantic validation/sample tests?
7. Are prompt/schema/SQL/results recorded in the audit log?
8. Are PII masking/least privilege/access controls active?
9. Are performance/cost metrics visible on dashboards?
10. Is the UI summarized with cards/tables/charts?

---

## 📌 TL;DR

**For LLM × DB, standardize on “allowlist + validation loop + audit log,” and always enforce read-only, LIMIT, and timeouts.**
