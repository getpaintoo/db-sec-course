# Безопасность баз данных

Репозиторий собран по заданиям курса с сайта `db-sec.needcode.ru` и приведен к удобному для Git виду:

- теоретические отчеты лежат в `theory/`;
- практики с SQL лежат в `scripts/`;
- практики 4-6 связаны общей учебной БД `corporate_tasks`;
- практика 2 содержит отдельную учебную БД `task_management`;
- для практики 3 подготовлен лабораторный `pg_hba.conf` и безопасный production-вариант.

## Структура

- `theory/01_threat_classification.md` — практика 1, анализ угроз для учебной ИС.
- `theory/02_access_models_comparison.md` — практика 2, часть с анализом DAC/MAC/RBAC.
- `theory/02_security_policy_task_management.md` — политика безопасности для `task_management`.
- `theory/03_authentication_report.md` — краткий отчет по практике 3.
- `theory/04_role_hierarchy_policy.md` — политика ролей для `corporate_tasks`.
- `theory/05_privileges_report.md` — отчет по переработке привилегий.
- `theory/06_rls_report.md` — отчет по политике RLS.
- `scripts/02_access_models/` — практика 2, RBAC для `task_management`.
- `scripts/03_authentication/` — практика 3, аутентификация PostgreSQL.
- `scripts/04_role_hierarchy/` — практика 4, иерархия ролей.
- `scripts/05_privileges/` — практика 5, детальная настройка привилегий.
- `scripts/06_rls/` — практика 6, RLS.
- `scripts/common/` — общие SQL-файлы со схемой и тестовыми данными для `corporate_tasks`.

## Быстрый старт

```bash
docker compose up -d
docker compose exec -u postgres db psql -U postgres -d postgres -c "select version();"
```

## Команды по практикам

```bash
make p2
make p3
make p4
make p5
make p6
```

Эквивалентные команды через `docker compose exec` уже вынесены в `Makefile`.

## Что сдавать

- SQL-решения: `scripts/**/setup.sql` и `scripts/**/verify.sql`;
- README по каждой SQL-практике: соответствующая папка в `scripts/`;
- Markdown-отчеты: файлы в `theory/`.

## Примечание

Внутри этой среды нет локального `psql`, поэтому запуск идет через контейнер PostgreSQL из `docker-compose.yml`. Пуш в Git не выполнялся.
