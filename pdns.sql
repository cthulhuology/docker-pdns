create table domains (
  id                INTEGER PRIMARY KEY,
  name              VARCHAR(255) NOT NULL COLLATE NOCASE,
  master            VARCHAR(128) DEFAULT NULL,
  last_check        INTEGER DEFAULT NULL,
  type              VARCHAR(6) NOT NULL,
  notified_serial   INTEGER DEFAULT NULL, 
  account           VARCHAR(40) DEFAULT NULL
);

CREATE UNIQUE INDEX name_index ON domains(name);

CREATE TABLE records (
  id              INTEGER PRIMARY KEY,
  domain_id       INTEGER DEFAULT NULL,
  name            VARCHAR(255) DEFAULT NULL, 
  type            VARCHAR(10) DEFAULT NULL,
  content         VARCHAR(65535) DEFAULT NULL,
  ttl             INTEGER DEFAULT NULL,
  prio            INTEGER DEFAULT NULL,
  change_date     INTEGER DEFAULT NULL
);
              
CREATE INDEX rec_name_index ON records(name);
CREATE INDEX nametype_index ON records(name,type);
CREATE INDEX domain_id ON records(domain_id);

create table supermasters (
  ip          VARCHAR(64) NOT NULL, 
  nameserver  VARCHAR(255) NOT NULL COLLATE NOCASE, 
  account     VARCHAR(40) DEFAULT NULL
);

-- Define the domain
INSERT INTO domains (id,name,type,account) VALUES (1,'example.com','master','ADMIN');

-- SOA
INSERT INTO records (id,domain_id,name,type,content,ttl) VALUES (1,1,'example.com','SOA','ns.example.com. root.example.com. 2013111311 10800 3600 604800 3600',3600);

-- NS records
INSERT INTO records (id,domain_id,name,type,content,ttl) VALUES (2,1,'example.com','NS','ns1.example.com',3600);
INSERT INTO records (id,domain_id,name,type,content,ttl) VALUES (3,1,'example.com','NS','ns2.example.com',3600);

-- A records
INSERT INTO records (id,domain_id,name,type,content,ttl) VALUES (4,1,'www.example.com','A','127.0.0.1',3600);
INSERT INTO records (id,domain_id,name,type,content,ttl) VALUES (5,1,'ftp.example.com','A','127.0.0.1',3600);

.backup ./data/dns.sqlite
.exit
