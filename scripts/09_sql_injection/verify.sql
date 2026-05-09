\set ON_ERROR_STOP on

\echo === PRACTICE 09 / VERIFY ===

\echo --- Objects in injection_lab
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'injection_lab'
ORDER BY table_name;

\echo --- Baseline data
SELECT status, count(*) AS task_count
FROM injection_lab.tasks
GROUP BY status
ORDER BY status;

\echo --- Login bypass: vulnerable function returns users, safe function returns zero rows
SELECT 'vulnerable_login_payload' AS check_name, count(*) AS returned_rows
FROM injection_lab.vulnerable_login('alice'' OR ''1''=''1'' --', 'wrong-hash');

SELECT 'safe_login_payload' AS check_name, count(*) AS returned_rows
FROM injection_lab.safe_login('alice'' OR ''1''=''1'' --', 'wrong-hash');

\echo --- Status filter injection: vulnerable query expands result set, safe query treats payload as data
SELECT 'safe_status_new' AS check_name, count(*) AS returned_rows
FROM injection_lab.safe_tasks_by_status('new');

SELECT 'vulnerable_status_payload' AS check_name, count(*) AS returned_rows
FROM injection_lab.vulnerable_tasks_by_status('new'' OR ''1''=''1');

SELECT 'safe_status_payload' AS check_name, count(*) AS returned_rows
FROM injection_lab.safe_tasks_by_status('new'' OR ''1''=''1');

\echo --- Text search injection: vulnerable search is bypassed, safe search is not
SELECT 'vulnerable_search_payload' AS check_name, count(*) AS returned_rows
FROM injection_lab.vulnerable_search_tasks('x%'' OR ''1''=''1'' --');

SELECT 'safe_search_payload' AS check_name, count(*) AS returned_rows
FROM injection_lab.safe_search_tasks('x%'' OR ''1''=''1'' --');

\echo --- Least privilege for application role
SELECT
    has_schema_privilege('injection_app', 'injection_lab', 'USAGE') AS can_use_schema,
    has_table_privilege('injection_app', 'injection_lab.users', 'SELECT') AS can_select_users,
    has_table_privilege('injection_app', 'injection_lab.tasks', 'SELECT') AS can_select_tasks,
    has_function_privilege('injection_app', 'injection_lab.safe_login(text, text)', 'EXECUTE') AS can_execute_safe_login,
    has_function_privilege('injection_app', 'injection_lab.vulnerable_login(text, text)', 'EXECUTE') AS can_execute_vulnerable_login;

\echo --- Running as injection_app through safe SECURITY DEFINER function
SET ROLE injection_app;
SELECT count(*) AS visible_new_tasks
FROM injection_lab.safe_tasks_by_status('new');
RESET ROLE;
