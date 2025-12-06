# 🤖 DB-Centric AI Execution Guidelines v1.0

## 📋 Core Principles

**Objective**: For an LLM to safely and accurately query, analyze, and summarize databases.
**Scope**: RDBMS (PostgreSQL/MySQL/SQL Server/SQLite), NoSQL (MongoDB), Vector DB.
**Core Workflow**: READ ONLY → Schema Summary → SQL Generation → Validation → Restricted Execution → Result Interpretation.

-----

## 🎯 A. 5 Core Policies

```yaml
Safety:
  - Default to READ ONLY mode
  - Block DDL/DML (allowlist approach)
  - Enforce transactions, timeouts, and row limits

Accuracy:
  - Provide schema summary in the LLM context
  - Few-shot examples + test cases
  - Self-validation loop

Reproducibility:
  - Log all prompts, schemas, SQL, and results
  - Audit trail

Performance:
  - Index checks, sampling, paging, caching
  - EXPLAIN Plan review

Security/Privacy:
  - Principle of least privilege
  - PII masking
  - Table/column level access control
```

> **Key Trio**: allowlist + validation loop + audit log

-----

## 🏗️ B. 7-Step Execution Pipeline

```
① Schema Collection/Summary
    DB → ER/Column Stats → Build LLM Context

② Prompt Construction
    System Rules + User Question + Schema Summary + Few-shot

③ SQL Generation & Static Check
    Forbidden keywords, JOIN key validity, enforce LIMIT

④ Sandbox Simulation
    EXPLAIN/EXPLAIN ANALYZE (on a sample DB)

⑤ Restricted Execution
    Read-only connection, timeout, max row count

⑥ Result Interpretation/Visualization
    Table/Chart, semantic summary

⑦ Audit Log
    Record prompt_hash, schema_hash, SQL, metrics
```

> **Note**: Each step includes fail-fast + suggested revisions.

-----

## 🧠 C. Prompt Design

### System Prompt

```
Role: "DB Safe Query Assistant"

Rules:
- No DDL/DML (ALTER, DROP, INSERT, UPDATE, DELETE, TRUNCATE)
- Always include LIMIT ≤ 200
- Assume a 20-second timeout, prefer index access
- Do not guess columns/tables outside the schema summary

Output Format:
1) SQL (in a single code block)
2) Natural language validation checklist (with reasoning)
3) Expected result columns/types
```

### User Prompt

```
Question: {natural language question}
Period: 2025-07-01 to 2025-09-01
Schema Summary: {auto-injected}
Example Queries: {N few-shots}
Constraints: LIMIT≤200, 20s, read-only
Required Output: [SQL] + [Validation Points] + [Expected Columns]
Query Style: Strictly adhere to Claude_Knauf-SQL-Style.md
```

### Few-shot Example Patterns

```sql
-- Top 10 product sales from last month
-- Grouping/sorting/LIMIT, NULL handling, timezone specification
SELECT p.category, SUM(oi.qty*oi.price) - SUM(o.vat) AS net_sales
FROM orders o 
JOIN order_items oi USING(order_id)
JOIN products p USING(product_id)
WHERE o.status!='CANCELLED'
  AND o.order_ts >= DATE_TRUNC('month', NOW() AT TIME ZONE 'UTC' - INTERVAL '1 month')
  AND o.order_ts < DATE_TRUNC('month', NOW() AT TIME ZONE 'UTC')
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- New vs. returning user cohorts
-- Window functions, partition keys, date bucketing
WITH user_segments AS (...)
SELECT type, COUNT(*), AVG(amount)
FROM orders o JOIN user_segments u USING(user_id)
GROUP BY 1
LIMIT 200;
```

-----

## 🔒 D. Security/Permissions/Auditing

### Security Framework

```yaml
Least Privilege:
  - Dedicated READONLY role
  - Enforce SET TRANSACTION READ ONLY
  - Minimize exposure with (Materialized) Views

Query Allowlist:
  - Allowed pattern: ^\s*SELECT\b
  - Forbidden keywords: INSERT|UPDATE|DELETE|ALTER|DROP|TRUNCATE|GRANT|REVOKE|CREATE|EXEC

Privacy:
  - PII column masking: email, phone, ssn, address
  - View-level masking
  - Sampled data (5%)

Audit Logging:
  - prompt_hash, schema_hash, sql_text
  - plan_digest, rowcount, latency_ms
  - user_id, timestamp
```

> **Design Principle**: Less privilege, less exposure, more logging.

-----

## ⚙️ E. Execution Code (PostgreSQL)

### Core Validation and Execution

