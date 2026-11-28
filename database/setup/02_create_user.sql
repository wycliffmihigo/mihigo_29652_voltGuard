

SET ECHO ON
SET LINESIZE 200


ALTER SESSION SET CONTAINER = tue_29652_mihigo_voltguard_db;
SHOW CON_NAME


CREATE USER mihigo_admin IDENTIFIED BY mihigo;
GRANT DBA TO mihigo_admin;

SELECT username, account_status FROM dba_users WHERE username = 'MIHIGO_ADMIN';
SELECT grantee, granted_role FROM dba_role_privs WHERE grantee = 'MIHIGO_ADMIN';


