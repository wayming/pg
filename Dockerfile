FROM centos
ENV container docker

# Set to POXIS locale
ENV LC_ALL POSIX 
ENV LANG POSIX 
RUN sed -e "s#LANG=.*#LANG=\"POSIX\"#" /etc/locale.conf > /etc/locale.conf

# Disable the built-in PostgreSQL module:
RUN dnf -qy module disable postgresql

# Install the repository RPM:
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Install PostgreSQL and tools:
RUN dnf list -y postgresql*
RUN dnf install -y postgresql13-server
RUN dnf install -y net-tools
RUN dnf install -y python3

RUN alternatives --set python /usr/bin/python3

# Install systemctl alternative at last, in case systemd is overriden by other installations.
ENV SYSTEMCTL_VERSION=1.4.4181
ADD https://github.com/gdraheim/docker-systemctl-replacement/archive/v${SYSTEMCTL_VERSION}.tar.gz .
RUN tar xvf v${SYSTEMCTL_VERSION}.tar.gz docker-systemctl-replacement-${SYSTEMCTL_VERSION}/files/docker/systemctl.py && \
    /bin/rm -f /usr/bin/systemctl && \
    cp docker-systemctl-replacement-${SYSTEMCTL_VERSION}/files/docker/systemctl.py /usr/bin/systemctl

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -vf $i; done) \
  ; rm -vf /lib/systemd/system/multi-user.target.wants/* \
  ; rm -vf /etc/systemd/system/*.wants/* \
  ; rm -vf /lib/systemd/system/local-fs.target.wants/* \
  ; rm -vf /lib/systemd/system/sockets.target.wants/*udev* \
  ; rm -vf /lib/systemd/system/sockets.target.wants/*initctl* \
  ; rm -vf /lib/systemd/system/basic.target.wants/*

RUN systemctl start systemd-tmpfiles-setup.service -vvv \
  ; systemctl status systemd-tmpfiles-setup.service \
  ; systemctl stop systemd-tmpfiles-setup.service -vvv

# DB user
ENV PG_USER "test"
ENV PG_PASSWORD "test"

# DB setup
# Updates postgres configuration parameters so that it can be started in the container
RUN /usr/pgsql-13/bin/postgresql-13-setup initdb
RUN sed -e "/#listen_addresses/a listen_addresses = '*'" /var/lib/pgsql/13/data/postgresql.conf > /var/lib/pgsql/13/data/postgresql.conf.tmp \
  ; mv /var/lib/pgsql/13/data/postgresql.conf.tmp /var/lib/pgsql/13/data/postgresql.conf
RUN grep 'listen_addresses\|unix_socket_directories' /var/lib/pgsql/13/data/postgresql.conf
RUN systemctl start postgresql-13 -vvv \
  ; systemctl status postgresql-13 \
  ; systemctl stop postgresql-13 -vvv

# # DB create
# USER postgres
# RUN psql -c 'CREATE USER ${PG_USER} WITH PASSWORD \'${PG_PASSWORD}}\' CREATEROLE CREATEDB REPLICATION BYPASSRLS;'
# RUN /usr/pgsql-13/bin/createdb -e -O $dbusr testdb;
# RUN psql postgres://$dbusr:$dbpwd@localhost/testdb -c "SELECT 1"

RUN systemctl enable systemd-tmpfiles-setup.service -vvv
RUN systemctl enable postgresql-13
CMD /usr/bin/systemctl
