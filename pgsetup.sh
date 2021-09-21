#!/bin/bash
set -x

systemctl > /opt/pgsetup.log 2>&1
/usr/bin/postgresql-setup initdb >> /opt/pgsetup.log 2>&1