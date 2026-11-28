-- ============================================================
-- Name:        Mihigo Wycliff
-- Student ID:  29652
-- Group:       Tuesday
-- Project:     VoltGuard Rwanda: Electricity Billing and Meter Tamper Monitor
-- Script:      04_archive_log.sql
-- Run as:      SYS AS SYSDBA, connected to the container database (CDB$ROOT)
-- ============================================================

SET ECHO ON
SET LINESIZE 200

-- Task 4: show the current archive log mode.
SELECT name, log_mode FROM v$database;
SELECT instance_name, archiver FROM v$instance;

-- Why archive logging cannot be enabled for a single PDB:
-- All pluggable databases in a container share one instance, one set of control files
-- and one redo log stream. Archiving copies that shared redo, so the mode belongs to the
-- container (CDB) and is changed only from the root with SYSDBA while the CDB is
-- mounted, which needs a restart of the whole CDB. A PDB cannot have its own setting.

-- RUN THE FOLLOWING ONLY ON YOUR OWN LOCAL INSTALLATION, NEVER ON THE SHARED LAB SERVER.
SHUTDOWN IMMEDIATE
STARTUP MOUNT
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

-- Check again.
SELECT name, log_mode FROM v$database;
