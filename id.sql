-- dbext:profile=spu_ztest:

select 1;

drop function systemid();
create or replace function systemid() returns int as 
$$
	select 123
$$
language sql immutable;
drop sequence id_helper;
create sequence id_helper minvalue 0 maxvalue 65535 cycle;

create or replace function generate_id() returns int8 as 
$$
	select ((100*extract(epoch from clock_timestamp()))::int8::bit(40)||nextval('id_helper')::bit(12)||systemid()::bit(12))::bit(64)::int8;
$$
language sql volatile;

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

select timestamp with time zone 'epoch' + substring(2348890907203338240::bit(64) from 1 for 40)::int8::double precision/100*interval '1 second';

select current_timestamp,id_of_timestamp(current_timestamp),timestamp_of_id(id_of_timestamp(current_timestamp));


