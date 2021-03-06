SET client_min_messages TO WARNING;
create or replace language plpython3u;
create extension if not exists pgrollup;

create table test (
    id serial primary key,
    name text,
    num int
);

insert into test (name,num) values
    ('alice', 1),
    ('alice', 2),
    ('alice', 3),
    ('alice', 4),
    ('alice', 5),
    ('bill', 5),
    ('bill', 5),
    ('bill', 5),
    ('charlie', 1),
    ('charlie', 1),
    ('charlie', 1),
    ('charlie', 3),
    ('charlie', NULL),
    ('dave', 4),
    ('elliot', 5),
    (NULL, 1),
    (NULL, 1),
    (NULL, 1),
    (NULL, 1),
    (NULL, 1),
    (NULL, 8),
    (NULL, 9),
    (NULL, NULL),
    (NULL, NULL),
    (NULL, NULL),
    (NULL, NULL);

create materialized view test_rollup1 as (
    select name,count(*)
    from test
    group by name
);

create materialized view test_rollup2 as (
    select name,num,count(*)
    from test
    group by name,num
);


select assert_rollup('test_rollup1');
select assert_rollup('test_rollup2');


insert into test (name,num) values
    ('alice', 1),
    ('alice', 2),
    ('alice', 3),
    ('alice', 4),
    ('alice', 5),
    ('bill', 5),
    ('bill', 5),
    ('bill', 5),
    ('charlie', 1),
    ('charlie', 1),
    ('charlie', 1),
    ('charlie', 3),
    ('charlie', NULL),
    ('dave', 4),
    ('elliot', 5),
    (NULL, 1),
    (NULL, 1),
    (NULL, 1),
    (NULL, 1),
    (NULL, 1),
    (NULL, 8),
    (NULL, 9),
    (NULL, NULL),
    (NULL, NULL),
    (NULL, NULL),
    (NULL, NULL);

select assert_rollup('test_rollup1');
select assert_rollup('test_rollup2');

select drop_rollup('test_rollup1');

insert into test (name,num) values
    ('alice', 1),
    ('alice', 2),
    ('alice', 3),
    ('alice', 4),
    ('alice', 5),
    ('bill', 5),
    ('bill', 5),
    ('bill', 5),
    ('charlie', 1),
    ('charlie', 1),
    ('charlie', 1),
    ('charlie', 3),
    ('charlie', NULL),
    ('dave', 4),
    ('elliot', 5),
    (NULL, 1),
    (NULL, 1),
    (NULL, 1),
    (NULL, 1),
    (NULL, 1),
    (NULL, 8),
    (NULL, 9),
    (NULL, NULL),
    (NULL, NULL),
    (NULL, NULL),
    (NULL, NULL);

select assert_rollup('test_rollup2');

select drop_rollup('test_rollup2');

create materialized view test_rollup2 as (
    select name,count(*)
    from test
    group by name
);

create materialized view test_rollup1 as (
    select name,num,count(*)
    from test
    group by name,num
);

select assert_rollup('test_rollup1');
select assert_rollup('test_rollup2');

--FIXME:
--dropping the rollups when the table drops isn't currently implemented?

drop table test cascade;

create table test (
    id serial primary key,
    name text,
    num int
);

create materialized view test_rollup2 as (
    select name,sum(num)
    from test
    group by name
);

create materialized view test_rollup1 as (
    select num,count(*)
    from test
    group by num
);

select assert_rollup('test_rollup1');
select assert_rollup('test_rollup2');

drop table test cascade;
