create extension citext;

drop table if exists domains cascade;
create table domains (
  id                INTEGER PRIMARY KEY,
  name              citext,
  master            text,
  last_check        INTEGER DEFAULT NULL,
  type              text,
  notified_serial   INTEGER DEFAULT NULL, 
  account           text
);

drop sequence domain_id_seq;
create sequence domain_id_seq start 1;

CREATE UNIQUE INDEX name_index ON domains(name);

drop table if exists records cascade;
CREATE TABLE records (
  id              INTEGER PRIMARY KEY,
  domain_id       INTEGER DEFAULT NULL,
  name            text, 
  type            text,
  content         text,
  ttl             INTEGER DEFAULT NULL,
  prio            INTEGER DEFAULT NULL,
  change_date     INTEGER DEFAULT NULL
);
              
CREATE INDEX rec_name_index ON records(name);
CREATE INDEX nametype_index ON records(name,type);
CREATE INDEX domain_id ON records(domain_id);

drop sequence record_id_seq;
create sequence record_id_seq start 1;

drop table if exists supermasters cascade;
create table supermasters (
  ip          text, 
  nameserver  citext, 
  account     text
);

GRANT SELECT ON supermasters TO pdns;
GRANT ALL ON domains TO pdns;
GRANT ALL ON records TO pdns;

-- Define the domain
create or replace function create_domain(_name text, _type text, _account text) returns boolean as $$
begin
	INSERT INTO domains (id,name,type,account) VALUES (nextval('domain_id_seq'),_name,_type,_account);
	return found;
end
$$ language plpgsql;


-- SOA records
create or replace function create_soa( _domain text, _content text) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	insert into records (id, domain_id, name,type,content,ttl) values ( nextval('record_id_seq'), _domain_id, _domain, 'SOA', _content, 3600);
	return found;
end
$$ language plpgsql;

create or replace function delete_soa( _domain text ) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains;
	delete from records where domain_id = id and type = 'SOA';
	return found;
end
$$ language plpgsql;

-- A records
create or replace function create_a( _domain text, _host text, _ipaddr text) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	insert into records(id,domain_id, name,type, content, ttl) values (nextval('record_id_seq'), _domain_id, _host || '.' ||  _domain, 'A', _ipaddr, 3600);
	return found;
end
$$ language plpgsql;

create or replace function delete_a( _domain text, _host text, _ipaddr text) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	delete from records where domain_id = _domain_id and name = _host || '.' || _domain and content = _ipaddr and type = 'A';
	return found;
end
$$ language plpgsql;

-- NS records
create or replace function create_ns( _domain text, _host text) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	insert into records(id,domain_id, name,type, content, ttl) values (nextval('record_id_seq'), _domain_id,  _domain, 'NS', _host || '.' || _domain, 3600);
	return found;
end
$$ language plpgsql;

create or replace function delete_ns( _domain text, _host text) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	delete from records where domain_id = domain_id and type = 'NS' and content = _host || '.' || _domain;
	return found;
end
$$ language plpgsql;

-- CNAME records
create or replace function create_cname( _domain text, _host text, _alias text ) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	insert into records(id,domain_id,name,type,content,ttl) values (nextval('record_id_seq'), _domain_id, _host || '.' || _domain , 'CNAME', _alias, 3600);
	return found;
end
$$ language plpgsql;

create or replace function delete_cname( _domain text, _host text, _alias text) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	delete from records where domain_id = _domain_id and name = _host || '.' || _domain and content = _alias and type = 'CNAME';	
	return found;
end
$$ language plpgsql;


-- TXT records
-- http://www.ietf.org/rfc/rfc1464.txt

create or replace function create_txt( _domain text, _host text, _txt text ) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	insert into records(id,domain_id,name,type,content,ttl) values (nextval('record_id_seq'), _domain_id, _host || '.' || _domain, 'TXT', _txt, 3600);
	return found;
end
$$ language plpgsql;

create or replace function delete_txt( _domain text, _host text, _txt text ) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	delete from records where domain_id = _domain_id and name = _host || '.' || _domain and content = _txt and type = 'TXT';
	return found;
end
$$ language plpgsql;

-- SRV records
-- https://www.ietf.org/rfc/rfc2782.txt

create or replace function create_srv( _domain text, _host text, _txt text ) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	insert into records(id,domain_id,name,type,content,ttl) values (nextval('record_id_seq'), _domain_id, _host || '.' || _domain, 'SRV', _txt, 3600);
	return found;
end
$$ language plpgsql;

create or replace function delete_srv( _domain text, _host text, _txt text ) returns boolean as $$
declare
	_domain_id integer;
begin
	select into _domain_id id from domains where name = _domain;
	delete from records where domain_id = _domain_id and name = _host || '.' || _domain and content = _txt and type = 'SRV';
	return found;
end
$$ language plpgsql;

-- list domain
create or replace function list_domain(_domain text) returns json as $$
declare
	_domain_id integer;
	_json json;
begin
	select into _domain_id id from domains where name = _domain;
	select into _json array_to_json(array_agg(foo)) as domain from ( select name,type,content from records where domain_id = _domain_id) as foo;
	return _json;
end
$$ language plpgsql;
