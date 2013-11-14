DOCKER ?= docker

all: data/sqlite

data/sqlite : pdns.sql
	mkdir -p data
	sqlite3 <pdns.sql

.PHONY: container
container: 
	$(DOCKER) run -d -i -v $(pwd)/data:/dns -p 53:53/udp -p 8053:8053 -t cthulhuology/pdns

