# Практика 4. Иерархия ролей для `corporate_tasks`

Практика создает учебную БД `corporate_tasks`, базовую схему `app`, тестовые данные и ролевую модель:

- `app_user` — обычный сотрудник;
- `app_manager` — менеджер проекта;
- `app_admin` — администратор;
- контейнерные роли для подключения, справочников, истории и аудита.

## Запуск

```bash
docker compose up -d
docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/04_role_hierarchy/setup.sql
docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/04_role_hierarchy/verify.sql
```

## Связанные материалы

- `theory/04_role_hierarchy_policy.md`
- `scripts/common/corporate_tasks_schema.sql`
- `scripts/common/corporate_tasks_seed.sql`
