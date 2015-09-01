/*
https://github.com/kergma/id8
*/

create or replace function systemid() returns int as
$$
	select 128
$$
language sql immutable;

create sequence id_helper minvalue 0 maxvalue 65535 cycle;

create or replace function generate_id() returns int8 as
$$
	select ((100*extract(epoch from clock_timestamp()))::int8::bit(40)||nextval('id_helper')::bit(12)||systemid()::bit(12))::bit(64)::int8;
$$
language sql volatile;

create or replace function generate_id(at_time timestamp with time zone) returns int8 as
$$
	select ((100*extract(epoch from at_time))::int8::bit(40)||nextval('id_helper')::bit(12)||systemid()::bit(12))::bit(64)::int8;
$$
language sql volatile;
comment on function generate_id(timestamp with time zone) is 'Внимание: для каждого момента времени может быть сгенерировано только 4096 уникальных идентификаторов';

create or replace function id_of_timestamp(t timestamp with time zone) returns int8 as
$$
	select ((100*extract(epoch from t))::int8::bit(40)||'000000000000000000000000')::bit(64)::int8;
$$
language sql immutable;

create or replace function timestamp_of_id(i int8) returns timestamp with time zone as
$$
	select timestamp with time zone 'epoch' + substring(i::bit(64) from 1 for 40)::int8::double precision/100*interval '1 second';
$$
language sql immutable;

create or replace function isid(v anyelement)
returns boolean language sql immutable
as $_$
	select v::text ~ '^\d+$';
$_$;
