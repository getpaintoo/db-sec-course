\echo === COMMON / CORPORATE TASKS SEED ===

INSERT INTO app.departments (name, description) VALUES
('IT', 'Разработка и сопровождение'),
('Marketing', 'Маркетинг и коммуникации'),
('Sales', 'Продажи'),
('Administration', 'Администрирование и безопасность');

INSERT INTO app.positions (title, level, description) VALUES
('Intern', 1, 'Стажер'),
('Specialist', 2, 'Специалист'),
('Senior Specialist', 3, 'Старший специалист'),
('Manager', 4, 'Менеджер'),
('Administrator', 5, 'Администратор системы');

INSERT INTO app.users (username, email, password_hash, full_name, department_id, position_id) VALUES
('dev_alice', 'alice@company.test', 'SCRAM-SHA-256$alice', 'Alice Johnson', 1, 2),
('pm_bob', 'bob@company.test', 'SCRAM-SHA-256$bob', 'Bob Smith', 1, 4),
('dev_charlie', 'charlie@company.test', 'SCRAM-SHA-256$charlie', 'Charlie Brown', 1, 3),
('admin_diana', 'diana@company.test', 'SCRAM-SHA-256$diana', 'Diana Prince', 4, 5),
('marketing_eve', 'eve@company.test', 'SCRAM-SHA-256$eve', 'Eve Wilson', 2, 2);

INSERT INTO app.projects (name, description, owner_id, department_id, status, budget, start_date, end_date) VALUES
('Platform Refresh', 'Обновление внутренней платформы', 2, 1, 'active', 120000.00, '2026-01-10', '2026-06-30'),
('Q2 Campaign', 'Маркетинговая кампания второго квартала', 5, 2, 'active', 45000.00, '2026-03-01', '2026-05-31'),
('Access Review', 'Проверка ролей, привилегий и аудита', 4, 4, 'planning', 30000.00, '2026-04-01', '2026-06-15');

INSERT INTO app.tasks (project_id, title, description, status, priority, assignee_id, created_by, estimated_hours, due_date) VALUES
(1, 'Собрать требования по редизайну', 'Список требований по интерфейсу', 'done', 2, 2, 2, 8.00, '2026-01-20'),
(1, 'Подготовить макет новой панели', 'Wireframe для новой панели', 'in_progress', 1, 1, 2, 24.00, '2026-04-25'),
(1, 'Обновить CI/CD pipeline', 'Усилить автоматические проверки', 'todo', 2, 3, 2, 16.00, '2026-05-02'),
(1, 'Проверить доступы к staging', 'Сверить роли и учетные записи', 'review', 3, 2, 4, 10.00, '2026-04-28'),
(2, 'Сформировать контент-план', 'Контентный план на Q2', 'in_progress', 2, 5, 5, 12.00, '2026-04-24'),
(2, 'Подготовить баннеры', 'Графика для email-рассылки', 'todo', 3, 5, 5, 14.00, '2026-04-29'),
(2, 'Согласовать UTM-метки', 'Параметры аналитики кампании', 'todo', 4, 2, 5, 6.00, '2026-04-30'),
(3, 'Провести аудит ролей', 'Проверка ролевой модели', 'in_progress', 1, 4, 4, 20.00, '2026-05-05'),
(3, 'Пересмотреть матрицу привилегий', 'Актуализация GRANT/REVOKE', 'todo', 1, 4, 4, 18.00, '2026-05-08'),
(3, 'Подготовить RLS-политики', 'Черновик политик построчного доступа', 'todo', 2, 1, 4, 12.00, '2026-05-10');

INSERT INTO app.comments (task_id, user_id, content, is_internal) VALUES
(2, 2, 'Нужен акцент на мобильной версии.', false),
(2, 1, 'Сделаю две альтернативы к вечеру.', false),
(3, 2, 'Внутренняя заметка для DevOps.', true),
(5, 5, 'Контент-план согласован с командой.', false),
(8, 4, 'В аудит обязательно включить логирование подключений.', true),
(10, 1, 'Для RLS потребуется функция current user -> user_id.', false);

INSERT INTO app.task_history (task_id, changed_by, field_name, old_value, new_value) VALUES
(1, 2, 'status', 'in_progress', 'done'),
(2, 1, 'status', 'todo', 'in_progress'),
(4, 2, 'status', 'todo', 'review'),
(8, 4, 'status', 'todo', 'in_progress');

INSERT INTO app.access_logs (user_id, action_text, resource_type, resource_id, ip_address) VALUES
(1, 'dev_alice viewed task', 'task', 2, '127.0.0.1'),
(2, 'pm_bob updated project', 'project', 1, '127.0.0.1'),
(4, 'admin_diana reviewed audit logs', 'access_logs', 1, '127.0.0.1'),
(5, 'marketing_eve opened campaign dashboard', 'project', 2, '127.0.0.1');
