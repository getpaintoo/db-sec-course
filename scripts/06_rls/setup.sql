\echo === PRACTICE 6 / RLS SETUP ===
\set ON_ERROR_STOP on

DROP DATABASE IF EXISTS task_management;
DROP DATABASE IF EXISTS corporate_tasks;

DROP ROLE IF EXISTS eve;
DROP ROLE IF EXISTS diana;
DROP ROLE IF EXISTS charlie;
DROP ROLE IF EXISTS bob;
DROP ROLE IF EXISTS alice;
DROP ROLE IF EXISTS marketing_eve;
DROP ROLE IF EXISTS admin_diana;
DROP ROLE IF EXISTS dev_charlie;
DROP ROLE IF EXISTS pm_bob;
DROP ROLE IF EXISTS dev_alice;
DROP ROLE IF EXISTS app_admin;
DROP ROLE IF EXISTS app_manager;
DROP ROLE IF EXISTS app_user;
DROP ROLE IF EXISTS app_superuser;
DROP ROLE IF EXISTS app_read_all;
DROP ROLE IF EXISTS app_audit_read;
DROP ROLE IF EXISTS app_history_read;
DROP ROLE IF EXISTS app_internal_comments;
DROP ROLE IF EXISTS app_task_worker;
DROP ROLE IF EXISTS app_full_access;
DROP ROLE IF EXISTS app_access_log_write;
DROP ROLE IF EXISTS app_history_full;
DROP ROLE IF EXISTS app_project_write;
DROP ROLE IF EXISTS app_task_write;
DROP ROLE IF EXISTS app_comments_full;
DROP ROLE IF EXISTS app_read_main;
DROP ROLE IF EXISTS app_read_reference;
DROP ROLE IF EXISTS app_employee;
DROP ROLE IF EXISTS app_guest;
DROP ROLE IF EXISTS app_connect;

CREATE DATABASE corporate_tasks;
\connect corporate_tasks

\i /workspace/scripts/common/corporate_tasks_schema.sql
\i /workspace/scripts/common/corporate_tasks_seed.sql

CREATE ROLE app_user NOLOGIN;
CREATE ROLE app_manager NOLOGIN;
CREATE ROLE app_admin NOLOGIN;

CREATE ROLE app_connect NOLOGIN;
GRANT CONNECT ON DATABASE corporate_tasks TO app_connect;
GRANT USAGE ON SCHEMA app TO app_connect;

CREATE ROLE app_read_reference NOLOGIN;
GRANT SELECT ON TABLE app.departments TO app_read_reference;
GRANT SELECT ON TABLE app.positions TO app_read_reference;

CREATE ROLE app_read_main NOLOGIN;
GRANT SELECT (user_id, username, email, full_name, department_id, position_id, is_active, created_at, updated_at)
    ON TABLE app.users TO app_read_main;
GRANT SELECT ON TABLE app.projects TO app_read_main;
GRANT SELECT ON TABLE app.tasks TO app_read_main;

CREATE ROLE app_comments_full NOLOGIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app.comments TO app_comments_full;
GRANT USAGE, SELECT ON SEQUENCE app.comments_comment_id_seq TO app_comments_full;

CREATE ROLE app_task_write NOLOGIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app.tasks TO app_task_write;
GRANT SELECT ON TABLE app.projects TO app_task_write;
GRANT USAGE, SELECT ON SEQUENCE app.tasks_task_id_seq TO app_task_write;

CREATE ROLE app_project_write NOLOGIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app.projects TO app_project_write;
GRANT USAGE, SELECT ON SEQUENCE app.projects_project_id_seq TO app_project_write;

CREATE ROLE app_history_full NOLOGIN;
GRANT SELECT, INSERT ON TABLE app.task_history TO app_history_full;
GRANT USAGE, SELECT ON SEQUENCE app.task_history_history_id_seq TO app_history_full;

