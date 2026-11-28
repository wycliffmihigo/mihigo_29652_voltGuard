SELECT SYS_CONTEXT('USERENV','CON_NAME') AS pdb FROM dual;
SELECT username, default_tablespace, temporary_tablespace FROM dba_users WHERE username = 'MIHIGO_ADMIN';
SELECT tablespace_name, DECODE(max_bytes, -1, 'UNLIMITED', max_bytes) AS quota FROM dba_ts_quotas WHERE username = 'MIHIGO_ADMIN';