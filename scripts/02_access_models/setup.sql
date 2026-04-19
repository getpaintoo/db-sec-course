\echo === PRACTICE 2 / TASK MANAGEMENT SETUP ===
\set ON_ERROR_STOP on

DROP DATABASE IF EXISTS task_management;
DROP DATABASE IF EXISTS corporate_tasks;

DROP ROLE IF EXISTS marketing_eve;
DROP ROLE IF EXISTS admin_diana;
DROP ROLE IF EXISTS dev_charlie;
DROP ROLE IF EXISTS pm_bob;
DROP ROLE IF EXISTS dev_alice;
DROP ROLE IF EXISTS eve;
DROP ROLE IF EXISTS diana;
DROP ROLE IF EXISTS charlie;
DROP ROLE IF EXISTS bob;
DROP ROLE IF EXISTS alice;
DROP ROLE IF EXISTS app_read_all;
DROP ROLE IF EXISTS app_full_access;
DROP ROLE IF EXISTS app_access_log_write;
DROP ROLE IF EXISTS app_history_full;
DROP ROLE IF EXISTS app_project_write;
DROP ROLE IF EXISTS app_task_write;
DROP ROLE IF EXISTS app_comments_full;
DROP ROLE IF EXISTS app_read_main;
DROP ROLE IF EXISTS app_audit_read;
DROP ROLE IF EXISTS app_history_read;
DROP ROLE IF EXISTS app_internal_comments;
DROP ROLE IF EXISTS app_task_worker;
DROP ROLE IF EXISTS app_read_reference;
DROP ROLE IF EXISTS app_superuser;
DROP ROLE IF EXISTS app_admin;
DROP ROLE IF EXISTS app_manager;
DROP ROLE IF EXISTS app_user;
DROP ROLE IF EXISTS app_employee;
DROP ROLE IF EXISTS app_guest;
DROP ROLE IF EXISTS app_connect;

CREATE DATABASE task_management;
\connect task_management

CREATE SCHEMA app;