CREATE ROLE app_access_log_write NOLOGIN;
GRANT INSERT ON TABLE app.access_logs TO app_access_log_write;
GRANT USAGE, SELECT ON SEQUENCE app.access_logs_log_id_seq TO app_access_log_write;

CREATE ROLE app_full_access NOLOGIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app TO app_full_access WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app TO app_full_access WITH GRANT OPTION;
GRANT CREATE ON SCHEMA app TO app_full_access;

GRANT app_connect TO app_user;
GRANT app_read_reference TO app_user;
GRANT app_read_main TO app_user;
GRANT app_task_write TO app_user;
GRANT app_comments_full TO app_user;
GRANT app_history_full TO app_user;
GRANT app_access_log_write TO app_user;

GRANT app_user TO app_manager;
GRANT app_project_write TO app_manager;

GRANT app_manager TO app_admin;
GRANT app_full_access TO app_admin;

CREATE ROLE dev_alice LOGIN PASSWORD 'AliceDev123!';
CREATE ROLE pm_bob LOGIN PASSWORD 'BobPM456!';
CREATE ROLE dev_charlie LOGIN PASSWORD 'CharlieDev789!';
CREATE ROLE admin_diana LOGIN PASSWORD 'DianaAdmin012!' CREATEDB CREATEROLE;
CREATE ROLE marketing_eve LOGIN PASSWORD 'EveMarket345!';

GRANT app_user TO dev_alice;
GRANT app_manager TO pm_bob;
GRANT app_user TO dev_charlie;
GRANT app_admin TO admin_diana;
GRANT app_read_reference TO marketing_eve;
GRANT app_read_main TO marketing_eve;
GRANT app_connect TO marketing_eve;

CREATE TABLE app.role_directory (
    db_role name PRIMARY KEY,
    user_id integer NOT NULL UNIQUE REFERENCES app.users (user_id),
    department_id integer NOT NULL REFERENCES app.departments (department_id),
    is_manager boolean NOT NULL DEFAULT false,
    is_admin boolean NOT NULL DEFAULT false
);

INSERT INTO app.role_directory (db_role, user_id, department_id, is_manager, is_admin) VALUES
('dev_alice', 1, 1, false, false),
('pm_bob', 2, 1, true, false),
('dev_charlie', 3, 1, false, false),
('admin_diana', 4, 4, false, true),
('marketing_eve', 5, 2, false, false);

REVOKE ALL ON TABLE app.role_directory FROM PUBLIC;
GRANT SELECT ON TABLE app.role_directory TO app_user, app_manager, app_admin;

CREATE OR REPLACE FUNCTION app.get_current_user_id()
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = app, public
AS $$
    SELECT user_id
    FROM app.role_directory
    WHERE db_role = current_user
$$;

CREATE OR REPLACE FUNCTION app.get_current_department_id()
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = app, public
AS $$
    SELECT department_id
    FROM app.role_directory
    WHERE db_role = current_user
$$;

CREATE OR REPLACE FUNCTION app.is_project_manager(p_project_id integer)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = app, public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM app.projects p
        WHERE p.project_id = p_project_id
          AND p.owner_id = app.get_current_user_id()
    )
$$;

ALTER TABLE app.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY tasks_select_own
ON app.tasks
FOR SELECT
TO app_user
USING (assignee_id = app.get_current_user_id());

CREATE POLICY tasks_insert_own
ON app.tasks
FOR INSERT
TO app_user
WITH CHECK (assignee_id = app.get_current_user_id());

CREATE POLICY tasks_update_own
ON app.tasks
FOR UPDATE
TO app_user
USING (assignee_id = app.get_current_user_id())
WITH CHECK (assignee_id = app.get_current_user_id());

CREATE POLICY tasks_delete_own
ON app.tasks
FOR DELETE
TO app_user
USING (assignee_id = app.get_current_user_id());

CREATE POLICY tasks_select_managed
ON app.tasks
FOR SELECT
TO app_manager
USING (
    assignee_id = app.get_current_user_id()
    OR app.is_project_manager(project_id)
);

