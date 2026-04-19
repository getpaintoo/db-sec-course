# Практика 3. Настройка различных методов аутентификации

## Что покрывает решение

- поиск и проверку путей к конфигурационным файлам PostgreSQL;
- создание пользователей с `md5` и `scram-sha-256`;
- лабораторную конфигурацию `pg_hba.conf` для `trust`, `md5`, `scram-sha-256`;
- включение логирования подключений;
- production-вариант `pg_hba.production.conf`.

## Файлы

- `setup.sql` — создает тестовых пользователей и включает настройки логирования;
- `verify.sql` — показывает конфиги, типы хешей и параметры логирования;
- `00_setup.sql` и `01_check.sql` — совместимые обертки для старых команд;
- `pg_hba.production.conf` — безопасный вариант конфигурации для отчета.

## Запуск

```bash
docker compose up -d
docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/03_authentication/setup.sql
docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/03_authentication/verify.sql
```

## Примеры ручных проверок

```bash
docker compose exec db bash -lc "PGPASSWORD='' psql -h 127.0.0.1 -U user_scram -d postgres -c 'select current_user;'"
docker compose exec db bash -lc "PGPASSWORD='SecurePass123!' psql -h 127.0.0.1 -U user_md5 -d postgres -c 'select current_user;'"
docker compose exec db bash -lc "PGPASSWORD='NewSecurePassword789!' psql -h 127.0.0.1 -U user_alice -d postgres -c 'select current_user;'"
```

## Отчет

Краткий текстовый отчет вынесен в `theory/03_authentication_report.md`.
