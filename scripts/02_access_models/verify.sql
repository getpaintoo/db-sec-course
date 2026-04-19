\echo === PRACTICE 2 / VERIFY ===
\set ON_ERROR_STOP off
\connect task_management

\echo --- role membership ---
SELECT r.rolname AS role_name, m.rolname AS member_name
FROM pg_auth_members am
JOIN pg_roles r ON r.oid = am.roleid
JOIN pg_roles m ON m.oid = am.member
WHERE r.rolname LIKE 'app_%'
ORDER BY r.rolname, m.rolname;

\echo --- privilege summary ---
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'app'
  AND grantee IN ('app_guest', 'app_employee', 'app_manager', 'app_admin', 'app_superuser')
ORDER BY grantee, table_name, privilege_type;

\echo --- guest can read only projects ---
SET ROLE app_guest;
SELECT current_user, session_user;
SELECT project_id, name, is_public FROM app.projects ORDER BY project_id;
\echo expected: app_guest has no access to app.tasks
SELECT * FROM app.tasks;
RESET ROLE;

\echo --- bob as employee sees only own tasks via RLS ---
SET ROLE bob;
SELECT current_user, session_user;
SELECT task_id, title, assignee_id FROM app.tasks ORDER BY task_id;
INSERT INTO app.tasks (project_id, title, description, status, priority, assignee_id, created_by)
VALUES (
    1,
    'Bob self task',
    'Employee can add only own tasks',
    'todo',
    2,
    (SELECT user_id FROM app.users WHERE username = current_user),
    1
);
\echo expected: employee cannot create tasks for another assignee
INSERT INTO app.tasks (project_id, title, description, status, priority, assignee_id, created_by)
VALUES (1, 'Bob чужая задача', 'should fail', 'todo', 2, 1, 1);
RESET ROLE;

\echo --- alice as manager sees all tasks and can delete temp row ---
SET ROLE alice;
SELECT current_user, session_user;
SELECT COUNT(*) AS manager_visible_tasks FROM app.tasks;
DELETE FROM app.tasks WHERE title = 'Bob self task';
RESET ROLE;

\echo --- diana as admin can manage users ---
SET ROLE diana;
SELECT current_user, session_user;
UPDATE app.users SET full_name = 'Bob Smith Updated' WHERE username = 'bob';
UPDATE app.users SET full_name = 'Bob Smith' WHERE username = 'bob';
CREATE TABLE app.p2_admin_check (id integer);
DROP TABLE app.p2_admin_check;
RESET ROLE;