CREATE TABLE app.users (
    user_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username text NOT NULL UNIQUE,
    email text NOT NULL UNIQUE,
    password_hash text NOT NULL,
    full_name text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app.projects (
    project_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE,
    description text NOT NULL,
    owner_id integer NOT NULL REFERENCES app.users (user_id),
    status text NOT NULL CHECK (status IN ('draft', 'active', 'done')),
    is_public boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app.tasks (
    task_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id integer NOT NULL REFERENCES app.projects (project_id) ON DELETE CASCADE,
    title text NOT NULL,
    description text NOT NULL,
    status text NOT NULL CHECK (status IN ('todo', 'in_progress', 'done')),
    priority integer NOT NULL CHECK (priority BETWEEN 1 AND 5),
    assignee_id integer REFERENCES app.users (user_id),
    created_by integer NOT NULL REFERENCES app.users (user_id),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app.comments (
    comment_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id integer NOT NULL REFERENCES app.tasks (task_id) ON DELETE CASCADE,
    user_id integer NOT NULL REFERENCES app.users (user_id),
    content text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app.task_history (
    history_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id integer NOT NULL REFERENCES app.tasks (task_id) ON DELETE CASCADE,
    changed_by integer NOT NULL REFERENCES app.users (user_id),
    field_name text NOT NULL,
    old_value text,
    new_value text,
    changed_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app.access_logs (
    log_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id integer REFERENCES app.users (user_id),
    action_text text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO app.users (username, email, password_hash, full_name) VALUES
('alice', 'alice@example.test', 'SCRAM-SHA-256$alice', 'Alice Johnson'),
('bob', 'bob@example.test', 'SCRAM-SHA-256$bob', 'Bob Smith'),
('charlie', 'charlie@example.test', 'SCRAM-SHA-256$charlie', 'Charlie Brown'),
('diana', 'diana@example.test', 'SCRAM-SHA-256$diana', 'Diana Prince'),
('eve', 'eve@example.test', 'SCRAM-SHA-256$eve', 'Eve Wilson');

INSERT INTO app.projects (name, description, owner_id, status, is_public) VALUES
('Website Refresh', 'Frontend and content refresh', 1, 'active', true),
('Internal CRM', 'New internal CRM implementation', 1, 'draft', false);

INSERT INTO app.tasks (project_id, title, description, status, priority, assignee_id, created_by) VALUES
(1, 'Prepare homepage wireframe', 'Landing page mockup', 'in_progress', 1, 2, 1),
(1, 'Update analytics tags', 'Replace old tracking code', 'todo', 3, 3, 1),
(1, 'Publish release checklist', 'Checklist for deployment', 'done', 2, 1, 1),
(2, 'Design database schema', 'Initial schema for CRM', 'todo', 1, 2, 1),
(2, 'Write API contract', 'Draft REST contract', 'todo', 2, 3, 1),
(2, 'Collect admin requirements', 'Security and audit requirements', 'in_progress', 2, 4, 1),
(2, 'Prepare marketing handoff', 'Campaign integration notes', 'todo', 4, 5, 1),
(1, 'Backlog grooming', 'Sort feature backlog', 'done', 4, 2, 1),
(2, 'Access review', 'Review role matrix', 'in_progress', 1, 4, 1),
(1, 'QA smoke check', 'Post-release smoke test', 'todo', 2, 3, 1);

INSERT INTO app.comments (task_id, user_id, content) VALUES
(1, 1, 'Please keep mobile layout in mind.'),
(1, 2, 'Wireframe draft is ready for review.'),
(4, 2, 'Need confirmation on custom fields.'),
(9, 4, 'Audit trail is mandatory.');

INSERT INTO app.task_history (task_id, changed_by, field_name, old_value, new_value) VALUES
(1, 2, 'status', 'todo', 'in_progress'),
(3, 1, 'status', 'in_progress', 'done'),
(9, 4, 'status', 'todo', 'in_progress');

INSERT INTO app.access_logs (user_id, action_text) VALUES
(1, 'alice signed in'),
(2, 'bob viewed Website Refresh'),
(4, 'diana reviewed audit records');

CREATE ROLE app_guest NOLOGIN;
CREATE ROLE app_employee NOLOGIN;
CREATE ROLE app_manager NOLOGIN;
CREATE ROLE app_admin NOLOGIN;
CREATE ROLE app_superuser NOLOGIN;

CREATE ROLE alice LOGIN PASSWORD 'AliceSecure123!';
CREATE ROLE bob LOGIN PASSWORD 'BobSecure456!';
CREATE ROLE charlie LOGIN PASSWORD 'CharlieSecure789!';
CREATE ROLE diana LOGIN PASSWORD 'DianaSecure012!';
CREATE ROLE eve LOGIN PASSWORD 'EveSecure345!';

GRANT CONNECT ON DATABASE task_management TO app_guest, app_employee, app_manager, app_admin, app_superuser;
GRANT USAGE ON SCHEMA app TO app_guest, app_employee, app_manager, app_admin, app_superuser;

GRANT app_guest TO app_employee;
GRANT app_employee TO app_manager;
GRANT app_manager TO app_admin;
GRANT app_admin TO app_superuser;

GRANT app_manager TO alice;
GRANT app_employee TO bob;
GRANT app_employee TO charlie;
GRANT app_admin TO diana;
GRANT app_superuser TO eve;

GRANT SELECT ON app.projects TO app_guest;

GRANT SELECT (user_id, username, email, full_name, created_at) ON app.users TO app_employee;
GRANT SELECT ON app.projects TO app_employee;
GRANT SELECT, INSERT, UPDATE ON app.tasks TO app_employee;
GRANT SELECT, INSERT ON app.comments TO app_employee;
GRANT USAGE, SELECT ON SEQUENCE app.comments_comment_id_seq TO app_employee;
GRANT USAGE, SELECT ON SEQUENCE app.tasks_task_id_seq TO app_employee;

GRANT SELECT, INSERT, UPDATE, DELETE ON app.projects TO app_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON app.tasks TO app_manager;
GRANT SELECT, INSERT, DELETE ON app.comments TO app_manager;
GRANT SELECT, INSERT ON app.task_history TO app_manager;
GRANT USAGE, SELECT ON SEQUENCE app.projects_project_id_seq TO app_manager;
GRANT USAGE, SELECT ON SEQUENCE app.task_history_history_id_seq TO app_manager;

GRANT SELECT, INSERT, UPDATE, DELETE ON app.users TO app_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app TO app_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app TO app_admin;
GRANT CREATE ON SCHEMA app TO app_admin;

GRANT ALL PRIVILEGES ON DATABASE task_management TO app_superuser;

ALTER TABLE app.projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY guest_projects_public
ON app.projects
FOR SELECT
TO app_guest
USING (is_public);

CREATE POLICY employee_projects_all
ON app.projects
FOR SELECT
TO app_employee
USING (true);

CREATE POLICY manager_projects_all
ON app.projects
FOR ALL
TO app_manager
USING (true)
WITH CHECK (true);

ALTER TABLE app.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY employee_tasks_select
ON app.tasks
FOR SELECT
TO app_employee
USING (
    assignee_id = (SELECT user_id FROM app.users WHERE username = current_user)
);

CREATE POLICY employee_tasks_insert
ON app.tasks
FOR INSERT
TO app_employee
WITH CHECK (
    assignee_id = (SELECT user_id FROM app.users WHERE username = current_user)
);

CREATE POLICY employee_tasks_update
ON app.tasks
FOR UPDATE
TO app_employee
USING (
    assignee_id = (SELECT user_id FROM app.users WHERE username = current_user)
)
WITH CHECK (
    assignee_id = (SELECT user_id FROM app.users WHERE username = current_user)
);

CREATE POLICY manager_tasks_all
ON app.tasks
FOR ALL
TO app_manager
USING (true)
WITH CHECK (true);

\echo Practice 2 database prepared
