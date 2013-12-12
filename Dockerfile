FROM cthulhuology/postgresql
MAINTAINER Dave Goehrig <dave@dloh.org>

RUN yum install -y pdns bind-utils pdns-backend-postgresql.x86_64

ADD ./pdns.conf /etc/pdns/pdns.conf
ADD ./pdns.sql /pdns.sql
ADD ./start.sh /start.sh
RUN chmod u+x /start.sh

EXPOSE 53
EXPOSE 53/udp

CMD ./start.sh
