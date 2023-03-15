-- create replica user
CREATE ROLE replicauser LOGIN REPLICATION ENCRYPTED PASSWORD 'rep-user-pass';
-- check cluster stats
SELECT pid, usename, application_name, backend_start, state, sync_state, reply_time
FROM pg_stat_replication;