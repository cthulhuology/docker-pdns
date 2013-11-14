
data/dns.sqlite : pdns.sql
	sqlite3 <pdns.sql

.PHONY: container
container: 
	docker run -d -i -v $(pwd)/data:/dns -p 53:53/udp -p 8053:8053 -t cthulhuolog/pdns

