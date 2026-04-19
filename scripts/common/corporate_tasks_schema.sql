\echo === COMMON / CORPORATE TASKS SCHEMA ===

CREATE SCHEMA app;

CREATE TABLE app.departments (
    department_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE,
    description text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app.positions (
    position_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title text NOT NULL UNIQUE,
    level integer NOT NULL CHECK (level BETWEEN 1 AND 5),
    description text NOT NULL
);

CREATE TABLE app.users (
    user_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username text NOT NULL UNIQUE,
    email text NOT NULL UNIQUE,
    password_hash text NOT NULL,
    full_name text NOT NULL,
    department_id integer NOT NULL REFERENCES app.departments (department_id),
    position_id integer NOT NULL REFERENCES app.positions (position_id),
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app.projects (
    project_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE,
    description text NOT NULL,
    owner_id integer NOT NULL REFERENCES app.users (user_id),
    department_id integer NOT NULL REFERENCES app.departments (department_id),
    status text NOT NULL CHECK (status IN ('planning', 'active', 'paused', 'done')),
    budget numeric(12,2) NOT NULL CHECK (budget >= 0),
    start_date date NOT NULL,
    end_date date,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app.tasks (
    task_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id integer NOT NULL REFERENCES app.projects (project_id) ON DELETE CASCADE,
    title text NOT NULL,
    description text NOT NULL,
    status text NOT NULL CHECK (status IN ('todo', 'in_progress', 'review', 'done', 'cancelled')),
    priority integer NOT NULL CHECK (priority BETWEEN 1 AND 5),
    assignee_id integer NOT NULL REFERENCES app.users (user_id),
    created_by integer NOT NULL REFERENCES app.users (user_id),
    estimated_hours numeric(6,2) NOT NULL DEFAULT 0 CHECK (estimated_hours >= 0),
    due_date date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app.comments (
    comment_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id integer NOT NULL REFERENCES app.tasks (task_id) ON DELETE CASCADE,
    user_id integer NOT NULL REFERENCES app.users (user_id),
    content text NOT NULL,
    is_internal boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE app.task_history (
    history_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id integer NOT NULL REFERENCES app.tasks (task_id) ON DELETE CASCADE,
    changed_by integer NOT NULL REFERENCES app.users (user_id),
    changed_at timestamptz NOT NULL DEFAULT now(),
    field_name text NOT NULL,
    old_value text,
    new_value text
);

CREATE TABLE app.access_logs (
    log_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id integer REFERENCES app.users (user_id),
    action_text text NOT NULL,
    resource_type text NOT NULL,
    resource_id integer,
    ip_address inet,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_projects_owner_id ON app.projects (owner_id);
CREATE INDEX idx_projects_department_id ON app.projects (department_id);
CREATE INDEX idx_tasks_project_id ON app.tasks (project_id);
CREATE INDEX idx_tasks_assignee_id ON app.tasks (assignee_id);
CREATE INDEX idx_comments_task_id ON app.comments (task_id);
CREATE INDEX idx_comments_user_id ON app.comments (user_id);
CREATE INDEX idx_users_department_id ON app.users (department_id);
