alter session set "_ORACLE_SCRIPT"=true;  

--
-- This script is a SAMPLE and can be modified as appropriate by the
-- customer as long as the equivalent tables and indexes are created.
-- The database name, user, and password must match those defined in
-- iiq.properties in the IdentityIQ installation.
--

--
-- The DATAFILE location must be modified to match your environment.
-- Because of this, these commands are commented out in this script.
--
-- 
CREATE BIGFILE TABLESPACE identityiq_ts
DATAFILE '/tmp/identityiq.dbf' SIZE 1G 
   AUTOEXTEND ON NEXT 512M MAXSIZE UNLIMITED
   EXTENT MANAGEMENT LOCAL;

CREATE USER identityiq IDENTIFIED BY identityiq
    DEFAULT TABLESPACE identityiq_ts
    QUOTA UNLIMITED ON identityiq_ts;

GRANT CREATE SESSION to identityiq;
GRANT CREATE TABLE to identityiq;


--
-- The DATAFILE location must be modified to match your environment.
-- Because of this, these commands are commented out in this script.
--
--
CREATE BIGFILE TABLESPACE identityiqPlugin_ts
DATAFILE '/tmp/identityiqPlugin.dbf' SIZE 128M
   AUTOEXTEND ON NEXT 128M MAXSIZE UNLIMITED
   EXTENT MANAGEMENT LOCAL;

CREATE USER identityiqPlugin IDENTIFIED BY identityiqPlugin
    DEFAULT TABLESPACE identityiqPlugin_ts
    QUOTA UNLIMITED ON identityiqPlugin_ts;

GRANT CREATE SESSION to identityiqPlugin;
GRANT CREATE TABLE to identityiqPlugin;
--
-- A hint submitted by a user: Oracle DB MUST be created as "shared" and the
-- job_queue_processes parameter  must be greater than 2, otherwise a DB lock
-- will happen.   However, these settings are pretty much standard after any
-- Oracle install, so most users need not worry about this.
--
-- IdentityIQ NOTES
--
-- Since things like Application names can make their way into TaskSchedule
-- object names we have to be careful with the sizes of various Quartz name
-- columns.  The original size was 80, this has been raised to 2000.  The
-- maximum size of a varchar2 in Oracle is 4000.
--
