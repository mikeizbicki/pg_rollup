SET client_min_messages TO WARNING;

create table test_nopk (
    id int generated by default as identity, -- primary key,
    name text,
    num int
);

insert into test_nopk (name,num) values
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

CREATE ACCESS METHOD pgrollup TYPE TABLE HANDLER heap_tableam_handler;

create materialized view test_nopk_rollup1 using pgrollup as (
    select name,count(*)
    from test_nopk
    group by name
);

select * from pgrollup_rollups;

select assert_rollup('test_nopk_rollup1');

insert into test_nopk (name,num) values
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

select assert_rollup('test_nopk_rollup1');

-- FIXME:
-- The following lines should fail, and we should assert that fact.
--
-- select rollup_mode('test_nopk_rollup1','manual');
-- select rollup_mode('test_nopk_rollup1','cron');

select assert_rollup('test_nopk_rollup1');

drop table test_nopk cascade;
