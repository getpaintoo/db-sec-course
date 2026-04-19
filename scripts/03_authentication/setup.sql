\echo === PRACTICE 3 / AUTHENTICATION SETUP ===
\set ON_ERROR_STOP on

DROP ROLE IF EXISTS testuser;
DROP ROLE IF EXISTS user_alice;
DROP ROLE IF EXISTS user_md5;
DROP ROLE IF EXISTS user_scram;

ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM SET log_disconnections = on;
ALTER SYSTEM SET log_line_prefix = '%m [%p] user=%u db=%d app=%a client=%h ';
SELECT pg_reload_conf();

SHOW password_encryption;

SET password_encryption = 'scram-sha-256';
CREATE ROLE user_scram LOGIN PASSWORD 'SecurePass123!';

SET password_encryption = 'md5';
CREATE ROLE user_md5 LOGIN PASSWORD 'SecurePass123!';

SET password_encryption = 'scram-sha-256';
CREATE ROLE user_alice LOGIN PASSWORD 'NewSecurePassword789!';

RESET password_encryption;

CREATE ROLE testuser LOGIN;

\echo Practice 3 users created: user_scram, user_md5, user_alice, testuser
