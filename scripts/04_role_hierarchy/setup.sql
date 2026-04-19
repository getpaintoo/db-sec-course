\echo === PRACTICE 4 / ROLE HIERARCHY SETUP ===
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
DROP ROLE IF EXISTS app_read_all;
DROP ROLE IF EXISTS app_full_access;
DROP ROLE IF EXISTS app_access_log_write;
DROP ROLE IF EXISTS app_history_full;
DROP ROLE IF EXISTS app_project_write;
DROP ROLE IF EXISTS app_task_write;
DROP ROLE IF EXISTS app_comments_full;
DROP ROLE IF EXISTS app_read_main;
DROP ROLE IF EXISTS app_admin;
DROP ROLE IF EXISTS app_manager;
DROP ROLE IF EXISTS app_user;
DROP ROLE IF EXISTS app_superuser;
DROP ROLE IF EXISTS app_audit_read;
DROP ROLE IF EXISTS app_history_read;
DROP ROLE IF EXISTS app_internal_comments;
DROP ROLE IF EXISTS app_task_worker;
DROP ROLE IF EXISTS app_read_reference;
DROP ROLE IF EXISTS app_employee;
DROP ROLE IF EXISTS app_guest;
DROP ROLE IF EXISTS app_connect;

CREATE DATABASE corporate_tasks;
\connect corporate_tasks

\i /workspace/scripts/common/corporate_tasks_schema.sql
\i /workspace/scripts/common/corporate_tasks_seed.sql

CREATE ROLE app_connect NOLOGIN;
GRANT CONNECT ON DATABASE corporate_tasks TO app_connect;
GRANT USAGE ON SCHEMA app TO app_connect;

CREATE ROLE app_read_reference NOLOGIN;
GRANT SELECT ON TABLE app.departments TO app_read_reference;
GRANT SELECT ON TABLE app.positions TO app_read_reference;

CREATE ROLE app_task_worker NOLOGIN;
GRANT SELECT ON TABLE app.projects TO app_task_worker;
GRANT SELECT ON TABLE app.tasks TO app_task_worker;
GRANT SELECT (user_id, username, email, full_name, department_id, position_id, is_active, created_at, updated_at)
    ON TABLE app.users TO app_task_worker;
GRANT INSERT ON TABLE app.comments TO app_task_worker;
GRANT USAGE, SELECT ON SEQUENCE app.comments_comment_id_seq TO app_task_worker;

CREATE ROLE app_internal_comments NOLOGIN;
GRANT SELECT, UPDATE ON TABLE app.comments TO app_internal_comments;

CREATE ROLE app_history_read NOLOGIN;
GRANT SELECT, INSERT ON TABLE app.task_history TO app_history_read;
GRANT USAGE, SELECT ON SEQUENCE app.task_history_history_id_seq TO app_history_read;

CREATE ROLE app_audit_read NOLOGIN;
GRANT SELECT ON TABLE app.access_logs TO app_audit_read;

CREATE ROLE app_read_all NOLOGIN;
GRANT app_connect TO app_read_all;
GRANT SELECT ON ALL TABLES IN SCHEMA app TO app_read_all;

CREATE ROLE app_user NOLOGIN;
GRANT app_connect TO app_user;
GRANT app_read_reference TO app_user;
GRANT app_task_worker TO app_user;

CREATE ROLE app_manager NOLOGIN;
GRANT app_user TO app_manager;
GRANT app_internal_comments TO app_manager;
GRANT app_history_read TO app_manager;
GRANT SELECT ON TABLE app.users TO app_manager;
GRANT SELECT, INSERT, UPDATE ON TABLE app.projects TO app_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE app.tasks TO app_manager;
GRANT SELECT, INSERT, UPDATE ON TABLE app.comments TO app_manager;
GRANT USAGE, SELECT ON SEQUENCE app.projects_project_id_seq TO app_manager;
GRANT USAGE, SELECT ON SEQUENCE app.tasks_task_id_seq TO app_manager;

CREATE ROLE app_admin NOLOGIN;
GRANT app_manager TO app_admin;
GRANT app_audit_read TO app_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app TO app_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app TO app_admin;
GRANT CREATE ON SCHEMA app TO app_admin;

CREATE ROLE dev_alice LOGIN PASSWORD 'AliceDev123!';
CREATE ROLE pm_bob LOGIN PASSWORD 'BobPM456!';
CREATE ROLE dev_charlie LOGIN PASSWORD 'CharlieDev789!';
CREATE ROLE admin_diana LOGIN PASSWORD 'DianaAdmin012!' CREATEDB CREATEROLE;
CREATE ROLE marketing_eve LOGIN PASSWORD 'EveMarket345!';

GRANT app_user TO dev_alice;
GRANT app_manager TO pm_bob;
GRANT app_user TO dev_charlie;
GRANT app_admin TO admin_diana;
GRANT app_read_all TO marketing_eve;

\echo Practice 4 database prepared
