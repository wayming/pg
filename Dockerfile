FROM centos
ENV container docker

# Set to POXIS locale
ENV LC_ALL POSIX 
ENV LANG POSIX 
RUN sed -e "s#LANG=.*#LANG=\"POSIX\"#" /etc/locale.conf > /etc/locale.conf

RUN dnf install -y python3
RUN alternatives --set python /usr/bin/python3

# Install systemctl alternative
ENV SYSTEMCTL_VERSION=1.4.4181
ADD https://github.com/gdraheim/docker-systemctl-replacement/archive/v${SYSTEMCTL_VERSION}.tar.gz .
RUN tar xvf v${SYSTEMCTL_VERSION}.tar.gz docker-systemctl-replacement-${SYSTEMCTL_VERSION}/files/docker/systemctl.py && \
    /bin/rm -f /usr/bin/systemctl && \
    cp docker-systemctl-replacement-${SYSTEMCTL_VERSION}/files/docker/systemctl.py /usr/bin/systemctl

# Install the repository RPM:
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Disable the built-in PostgreSQL module:
RUN dnf -qy module disable postgresql

# Install PostgreSQL:
RUN dnf install -y postgresql13-server

RUN dnf install -y net-tools

# DB user
ENV PG_USER "test"
ENV PG_PASSWORD "test"

# # DB setup
RUN ["/usr/pgsql-13/bin/postgresql-13-setup", "initdb"]
RUN ["systemctl", "enable", "postgresql-13"]
# RUN ["systemctl", "start", "postgresql-13"]
# RUN ["systemctl", "status", "postgresql-13"]

# # DB create
# USER postgres
# RUN psql -c 'CREATE USER ${PG_USER} WITH PASSWORD \'${PG_PASSWORD}}\' CREATEROLE CREATEDB REPLICATION BYPASSRLS;'
# RUN /usr/pgsql-13/bin/createdb -e -O $dbusr testdb;
# RUN psql postgres://$dbusr:$dbpwd@localhost/testdb -c "SELECT 1"

VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT ["/usr/sbin/init"]
