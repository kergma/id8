-- dbext:profile=spu_ztest:

select 1;

drop function systemid();
create or replace function systemid() returns int as 
$$
	select 123
$$
language sql immutable;
drop sequence id_helper;
create sequence id_helper minvalue 0 maxvalue 65536 cycle;

create or replace function generate_id() returns int8 as 
$$
	select ((100*extract(epoch from clock_timestamp()))::int8::bit(40)||nextval('id_helper')::bit(12)||systemid()::bit(12))::bit(64)::int8;
$$
language sql volatile;

