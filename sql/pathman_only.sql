/*
 * ---------------------------------------------
 *  NOTE: This test behaves differenly on PgPro
 * ---------------------------------------------
 */

\set VERBOSITY terse

SET search_path = 'public','_gogu';
CREATE EXTENSION gogudb;
CREATE SCHEMA test_only;



/* Test special case: ONLY statement with not-ONLY for partitioned table */
CREATE TABLE test_only.from_only_test(val INT NOT NULL);
INSERT INTO test_only.from_only_test SELECT generate_series(1, 20);
SELECT create_range_partitions('test_only.from_only_test', 'val', 1, 2);

VACUUM ANALYZE;

/* should be OK */
EXPLAIN (COSTS OFF)
SELECT * FROM ONLY test_only.from_only_test
UNION SELECT * FROM test_only.from_only_test;

/* should be OK */
EXPLAIN (COSTS OFF)
SELECT * FROM test_only.from_only_test
UNION SELECT * FROM ONLY test_only.from_only_test;

/* should be OK */
EXPLAIN (COSTS OFF)
SELECT * FROM test_only.from_only_test
UNION SELECT * FROM test_only.from_only_test
UNION SELECT * FROM ONLY test_only.from_only_test;

/* should be OK */
EXPLAIN (COSTS OFF)
SELECT * FROM ONLY test_only.from_only_test
UNION SELECT * FROM test_only.from_only_test
UNION SELECT * FROM test_only.from_only_test;

/* not ok, ONLY|non-ONLY in one query (this is not the case for PgPro) */
EXPLAIN (COSTS OFF)
SELECT * FROM test_only.from_only_test a
JOIN ONLY test_only.from_only_test b USING(val);

/* should be OK */
EXPLAIN (COSTS OFF)
WITH q1 AS (SELECT * FROM test_only.from_only_test),
	 q2 AS (SELECT * FROM ONLY test_only.from_only_test)
SELECT * FROM q1 JOIN q2 USING(val);

/* should be OK */
EXPLAIN (COSTS OFF)
WITH q1 AS (SELECT * FROM ONLY test_only.from_only_test)
SELECT * FROM test_only.from_only_test JOIN q1 USING(val);

/* should be OK */
EXPLAIN (COSTS OFF)
SELECT * FROM test_only.from_only_test
WHERE val = (SELECT val FROM ONLY test_only.from_only_test
			 ORDER BY val ASC
			 LIMIT 1);



DROP SCHEMA test_only CASCADE;
DROP EXTENSION gogudb;

