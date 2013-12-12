su - postgres -c '/usr/pgsql-9.3/bin/postgres -D /var/lib/pgsql/data' & 
if [[ ! -x /.db.init ]]; then
	sleep 5
	touch /.db.init
	su - postgres -c 'createdb pdns'
	su - postgres -c 'createuser pdns'
	psql -U postgres -h localhost pdns < pdns.sql
fi
sleep 4
su - postgres -c '/node_modules/.bin/pgproc postgres://localhost:5432/pdns public 5380'  &
sleep 1
/usr/sbin/pdns_server
