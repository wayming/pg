#!/bin/bash
# Run as postgres
set -x
dbusr=test
dbpwd=test
dbname=testdb

psql <<END
CREATE USER $dbusr WITH PASSWORD '$dbpwd' CREATEROLE CREATEDB REPLICATION BYPASSRLS;
CREATE DATABASE $dbname OWNER=$dbusr
END

psql postgres://$dbusr:$dbpwd@localhost/$dbname -c "SELECT 1"