```python
import os, re, json, hashlib, time
from contextlib import contextmanager
import pandas as pd
from sqlalchemy import create_engine, text

# Validation regex
ALLOWED = re.compile(r"^\s*SELECT\b", re.IGNORECASE | re.DOTALL)
FORBIDDEN = re.compile(
    r"\b(INSERT|UPDATE|DELETE|ALTER|DROP|TRUNCATE|GRANT|REVOKE|CREATE)\b",
    re.IGNORECASE
)

def validate_sql(sql: str):
    """Static SQL validation"""
    if not ALLOWED.search(sql):
        raise ValueError("Only SELECT statements are allowed")
    if FORBIDDEN.search(sql):
        raise ValueError("DDL/DML is forbidden")
    if "limit" not in sql.lower():
        raise ValueError("LIMIT ≤ 200 is mandatory")
    m = re.search(r"limit\s+(\d+)", sql, re.IGNORECASE)
    if not m or int(m.group(1)) > 200:
        raise ValueError("LIMIT must be 200 or less")

@contextmanager
def readonly_engine():
    """READ ONLY connection context"""
    url = os.getenv("PG_URL_READONLY")
    eng = create_engine(
        url,
        connect_args={"options": "-c statement_timeout=20000"}
    )
    try:
        with eng.begin() as conn:
            conn.execute(text("SET TRANSACTION READ ONLY;"))
            yield conn
    finally:
        eng.dispose()

def run_sql(sql: str) -> tuple[pd.DataFrame, int]:
    """Validate and then execute"""
    validate_sql(sql)
    t0 = time.time()
    with readonly_engine() as conn:
        df = pd.read_sql(text(sql), conn)
    latency = int((time.time() - t0) * 1000)
    return df, latency

def log_audit(prompt: str, schema: str, sql: str, latency: int, rows: int):
    """Record an audit log"""
    rec = {
        "prompt_hash": hashlib.sha256(prompt.encode()).hexdigest()[:16],
        "schema_hash": hashlib.sha256(schema.encode()).hexdigest()[:16],
        "sql": sql,
        "latency_ms": latency,
        "rowcount": rows,
        "ts": pd.Timestamp.utcnow().isoformat()
    }
    with open("audit_log.jsonl", "a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")
```

### Automatic Schema Summary

```python
from sqlalchemy import create_engine, inspect

def summarize_schema(url: str) -> str:
    """Summarize schema metadata"""
    eng = create_engine(url)
    insp = inspect(eng)
    lines = []
    
    for table in insp.get_table_names():
        cols = insp.get_columns(table)
        pk = insp.get_pk_constraint(table).get('constrained_columns', [])
        col_names = ', '.join([c['name'] for c in cols])
        lines.append(f"- {table}({col_names}); PK={pk}")
    
    eng.dispose()
    return "tables:\n" + "\n".join(lines)
```

-----

## 🔍 F. 3-Step Validation Loop

```yaml
Static Validation:
  Checks:
    - Detect forbidden keywords
    - Check for entities outside the schema
    - Enforce LIMIT/timeout
    - Verify existence of JOIN keys

Dynamic Validation:
  Execution:
    - EXPLAIN cost analysis
    - Seq Scan size → suggest index
    - 2-stage: sample (staging) → production

Semantic Validation:
  Test Cases:
    - period=1 day
    - period=0 rows
    - Boundary values (end/start of month)
  Result Statistics:
    - NULL ratio
    - Duplication check
    - Range validation
    - Anomaly detection
```

> **Requirement**: Must pass all 3 steps before production execution.

-----

## 📈 G. Performance & Cost Management

### Query Optimization

```yaml
Guidelines:
  - SELECT only necessary columns
  - Enforce date range filters
  - Choose between JOIN/CTE vs. Subquery
  - Window Function: Review partition size

Paging/Sampling:
  - Visualization: LIMIT 200
  - Full download: Delayed job

Caching:
  - Key: prompt_hash + schema_hash + args
  - Set TTL

Monitoring:
  - SLA Card: latency, row count, cost
```

-----

## 🧪 H. Quality Metrics

```yaml
Accuracy:
  - Success rate (no errors)
  - Semantic accuracy (match rate against golden queries)

Security:
  - Violation detection rate (blocking forbidden patterns)

Performance:
  - Median latency
  - p95 latency
  - Average row count

Reproducibility:
  - Same prompt_hash → same result rate
```

> **Recommendation**: Weekly regression test with a set of 50-200 queries.

-----

## 🧰 I. Alternative Designs

### Option A: Direct SQL Generation

```yaml
Characteristics: Fast/Flexible
Pros: Simple implementation, low cost
Risks: Hallucination/Security → Strictly apply the validation/allowlist from this guide
```

### Option B: ORM/API Layer

```yaml
Characteristics: Safe/Consistent
Method: LLM only outputs a "query intent DSL" → server converts it to ORM
Pros: Resilient to schema changes, central security policy
```

### Option C: Hybrid (RAG + SQL)

```yaml
Characteristics: Accurate/Secure
Method: Embed pre-aggregated Views/Data Dictionaries → map questions to Views
Pros: Minimizes raw SQL
```

**Selection Criteria**: High data sensitivity → B/C, Exploratory analysis → A/C

-----

## 📦 J. NoSQL & Vector DB

### MongoDB

```yaml
Allowed: find, aggregate
Stage Allowlist: $match, $project, $limit, $group, $sort
Forbidden: $out, $merge (write stages)
```

### PGVector

```sql
-- HNSW index
CREATE INDEX idx_docs_embedding 
ON docs USING hnsw (embedding vector_l2_ops);

-- LLM provides search intent only, server constructs safe SQL
SELECT id, title FROM docs
ORDER BY embedding <-> :query_embedding
LIMIT 20;
```

-----

## ✅ Final Checklist

```
1. [ ] Configure READ ONLY connection/role
2. [ ] Ensure schema summary is up-to-date and injected into the prompt
3. [ ] Apply forbidden keyword filter/allowlist
4. [ ] Enforce LIMIT≤200, timeout≤20s
5. [ ] Execute on production after EXPLAIN/staging
6. [ ] Pass semantic validation/sample tests
7. [ ] Record audit logs
8. [ ] Implement PII masking/least privilege/access control
9. [ ] Set up performance/cost metrics dashboard
10. [ ] Summarize results in UI cards/tables/charts
```

-----

## 🚫 Forbidden Rules

```
❌ Generate/execute DDL/DML/permission changes
❌ Guess tables/columns outside the schema
❌ Queries without LIMIT/timeout
❌ Query/export raw PII data
```

-----

## 📌 Key Summary

**LLM × DB Standard**: allowlist + validation loop + audit log, always enforce read-only + LIMIT + timeout.