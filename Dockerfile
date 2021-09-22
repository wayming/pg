FROM centos
ENV container docker

# Set to POXIS locale
ENV LC_ALL POSIX 
ENV LANG POSIX 
RUN sed -e "s#LANG=.*#LANG=\"POSIX\"#" /etc/locale.conf > /etc/locale.conf


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

# DB setup
COPY pgsetup.sh /opt/pgsetup.sh
COPY dbsetup.sh /opt/dbsetup.sh
RUN chmod +x /opt/pgsetup.sh
RUN chmod +x /opt/dbsetup.sh
COPY pgsetup.service /etc/systemd/system/pgsetup.service
RUN ln -s /etc/systemd/system/pgsetup.service /etc/systemd/system/multi-user.target.wants/pgsetup.service


ENTRYPOINT ["/usr/sbin/init"]
