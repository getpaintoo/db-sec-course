# Практика 5. Детальная настройка привилегий

Практика пересобирает доступ к `corporate_tasks` по принципу минимальных привилегий:

- вводит контейнерные роли `app_read_main`, `app_task_write`, `app_project_write` и другие;
- заново назначает права ролям `app_user`, `app_manager`, `app_admin`;
- настраивает `ALTER DEFAULT PRIVILEGES`;
- дает сценарии проверки для `dev_alice`, `pm_bob`, `admin_diana`.

## Запуск

```bash
docker compose up -d
docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/05_privileges/setup.sql
docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/05_privileges/verify.sql
```
