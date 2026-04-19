# Практика 6. Реализация RLS для `corporate_tasks`

Практика продолжает настройку `corporate_tasks` после детальной раздачи привилегий и включает RLS на:

- `app.tasks`
- `app.comments`
- `app.projects`
- `app.users`

## Запуск

```bash
docker compose up -d
docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/06_rls/setup.sql
docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/06_rls/verify.sql
```

## Отчет

Краткое описание политики вынесено в `theory/06_rls_report.md`.
