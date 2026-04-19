\echo === PRACTICE 6 / VERIFY ===
\set ON_ERROR_STOP off
\connect corporate_tasks

\echo --- tables with RLS ---
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'app'
ORDER BY tablename;

\echo --- policies ---
SELECT tablename, policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'app'
ORDER BY tablename, policyname;

\echo --- dev_alice as app_user ---
SET ROLE dev_alice;
SELECT current_user, session_user;
SELECT task_id, title, assignee_id FROM app.tasks ORDER BY task_id;
SELECT user_id, username, full_name FROM app.users ORDER BY user_id;
SELECT comment_id, task_id, user_id, is_internal FROM app.comments ORDER BY comment_id;
SELECT project_id, name FROM app.projects ORDER BY project_id;
INSERT INTO app.tasks (project_id, title, description, status, priority, assignee_id, created_by, estimated_hours, due_date)
VALUES (1, 'RLS self task', 'Allowed task for own user', 'todo', 2, 1, 1, 1.00, '2026-05-02');
\echo expected: app_user cannot insert a task for another assignee
INSERT INTO app.tasks (project_id, title, description, status, priority, assignee_id, created_by, estimated_hours, due_date)
VALUES (1, 'RLS чужая task', 'Should fail', 'todo', 2, 2, 1, 1.00, '2026-05-02');
INSERT INTO app.comments (task_id, user_id, content, is_internal)
VALUES (2, 1, 'RLS public note', false);
\echo expected: app_user cannot create internal comments
INSERT INTO app.comments (task_id, user_id, content, is_internal)
VALUES (2, 1, 'RLS internal note', true);
RESET ROLE;

\echo --- pm_bob as app_manager ---
SET ROLE pm_bob;
SELECT current_user, session_user;
SELECT task_id, title, project_id, assignee_id FROM app.tasks ORDER BY task_id;
SELECT comment_id, is_internal FROM app.comments WHERE is_internal = true ORDER BY comment_id;
SELECT user_id, username, department_id FROM app.users ORDER BY user_id;
INSERT INTO app.tasks (project_id, title, description, status, priority, assignee_id, created_by, estimated_hours, due_date)
VALUES (1, 'RLS manager task', 'Manager can create in own project', 'todo', 2, 3, 2, 2.00, '2026-05-03');
INSERT INTO app.comments (task_id, user_id, content, is_internal)
VALUES (1, 2, 'Internal note from manager', true);
RESET ROLE;

\echo --- admin_diana as app_admin ---
SET ROLE admin_diana;
SELECT current_user, session_user;
SELECT COUNT(*) AS admin_tasks FROM app.tasks;
SELECT COUNT(*) AS admin_comments FROM app.comments;
SELECT COUNT(*) AS admin_projects FROM app.projects;
SELECT COUNT(*) AS admin_users FROM app.users;
UPDATE app.tasks SET status = 'cancelled' WHERE title = 'RLS manager task';
DELETE FROM app.comments WHERE content = 'RLS public note';
DELETE FROM app.comments WHERE content = 'Internal note from manager';
DELETE FROM app.tasks WHERE title IN ('RLS self task', 'RLS manager task');
RESET ROLE;

\echo --- explain analyze ---
SET ROLE dev_alice;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM app.tasks;
RESET ROLE;

SET ROLE admin_diana;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM app.tasks;
RESET ROLE;
