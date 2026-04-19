\echo === PRACTICE 4 / VERIFY ===
\set ON_ERROR_STOP off
\connect corporate_tasks

\echo --- role membership ---
SELECT r.rolname AS role_name, m.rolname AS member_name
FROM pg_auth_members am
JOIN pg_roles r ON r.oid = am.roleid
JOIN pg_roles m ON m.oid = am.member
WHERE r.rolname LIKE 'app_%'
ORDER BY r.rolname, m.rolname;

\echo --- dev_alice as app_user ---
SET ROLE dev_alice;
SELECT current_user, session_user;
SELECT * FROM app.departments ORDER BY department_id;
SELECT * FROM app.positions ORDER BY position_id;
SELECT task_id, title, status FROM app.tasks ORDER BY task_id LIMIT 5;
INSERT INTO app.comments (task_id, user_id, content, is_internal)
VALUES (2, 1, 'Comment from app_user', false);
\echo expected: app_user cannot update tasks directly
UPDATE app.tasks SET status = 'done' WHERE task_id = 2;
\echo expected: app_user cannot read audit log
SELECT * FROM app.access_logs;
RESET ROLE;

\echo --- pm_bob as app_manager ---
SET ROLE pm_bob;
SELECT current_user, session_user;
SELECT username, email, full_name FROM app.users ORDER BY user_id;
SELECT * FROM app.task_history ORDER BY history_id;
INSERT INTO app.projects (name, description, owner_id, department_id, status, budget, start_date, end_date)
VALUES ('P4 temp project', 'Created during manager verification', 2, 1, 'planning', 1000.00, '2026-04-19', '2026-05-19');
INSERT INTO app.tasks (project_id, title, description, status, priority, assignee_id, created_by, estimated_hours, due_date)
VALUES (
    (SELECT project_id FROM app.projects WHERE name = 'P4 temp project'),
    'P4 temp task',
    'Task created by manager',
    'todo',
    3,
    2,
    2,
    2.00,
    '2026-05-01'
);
UPDATE app.tasks SET status = 'in_progress' WHERE title = 'P4 temp task';
DELETE FROM app.tasks WHERE title = 'P4 temp task';
\echo expected: manager cannot delete projects in practice 4
DELETE FROM app.projects WHERE name = 'P4 temp project';
\echo expected: manager cannot read audit log
SELECT * FROM app.access_logs;
RESET ROLE;

\echo --- admin_diana as app_admin ---
SET ROLE admin_diana;
SELECT current_user, session_user;
SELECT * FROM app.access_logs ORDER BY log_id;
UPDATE app.users SET is_active = false WHERE username = 'marketing_eve';
UPDATE app.users SET is_active = true WHERE username = 'marketing_eve';
DELETE FROM app.comments WHERE content = 'Comment from app_user';
DELETE FROM app.projects WHERE name = 'P4 temp project';
CREATE TABLE app.p4_admin_check (id integer);
ALTER TABLE app.p4_admin_check ADD COLUMN note text;
DROP TABLE app.p4_admin_check;
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('app_user', 'app_manager', 'app_admin')
ORDER BY grantee, table_name, privilege_type;
RESET ROLE;
