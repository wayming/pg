#!/bin/bash
# Run as postgres
set -x
dbusr=test
dbpwd=test


psql <<END
CREATE USER $dbusr WITH PASSWORD '$dbpwd' CREATEROLE CREATEDB REPLICATION BYPASSRLS;
END

/usr/pgsql-13/bin/createdb -e -O $dbusr testdb;

psql postgres://$dbusr:$dbpwd@localhost/testdb -c "SELECT 1"