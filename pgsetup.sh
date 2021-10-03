#!/bin/bash
set -x

/usr/pgsql-13/bin/postgresql-13-setup initdb >> /opt/pgsetup.log 2>&1
systemctl enable postgresql-13 >> /opt/pgsetup.log 2>&1
systemctl start postgresql-13 >> /opt/pgsetup.log 2>&1
systemctl status postgresql-13 >> /opt/pgsetup.log 2>&1
#su -c "/opt/dbsetup.sh ${PG_USER} ${PG_PASSWORD}" postgres >> /opt/pgsetup.log 2>&1