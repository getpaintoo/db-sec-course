# Практика 2. Сравнительный анализ моделей и RBAC

Папка закрывает SQL-часть практики 2 с сайта: создание учебной БД `task_management`, ролей `app_guest`, `app_employee`, `app_manager`, `app_admin`, `app_superuser` и сценариев проверки доступа.

## Запуск

```bash
docker compose up -d
docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/02_access_models/setup.sql
docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/02_access_models/verify.sql
```

## Что внутри

- `setup.sql` — создает БД, схему, тестовые данные, роли и базовые RLS-политики;
- `verify.sql` — проверяет иерархию ролей и поведение доступа;
- `theory/02_access_models_comparison.md` — аналитическая часть;
- `theory/02_security_policy_task_management.md` — документ политики безопасности.
