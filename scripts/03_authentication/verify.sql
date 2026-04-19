\echo === PRACTICE 3 / AUTHENTICATION VERIFY ===
\set ON_ERROR_STOP off

\echo --- config paths ---
SHOW hba_file;
SHOW config_file;
SHOW data_directory;

\echo --- security settings ---
SHOW password_encryption;
SHOW log_connections;
SHOW log_disconnections;
SHOW log_line_prefix;

\echo --- user hash types ---
SELECT
    usename,
    CASE
        WHEN passwd LIKE 'md5%' THEN 'md5'
        WHEN passwd LIKE 'SCRAM-SHA-256%' THEN 'scram-sha-256'
        WHEN passwd IS NULL THEN 'no password'
        ELSE 'unknown'
    END AS password_type,
    left(passwd, 20) AS hash_prefix
FROM pg_shadow
WHERE usename IN ('user_scram', 'user_md5', 'user_alice', 'testuser')
ORDER BY usename;

\echo --- lab queries for audit ---
SELECT name, setting
FROM pg_settings
WHERE name IN ('hba_file', 'config_file', 'data_directory')
ORDER BY name;
