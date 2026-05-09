\set ON_ERROR_STOP on

\echo === PRACTICE 09 / SETUP ===

DROP SCHEMA IF EXISTS injection_lab CASCADE;
CREATE SCHEMA injection_lab;

REVOKE ALL ON SCHEMA injection_lab FROM PUBLIC;

CREATE TABLE injection_lab.users (
    user_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username text NOT NULL UNIQUE,
    password_hash text NOT NULL,
    role_name text NOT NULL CHECK (role_name IN ('user', 'manager', 'admin')),
    is_active boolean NOT NULL DEFAULT true
);

CREATE TABLE injection_lab.tasks (
    task_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title text NOT NULL,
    description text NOT NULL,
    status text NOT NULL CHECK (status IN ('new', 'in_progress', 'done', 'archived')),
    priority text NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    owner_username text NOT NULL REFERENCES injection_lab.users (username),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE injection_lab.audit_log (
    event_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_type text NOT NULL,
    details text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO injection_lab.users (username, password_hash, role_name, is_active) VALUES
    ('alice', 'demo-hash-alice', 'user', true),
    ('bob', 'demo-hash-bob', 'manager', true),
    ('admin', 'demo-hash-admin', 'admin', true),
    ('disabled_user', 'demo-hash-disabled', 'user', false);

INSERT INTO injection_lab.tasks (title, description, status, priority, owner_username, created_at) VALUES
    ('Проверить права доступа', 'Аудит ролей PostgreSQL', 'new', 'critical', 'bob', now() - interval '4 days'),
    ('Исправить поиск', 'Перевести запрос на параметры', 'in_progress', 'high', 'alice', now() - interval '3 days'),
    ('Ограничить роль приложения', 'Выдать только нужные права', 'new', 'medium', 'admin', now() - interval '2 days'),
    ('Проверить журналирование', 'Добавить события безопасности', 'done', 'medium', 'bob', now() - interval '1 day'),
    ('Архивная задача', 'Старый тестовый кейс', 'archived', 'low', 'alice', now());

INSERT INTO injection_lab.audit_log (event_type, details) VALUES
    ('setup', 'Практика 9: стенд SQL-инъекций подготовлен');

CREATE OR REPLACE FUNCTION injection_lab.vulnerable_login(
    p_username text,
    p_password_hash text
)
RETURNS TABLE (
    user_id integer,
    username text,
    role_name text
)
LANGUAGE plpgsql
AS $$
DECLARE
    sql text;
BEGIN
    sql := 'SELECT user_id, username, role_name FROM injection_lab.users ' ||
           'WHERE is_active = true ' ||
           'AND username = ''' || p_username || ''' ' ||
           'AND password_hash = ''' || p_password_hash || '''';

    RETURN QUERY EXECUTE sql;
END;
$$;

CREATE OR REPLACE FUNCTION injection_lab.safe_login(
    p_username text,
    p_password_hash text
)
RETURNS TABLE (
    user_id integer,
    username text,
    role_name text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = injection_lab, pg_temp
AS $$
    SELECT user_id, username, role_name
    FROM users
    WHERE is_active = true
      AND username = p_username
      AND password_hash = p_password_hash;
$$;

CREATE OR REPLACE FUNCTION injection_lab.vulnerable_tasks_by_status(
    p_status text
)
RETURNS TABLE (
    task_id integer,
    title text,
    status text,
    priority text
)
LANGUAGE plpgsql
AS $$
DECLARE
    sql text;
BEGIN
    sql := 'SELECT task_id, title, status, priority FROM injection_lab.tasks ' ||
           'WHERE status = ''' || p_status || ''' ' ||
           'ORDER BY created_at DESC';

    RETURN QUERY EXECUTE sql;
END;
$$;

CREATE OR REPLACE FUNCTION injection_lab.safe_tasks_by_status(
    p_status text
)
RETURNS TABLE (
    task_id integer,
    title text,
    status text,
    priority text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = injection_lab, pg_temp
AS $$
    SELECT task_id, title, status, priority
    FROM tasks
    WHERE status = p_status
    ORDER BY created_at DESC;
$$;

CREATE OR REPLACE FUNCTION injection_lab.vulnerable_search_tasks(
    p_search text
)
RETURNS TABLE (
    task_id integer,
    title text,
    status text,
    priority text
)
LANGUAGE plpgsql
AS $$
DECLARE
    sql text;
BEGIN
    sql := 'SELECT task_id, title, status, priority FROM injection_lab.tasks ' ||
           'WHERE title ILIKE ''%' || p_search || '%'' ' ||
           'OR description ILIKE ''%' || p_search || '%'' ' ||
           'ORDER BY created_at DESC';

    RETURN QUERY EXECUTE sql;
END;
$$;

CREATE OR REPLACE FUNCTION injection_lab.safe_search_tasks(
    p_search text
)
RETURNS TABLE (
    task_id integer,
    title text,
    status text,
    priority text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = injection_lab, pg_temp
AS $$
    SELECT task_id, title, status, priority
    FROM tasks
    WHERE title ILIKE '%' || p_search || '%'
       OR description ILIKE '%' || p_search || '%'
    ORDER BY created_at DESC;
$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'injection_app') THEN
        CREATE ROLE injection_app NOLOGIN;
    END IF;
END
$$;

ALTER ROLE injection_app NOLOGIN PASSWORD NULL;

GRANT USAGE ON SCHEMA injection_lab TO injection_app;
REVOKE ALL ON ALL TABLES IN SCHEMA injection_lab FROM injection_app;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA injection_lab FROM PUBLIC;
GRANT EXECUTE ON FUNCTION injection_lab.safe_login(text, text) TO injection_app;
GRANT EXECUTE ON FUNCTION injection_lab.safe_tasks_by_status(text) TO injection_app;
GRANT EXECUTE ON FUNCTION injection_lab.safe_search_tasks(text) TO injection_app;

\echo === PRACTICE 09 / DONE ===
