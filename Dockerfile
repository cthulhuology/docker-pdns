FROM centos
MAINTAINER Dave Goehrig <dave@dloh.org>

# Install EPEL
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum install -y pdns pdns-backend-sqlite bind-utils
RUN mkdir -p /dns

ADD ./pdns.conf /etc/pdns/pdns.conf

VOLUME /dns
CMD /usr/sbin/pdns_server
