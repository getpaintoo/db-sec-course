\echo === PRACTICE 5 / PRIVILEGES SETUP ===
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

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA app FROM app_user, app_manager, app_admin;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app FROM app_user, app_manager, app_admin;

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
GRANT SELECT, INSERT, UPDATE ON TABLE app.tasks TO app_task_write;
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

COMMENT ON ROLE app_connect IS 'Базовое подключение к corporate_tasks';
COMMENT ON ROLE app_read_reference IS 'Чтение справочников';
COMMENT ON ROLE app_read_main IS 'Чтение основных таблиц';
COMMENT ON ROLE app_comments_full IS 'Полный доступ к комментариям';
COMMENT ON ROLE app_task_write IS 'Чтение и изменение задач';
COMMENT ON ROLE app_project_write IS 'Чтение и изменение проектов';
COMMENT ON ROLE app_history_full IS 'Чтение и запись истории изменений';
COMMENT ON ROLE app_access_log_write IS 'Запись в журнал доступа';
COMMENT ON ROLE app_full_access IS 'Полный доступ ко всем объектам схемы app';

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

ALTER DEFAULT PRIVILEGES FOR ROLE app_admin IN SCHEMA app
GRANT SELECT ON TABLES TO app_read_reference;

ALTER DEFAULT PRIVILEGES FOR ROLE app_admin IN SCHEMA app
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_task_write;

ALTER DEFAULT PRIVILEGES FOR ROLE app_admin IN SCHEMA app
GRANT ALL ON TABLES TO app_full_access WITH GRANT OPTION;

ALTER DEFAULT PRIVILEGES FOR ROLE app_admin IN SCHEMA app
GRANT USAGE ON SEQUENCES TO app_task_write;

ALTER DEFAULT PRIVILEGES FOR ROLE app_admin IN SCHEMA app
GRANT ALL ON SEQUENCES TO app_full_access WITH GRANT OPTION;

\echo Practice 5 privileges configured
