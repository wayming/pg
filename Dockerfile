FROM centos:7
ENV container docker

COPY pgsetup.sh /opt/pgsetup.sh
RUN chmod +x /opt/pgsetup.sh
COPY pgsetup.service /etc/systemd/system/pgsetup.service
RUN ln -s /etc/systemd/system/pgsetup.service /etc/systemd/system/multi-user.target.wants/pgsetup.service


RUN yum -y update; yum clean all
RUN yum install -y postgresql-server.x86_64

ENTRYPOINT ["/usr/sbin/init"]
