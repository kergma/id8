/*
https://github.com/kergma/id8
version 2, with 44 bit time and 4 bit system domain
*/

create or replace function sysdomain() returns int as
$$
	select 7
$$
language sql immutable;

create sequence id_helper minvalue 0 maxvalue 65535 cycle;

-- time resolution is 1 millisecond, and 44 bit time gives time range from 1970-01-01T00:00:00+00 to 4757-05-16T07:43:42+00
create or replace function generate_id() returns int8 as
$$
	select ((100*extract(epoch from clock_timestamp()))::int8::bit(44)||nextval('id_helper')::bit(16)||sysdomain()::bit(4))::bit(64)::int8;
$$
language sql volatile;

create or replace function generate_id(at_time timestamp with time zone) returns int8 as
$$
	select ((100*extract(epoch from at_time))::int8::bit(44)||nextval('id_helper')::bit(16)||sysdomain()::bit(4))::bit(64)::int8;
$$
language sql volatile;
comment on function generate_id(timestamp with time zone) is 'Attention: for each moment of time there are only 65636 uids can be generated';

create or replace function id_of_timestamp(t timestamp with time zone) returns int8 as
$$
	select ((100*extract(epoch from t))::int8::bit(44)||'0000000000000000')::bit(64)::int8;
$$
language sql immutable;

create or replace function timestamp_of_id(i int8) returns timestamp with time zone as
$$
	select timestamp with time zone 'epoch' + substring(i::bit(64) from 1 for 44)::int8::double precision/100*interval '1 second';
$$
language sql immutable;

create or replace function isid(v anyelement)
returns boolean language sql immutable
as $_$
	select v::text ~ '^\d+$';
$_$;
