SET client_min_messages TO WARNING;
create or replace language plpython3u;
create extension if not exists topn;
drop extension pg_rollup;
create extension if not exists pg_rollup;

create table test_topn (
    id serial primary key,
    name text,
    num int
);

insert into test_topn (name,num) values
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

CREATE MATERIALIZED VIEW test_topn_rollup1 AS (
    SELECT
        topn(topn_add_agg(name),1) AS top1,
        topn(topn_add_agg(name),2) AS top2,
        topn(topn_add_agg(name),3) AS top3
    FROM test_topn
);

select assert_rollup('test_topn_rollup1');

insert into test_topn (name,num) values
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


select assert_rollup('test_topn_rollup1');

select * from test_topn_rollup1;

drop table test_topn cascade;
