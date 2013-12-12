su - postgres -c '/usr/pgsql-9.3/bin/postgres -D /var/lib/pgsql/data' & 
if [[ ! -x /.db.init ]]; then
	sleep 5
	touch /.db.init
	su - postgres -c 'createdb pdns'
	su - postgres -c 'createuser pdns'
	psql -U postgres -h localhost pdns < pdns.sql
fi
sleep 4
/usr/sbin/pdns_server
