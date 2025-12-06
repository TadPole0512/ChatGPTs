1) Basic principles
    - Keywords in all capital letters : `select, from, join, where, group by, order by, with, case ...`
    - 1 line, 1 column: `SELECT`, `GROUP BY`, `ORDER BY` All columns are vertically aligned
    - Leading comma style: place comma `,` before each column line
    - AS aliases: column/table aliases should be `AS` on the same line
    - Schema explicit: tables always use the `dbo.` prefix
    - JOIN/WHERE indentation alignment : `JOIN`, `ON`, `WHERE`, `AND`, `OR` are newlines + vertical alignment
    - Semicolon: Use `;` at the end of a sentence (especially before CTE)
    - Hangul/Unicode literals should always be N'' for Korean/Unicode literals


2) SELECT block rules
SELECT a.ORDER_ID              AS ORDER_ID
     , a.CUST_CD               AS CUST_CD
     , c.CUST_NM               AS CUST_NM
     , a.ORDER_DT              AS ORDER_DT
     , CASE
           WHEN a.TOTAL_AMT >= 1000000 THEN N'대'
           WHEN a.TOTAL_AMT >=  100000 THEN N'중'
           ELSE N'소'
       END AS SIZE_GB
  FROM dbo.O_SALESORDER AS a
       JOIN dbo.O_CUSTOMER AS c
         ON c.CUST_CD = a.CUST_CD
 WHERE a.ORDER_DT >= '2025-08-01'
   AND a.STATUS   = N'CONFIRMED'
 GROUP BY a.ORDER_ID
        , a.CUST_CD
        , c.CUST_NM
        , a.ORDER_DT
        , CASE
              WHEN a.TOTAL_AMT >= 1000000 THEN N'대'
              WHEN a.TOTAL_AMT >=  100000 THEN N'중'
              ELSE N'소'
          END
 ORDER BY a.ORDER_DT DESC
        , a.ORDER_ID  ASC
;


3) JOIN rules
  FROM dbo.T1 AS t1
       JOIN dbo.T2 AS t2
         ON t2.K1 = t1.K1
        AND t2.USE_YN = N'Y'
       LEFT JOIN dbo.T3 AS t3
              ON t3.K1 = t1.K1
             AND t3.DEL_YN = N'N'


4) WHERE rules
 WHERE t1.DT BETWEEN '2025-08-01' AND '2025-08-31'
   AND t1.TYPE  = N'ORDER'
   AND (
           t1.AMT >= 10000
       OR  t1.FLAG = N'V'
       )


5) Subquery / CTE rules
;WITH cte AS (
                SELECT s.CUST_CD  AS CUST_CD
                     , SUM(s.QTY) AS QTY
                  FROM dbo.O_SALES AS s
                 WHERE s.DEL_YN = N'N'
                 GROUP BY s.CUST_CD
             )
SELECT c.CUST_CD
     , c.QTY
  FROM cte AS c
 WHERE c.QTY > 0
;


6) UNION(ALL) rules
(
   SELECT a.ID    AS ID
        , N'WEB'  AS SRC
     FROM dbo.T_WEB AS a
)
UNION ALL
(
   SELECT b.ID    AS ID
        , N'APP'  AS SRC
     FROM dbo.T_APP AS b
)


7) CASE rules
CASE
    WHEN x.VAL >  0 THEN N'POS'
    WHEN x.VAL =  0 THEN N'ZERO'
    ELSE N'NEG'
END AS VAL_TAG


8) IN / EXISTS rules
 WHERE t.CUST_CD IN (
                       SELECT c.CUST_CD
                         FROM dbo.O_CUSTOMER AS c
                        WHERE c.USE_YN = N'Y'
                    )
또는
WHERE EXISTS (
                SELECT 1
                  FROM dbo.O_CUSTOMER AS c
                 WHERE c.CUST_CD = t.CUST_CD
                   AND c.USE_YN = N'Y'
             )


9) Unicode literal rules (new in v1.1)
 WHERE t.MSG = N'mail format error'


10) SUBSTRING offset rule (new in v1.1)
-- Bad
SUBSTRING(t.TOKEN, 6, 10)

-- Good
SUBSTRING(t.TOKEN, LEN('PRE_') + 1, 10)


11) Object/Schema/Dynamic SQL (v1.1 Enhanced)
DECLARE @sch  SYSNAME = N'dbo'
      , @tb   SYSNAME = N'O_CUSTOMER'
      , @sql  NVARCHAR(MAX);

SET @sql = N'SELECT COUNT(*) AS CNT FROM '
         + QUOTENAME(@sch) + N'.' + QUOTENAME(@tb) + N';';

EXEC sys.sp_executesql @sql;


12) Numeric token LIKE boundary check (new in v1.1)
-- Example: Prevent '123' from being matched as part of '1234' in code
 WHERE col LIKE N'%123%' -- primary filter
   AND PATINDEX(N'%[^0-9]%', SUBSTRING(col, CHARINDEX(N'123', col) + 3, 1) + N'X') = 1


13) DDL rules (v1.1 complement)
-- Preferred
DROP TABLE IF EXISTS dbo.T_TEMP;

-- backwards compatible
IF OBJECT_ID(N'dbo.T_TEMP', N'U') IS NOT NULL
    DROP TABLE dbo.T_TEMP;


17) Synthetic example
;WITH base AS (
                 SELECT mi.CUST_CD               AS CUST_CD
                      , mi.CUST_MAIN_EMAIL       AS MAIN_EMAIL
                      , mi.SALESREP_EMAIL        AS SALES_EMAIL
                      , mi.REMARK                AS REMARK
                      , mi.CUST_SENDMAIL_YN      AS CUST_SENDMAIL_YN
                      , mi.SALESREP_SENDMAIL_YN  AS SALESREP_SENDMAIL_YN
                   FROM dbo.O_CUSTOMER_MAILINFO AS mi
                  WHERE mi.DEL_YN = N'N'
              )
SELECT b.CUST_CD
     , b.MAIN_EMAIL
     , b.SALES_EMAIL
     , b.REMARK
  FROM base AS b
 WHERE (
           b.CUST_SENDMAIL_YN   = N'Y'
       OR  b.SALESREP_SENDMAIL_YN = N'Y'
       )
   AND (
           b.MAIN_EMAIL  IS NOT NULL
       OR  b.SALES_EMAIL IS NOT NULL
       )
 ORDER BY b.CUST_CD ASC
;