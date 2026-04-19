up:
	docker compose up -d

down:
	docker compose down

psql:
	docker compose exec -u postgres db psql -U postgres -d postgres

p2:
	docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/02_access_models/setup.sql
	docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/02_access_models/verify.sql

p3:
	docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/03_authentication/setup.sql
	docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/03_authentication/verify.sql

p4:
	docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/04_role_hierarchy/setup.sql
	docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/04_role_hierarchy/verify.sql

p5:
	docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/05_privileges/setup.sql
	docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/05_privileges/verify.sql

p6:
	docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/06_rls/setup.sql
	docker compose exec -T -u postgres db psql -U postgres -d postgres -f /workspace/scripts/06_rls/verify.sql
