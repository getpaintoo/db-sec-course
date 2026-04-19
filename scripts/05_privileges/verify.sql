\echo === PRACTICE 5 / VERIFY ===
\set ON_ERROR_STOP off
\connect corporate_tasks

\echo --- audit current grants ---
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'app'
  AND grantee IN (
      'app_user',
      'app_manager',
      'app_admin',
      'app_connect',
      'app_read_reference',
      'app_read_main',
      'app_comments_full',
      'app_task_write',
      'app_project_write',
      'app_history_full',
      'app_access_log_write',
      'app_full_access'
  )
ORDER BY grantee, table_name, privilege_type;

\echo --- explicit privilege checks ---
SELECT
    has_table_privilege('app_user', 'app.tasks', 'SELECT') AS app_user_tasks_select,
    has_table_privilege('app_user', 'app.tasks', 'DELETE') AS app_user_tasks_delete,
    has_table_privilege('app_manager', 'app.projects', 'DELETE') AS app_manager_projects_delete,
    has_table_privilege('app_admin', 'app.access_logs', 'SELECT') AS app_admin_access_logs_select,
    has_schema_privilege('app_admin', 'app', 'CREATE') AS app_admin_schema_create;

\echo --- dev_alice as app_user ---
SET ROLE dev_alice;
SELECT current_user, session_user;
SELECT * FROM app.departments ORDER BY department_id;
SELECT user_id, username, email, full_name FROM app.users ORDER BY user_id;
SELECT task_id, title, status FROM app.tasks ORDER BY task_id LIMIT 5;
INSERT INTO app.tasks (project_id, title, description, status, priority, assignee_id, created_by, estimated_hours, due_date)
VALUES (1, 'P5 user task', 'Created during privileges check', 'todo', 3, 1, 1, 1.50, '2026-05-01');
UPDATE app.tasks SET status = 'in_progress' WHERE title = 'P5 user task';
\echo expected: app_user has no DELETE on app.tasks
DELETE FROM app.tasks WHERE title = 'P5 user task';
INSERT INTO app.comments (task_id, user_id, content, is_internal)
VALUES (2, 1, 'P5 comment from app_user', false);
INSERT INTO app.access_logs (user_id, action_text, resource_type, resource_id, ip_address)
VALUES (1, 'dev_alice wrote audit record', 'task', 2, '127.0.0.1');
\echo expected: app_user can write audit records but cannot read them
SELECT * FROM app.access_logs;
RESET ROLE;

\echo --- pm_bob as app_manager ---
SET ROLE pm_bob;
SELECT current_user, session_user;
INSERT INTO app.projects (name, description, owner_id, department_id, status, budget, start_date, end_date)
VALUES ('P5 manager project', 'Temporary manager project', 2, 1, 'planning', 2000.00, '2026-04-19', '2026-05-19');
UPDATE app.projects SET description = 'Updated by manager' WHERE name = 'P5 manager project';
DELETE FROM app.projects WHERE name = 'P5 manager project';
SELECT * FROM app.task_history ORDER BY history_id;
RESET ROLE;

\echo --- default privileges created by app_admin ---
SET ROLE app_admin;
CREATE TABLE app.test_default_privileges (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL
);
RESET ROLE;

SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'app'
  AND table_name = 'test_default_privileges'
ORDER BY grantee, privilege_type;

SET ROLE dev_alice;
SELECT * FROM app.test_default_privileges;
INSERT INTO app.test_default_privileges (name) VALUES ('visible to app_user');
RESET ROLE;

SET ROLE admin_diana;
GRANT SELECT ON TABLE app.access_logs TO app_manager;
REVOKE SELECT ON TABLE app.access_logs FROM app_manager;
DELETE FROM app.comments WHERE content = 'P5 comment from app_user';
DELETE FROM app.access_logs WHERE action_text = 'dev_alice wrote audit record';
DELETE FROM app.tasks WHERE title = 'P5 user task';
RESET ROLE;

SET ROLE app_admin;
DROP TABLE app.test_default_privileges;
RESET ROLE;
