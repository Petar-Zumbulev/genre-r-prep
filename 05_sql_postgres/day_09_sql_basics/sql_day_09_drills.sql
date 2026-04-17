-- Day 9 SQL drills
-- Insurance-style practice
# ---------------------------------------
# right now these SQL commands are mostly for learning and reading, not for 
# actual execution.
# Because at the moment you do not have:
# a real database
# real tables like policies, claims, premium_transactions
# a SQL engine connected to them
#
# So if you just have a .sql file sitting in your repo, nothing meaningful 
# happens by itself. The Day 9 plan was to learn SELECT, WHERE, GROUP BY, 
# ORDER BY, joins, and granularity
#---------------------------------------
-- 1. Select all policies
SELECT *
FROM policies;

-- 2. Select only some columns
SELECT policy_id, line, region
FROM policies;

-- 3. Filter rows
SELECT policy_id, line, region
FROM policies
WHERE region = 'North';

-- 4. Sort claims by amount
SELECT claim_id, policy_id, claim_amount
FROM claims
ORDER BY claim_amount DESC;

-- 5. Count claims per policy
SELECT
    policy_id,
    COUNT(*) AS claim_count
FROM claims
GROUP BY policy_id;

-- 6. Total claim amount per policy
SELECT
    policy_id,
    SUM(claim_amount) AS total_claim_amount
FROM claims
GROUP BY policy_id;

-- 7. Average severity per policy
SELECT
    policy_id,
    AVG(claim_amount) AS avg_severity
FROM claims
GROUP BY policy_id;

-- 8. Join claims to policies
SELECT
    c.claim_id,
    c.policy_id,
    p.line,
    p.region,
    c.claim_amount
FROM claims c
LEFT JOIN policies p
    ON c.policy_id = p.policy_id;

-- 9. Average severity by line
SELECT
    p.line,
    AVG(c.claim_amount) AS avg_severity
FROM claims c
LEFT JOIN policies p
    ON c.policy_id = p.policy_id
GROUP BY p.line
ORDER BY avg_severity DESC;

-- 10. Claim count by region
SELECT
    p.region,
    COUNT(*) AS claim_count
FROM claims c
LEFT JOIN policies p
    ON c.policy_id = p.policy_id
GROUP BY p.region
ORDER BY claim_count DESC;

-- 11. Total premium by line
SELECT
    p.line,
    SUM(pt.premium_amount) AS total_premium
FROM premium_transactions pt
LEFT JOIN policies p
    ON pt.policy_id = p.policy_id
GROUP BY p.line
ORDER BY total_premium DESC;

-- 12. Bad join example: may duplicate rows
# 
# The problem here is granularity
# if you join two “many rows per policy” tables at the same time, 
# you can accidentally multiply rows
#
# joining the two tables is not safe because it multiplies rows
# due to different granularities
# 
SELECT
    p.line,
    SUM(c.claim_amount) AS total_claims,
    SUM(pt.premium_amount) AS total_premium
FROM policies p
LEFT JOIN claims c
    ON p.policy_id = c.policy_id -- here's the problem, we join policies which has
LEFT JOIN premium_transactions pt -- one row per policy with claims which has
    ON p.policy_id = pt.policy_id -- many rows per policy!
GROUP BY p.line;

-- 13. Better version: aggregate first, then join
# 
# now we took care of the granularity because of the aggregation
#
WITH claim_totals AS (
    SELECT
        policy_id,
        SUM(claim_amount) AS total_claims -- aggregation part
    FROM claims
    GROUP BY policy_id
),
premium_totals AS (
    SELECT
        policy_id,
        SUM(premium_amount) AS total_premium -- aggregation part
    FROM premium_transactions
    GROUP BY policy_id
)
SELECT
    p.line,
    SUM(ct.total_claims) AS total_claims,
    SUM(pt.total_premium) AS total_premium
FROM policies p
LEFT JOIN claim_totals ct
    ON p.policy_id = ct.policy_id -- now we're joining tables that have aggregated values
LEFT JOIN premium_totals pt
    ON p.policy_id = pt.policy_id
GROUP BY p.line;

# now we joined summarized tables, and multiplication of rows didnt occur

