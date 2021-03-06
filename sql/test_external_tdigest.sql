SET client_min_messages TO WARNING;
create or replace language plpython3u;
drop extension pgrollup;
create extension if not exists tdigest;
create extension if not exists pgrollup;

create table tdigest_test (
    id serial primary key,
    a int
);

insert into tdigest_test (a) (select * from generate_series(0,10000));

CREATE MATERIALIZED VIEW tdigest_test_rollup1 AS (
    SELECT
        tdigest_getpercentile(tdigest(a,10),0.50) AS p50,
        tdigest_getpercentile(tdigest(a,10),0.90) AS p90,
        tdigest_getpercentile(tdigest(a,10),0.99) AS p99,
        tdigest_getpercentile(tdigest(a,1000),0.50) AS p1000_50,
        tdigest_getpercentile(tdigest(a,1000),0.90) AS p1000_90,
        tdigest_getpercentile(tdigest(a,1000),0.99) AS p1000_99
    FROM tdigest_test
);

select assert_rollup('tdigest_test_rollup1');

insert into tdigest_test (a) (select * from generate_series(0,10000));

SELECT assert_rollup_relative_error('tdigest_test_rollup1', 0.1);

insert into tdigest_test (a) (select * from generate_series(100000,200000));

SELECT assert_rollup_relative_error('tdigest_test_rollup1', 0.1);

drop table tdigest_test cascade;