CREATE POLICY tasks_insert_managed
ON app.tasks
FOR INSERT
TO app_manager
WITH CHECK (
    assignee_id = app.get_current_user_id()
    OR app.is_project_manager(project_id)
);

CREATE POLICY tasks_update_managed
ON app.tasks
FOR UPDATE
TO app_manager
USING (
    assignee_id = app.get_current_user_id()
    OR app.is_project_manager(project_id)
)
WITH CHECK (
    assignee_id = app.get_current_user_id()
    OR app.is_project_manager(project_id)
);

CREATE POLICY tasks_delete_managed
ON app.tasks
FOR DELETE
TO app_manager
USING (
    assignee_id = app.get_current_user_id()
    OR app.is_project_manager(project_id)
);

CREATE POLICY tasks_admin_all
ON app.tasks
FOR ALL
TO app_admin
USING (true)
WITH CHECK (true);

ALTER TABLE app.comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY comments_user_read
ON app.comments
FOR SELECT
TO app_user
USING (
    user_id = app.get_current_user_id()
    OR (
        task_id IN (
            SELECT task_id
            FROM app.tasks
            WHERE assignee_id = app.get_current_user_id()
        )
        AND is_internal = false
    )
);

CREATE POLICY comments_user_insert
ON app.comments
FOR INSERT
TO app_user
WITH CHECK (
    task_id IN (
        SELECT task_id
        FROM app.tasks
        WHERE assignee_id = app.get_current_user_id()
    )
    AND user_id = app.get_current_user_id()
    AND is_internal = false
);

CREATE POLICY comments_user_update
ON app.comments
FOR UPDATE
TO app_user
USING (user_id = app.get_current_user_id())
WITH CHECK (
    user_id = app.get_current_user_id()
    AND is_internal = false
);

CREATE POLICY comments_user_delete
ON app.comments
FOR DELETE
TO app_user
USING (user_id = app.get_current_user_id());

CREATE POLICY comments_manager_read
ON app.comments
FOR SELECT
TO app_manager
USING (true);

CREATE POLICY comments_manager_insert
ON app.comments
FOR INSERT
TO app_manager
WITH CHECK (true);

CREATE POLICY comments_manager_update
ON app.comments
FOR UPDATE
TO app_manager
USING (true)
WITH CHECK (true);

CREATE POLICY comments_manager_delete
ON app.comments
FOR DELETE
TO app_manager
USING (true);

CREATE POLICY comments_admin_all
ON app.comments
FOR ALL
TO app_admin
USING (true)
WITH CHECK (true);

ALTER TABLE app.projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY projects_user_read
ON app.projects
FOR SELECT
TO app_user
USING (
    owner_id = app.get_current_user_id()
    OR project_id IN (
        SELECT project_id
        FROM app.tasks
        WHERE assignee_id = app.get_current_user_id()
    )
);

CREATE POLICY projects_manager_read
ON app.projects
FOR SELECT
TO app_manager
USING (
    owner_id = app.get_current_user_id()
    OR department_id = app.get_current_department_id()
);

CREATE POLICY projects_manager_write
ON app.projects
FOR ALL
TO app_manager
USING (owner_id = app.get_current_user_id())
WITH CHECK (owner_id = app.get_current_user_id());

CREATE POLICY projects_admin_all
ON app.projects
FOR ALL
TO app_admin
USING (true)
WITH CHECK (true);

ALTER TABLE app.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_self_read
ON app.users
FOR SELECT
TO app_user
USING (user_id = app.get_current_user_id());

CREATE POLICY users_self_update
ON app.users
FOR UPDATE
TO app_user
USING (user_id = app.get_current_user_id())
WITH CHECK (user_id = app.get_current_user_id());

CREATE POLICY users_department_read
ON app.users
FOR SELECT
TO app_manager
USING (
    department_id = app.get_current_department_id()
);

CREATE POLICY users_admin_all
ON app.users
FOR ALL
TO app_admin
USING (true)
WITH CHECK (true);

\echo Practice 6 RLS configured
