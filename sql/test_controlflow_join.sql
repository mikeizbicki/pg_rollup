--SET client_min_messages TO WARNING;
create or replace language plpython3u;
create extension if not exists pg_rollup;

-- FIXME:
-- Currently, only inner joins (non-self) work, and they're only tested in trigger mode.
-- I believe there may be a bug in the manual mode when tables are rolled up in separate transactions.

create temporary table testjoin1 (
    pk serial primary key,
    id int,
    name text,
    num int
);

create temporary table testjoin2 (
    pk serial primary key,
    id int,
    str text,
    foo float
);

insert into testjoin1 (id,name,num) values
    (0,'alice', 1),
    (1,'alice', 2),
    (2,'alice', 3),
    (3,'alice', 4),
    (4,'alice', 5),
    (5,'bill', 5),
    (6,'bill', 5),
    (7,'bill', 5),
    (8,'charlie', 1),
    (9,'charlie', 1),
    (10,'charlie', 1),
    (11,'charlie', 3),
    (12,'charlie', NULL),
    (13,'dave', 4),
    (14,'elliot', 5),
    (15,NULL, 1),
    (16,NULL, 1),
    (17,NULL, 1),
    (18,NULL, 1),
    (19,NULL, 1),
    (20,NULL, 8),
    (21,NULL, 9),
    (22,NULL, NULL),
    (23,NULL, NULL),
    (24,NULL, NULL),
    (25,NULL, NULL);

insert into testjoin2 (id,str,foo) values
    (90,'alice', 1),
    (01,'alice', 2),
    (92,'alice', 3),
    (03,'alice', 4),
    (94,'alice', 5),
    (05,'bill', 5),
    (96,'bill', 5),
    (07,'bill', 5),
    (98,'charlie', 1),
    (09,'charlie', 1),
    (910,'charlie', 1),
    (011,'charlie', 3),
    (912,'charlie', NULL),
    (013,'dave', 4),
    (914,'elliot', 5),
    (015,NULL, 1),
    (916,NULL, 1),
    (017,NULL, 1),
    (918,NULL, 1),
    (019,NULL, 1),
    (920,NULL, 8),
    (021,NULL, 9),
    (922,NULL, NULL),
    (023,NULL, NULL),
    (924,NULL, NULL),
    (025,NULL, NULL);

select pgrollup($$
CREATE INCREMENTAL MATERIALIZED VIEW testjoin_rollup1 AS (
    SELECT
        sum(num),
        sum(foo)
    FROM testjoin1 AS t1
    JOIN testjoin2 AS t2 USING (id)
    GROUP BY name
);
$$, dry_run => False);

select pgrollup($$
CREATE INCREMENTAL MATERIALIZED VIEW testjoin_rollup2 AS (
    SELECT
        sum(num),
        sum(foo)
    FROM testjoin1 t1
    JOIN testjoin2 t2 ON (t1.id=t2.id)
    GROUP BY name
);
$$);

select pgrollup($$
CREATE INCREMENTAL MATERIALIZED VIEW testjoin_rollup3 AS (
    SELECT
        count(t1.num),
        count(t2.foo+1)
    FROM testjoin1 t1
    JOIN testjoin2 t2 USING (id)
    GROUP BY t1.name
);
$$, dry_run => False);

select pgrollup($$
CREATE INCREMENTAL MATERIALIZED VIEW testjoin_rollup4 AS (
    SELECT
        sum(t1.num),
        sum(t2.foo),
        sum(t1.num-t2.foo),
        max(t1.num-t2.foo)
    FROM testjoin1 t1
    JOIN testjoin2 t2 USING (id)
    GROUP BY t1.name
);
$$);

select assert_rollup('testjoin_rollup1');
select assert_rollup('testjoin_rollup2');
select assert_rollup('testjoin_rollup3');
select assert_rollup('testjoin_rollup4');


insert into testjoin2 (id,str,foo) values
    (10,'alice', 1),
    (11,'alice', 2),
    (12,'alice', 3),
    (13,'alice', 4),
    (14,'alice', 5),
    (15,'bill', 5),
    (16,'bill', 5),
    (17,'bill', 5),
    (18,'charlie', 1),
    (19,'charlie', 1),
    (110,'charlie', 1),
    (111,'charlie', 3),
    (112,'charlie', NULL),
    (113,'dave', 4),
    (114,'elliot', 5),
    (115,NULL, 1),
    (116,NULL, 1),
    (117,NULL, 1),
    (118,NULL, 1),
    (119,NULL, 1),
    (120,NULL, 8),
    (121,NULL, 9),
    (122,NULL, NULL),
    (123,NULL, NULL),
    (124,NULL, NULL),
    (125,NULL, NULL);


--SELECT *
--FROM pg_rollup
--WHERE pg_rollup.rollup_name='testjoin_rollup2';
--select do_rollup('testjoin_rollup2','t1');
--select do_rollup('testjoin_rollup2','t2');
--select do_rollup('testjoin_rollup2');

--select * from testjoin_rollup4_groundtruth;
--select * from testjoin_rollup4;
--select * from testjoin_rollup1_groundtruth order by name;

select assert_rollup('testjoin_rollup1');
select assert_rollup('testjoin_rollup2');
select assert_rollup('testjoin_rollup3');
select assert_rollup('testjoin_rollup4');

insert into testjoin1 (id,name,num) values
    (10,'alice', 1),
    (11,'alice', 2),
    (12,'alice', 3),
    (13,'alice', 4),
    (14,'alice', 5),
    (15,'bill', 5),
    (16,'bill', 5),
    (17,'bill', 5),
    (18,'charlie', 1),
    (19,'charlie', 1),
    (110,'charlie', 1),
    (111,'charlie', 3),
    (112,'charlie', NULL),
    (113,'dave', 4),
    (114,'elliot', 5),
    (115,NULL, 1),
    (116,NULL, 1),
    (117,NULL, 1),
    (118,NULL, 1),
    (119,NULL, 1),
    (120,NULL, 8),
    (121,NULL, 9),
    (122,NULL, NULL),
    (123,NULL, NULL),
    (124,NULL, NULL),
    (125,NULL, NULL);

insert into testjoin1 (id,name,num) values
    (10,'alice', 1),
    (21,'alice', 2),
    (12,'alice', 3),
    (23,'alice', 4),
    (14,'alice', 5),
    (25,'bill', 5),
    (16,'bill', 5),
    (27,'bill', 5),
    (18,'charlie', 1),
    (29,'charlie', 1),
    (110,'charlie', 1),
    (211,'charlie', 3),
    (112,'charlie', NULL),
    (213,'dave', 4),
    (114,'elliot', 5),
    (215,NULL, 1),
    (116,NULL, 1),
    (217,NULL, 1),
    (118,NULL, 1),
    (219,NULL, 1),
    (120,NULL, 8),
    (221,NULL, 9),
    (122,NULL, NULL),
    (223,NULL, NULL),
    (124,NULL, NULL),
    (225,NULL, NULL);

--select * from testjoin_rollup2_groundtruth order by name;
--select * from testjoin_rollup2 order by name;
--select * from testjoin_rollup1_groundtruth order by name;

select assert_rollup('testjoin_rollup1');
select assert_rollup('testjoin_rollup2');
select assert_rollup('testjoin_rollup3');
select assert_rollup('testjoin_rollup4');

insert into testjoin1 (id,name,num) values
    (0,'alice', 1),
    (1,'alice', 2),
    (2,'alice', 3),
    (3,'alice', 4),
    (4,'alice', 5),
    (5,'bill', 5),
    (6,'bill', 5),
    (7,'bill', 5),
    (8,'charlie', 1),
    (9,'charlie', 1),
    (10,'charlie', 1),
    (11,'charlie', 3),
    (12,'charlie', NULL),
    (13,'dave', 4),
    (14,'elliot', 5),
    (15,NULL, 1),
    (16,NULL, 1),
    (17,NULL, 1),
    (18,NULL, 1),
    (19,NULL, 1),
    (20,NULL, 8),
    (21,NULL, 9),
    (22,NULL, NULL),
    (23,NULL, NULL),
    (24,NULL, NULL),
    (25,NULL, NULL);

select assert_rollup('testjoin_rollup1');
select assert_rollup('testjoin_rollup2');
select assert_rollup('testjoin_rollup3');
select assert_rollup('testjoin_rollup4');

insert into testjoin2 (id,str,foo) values
    (0,'alice', 1),
    (1,'alice', 2),
    (2,'alice', 3),
    (3,'alice', 4),
    (4,'alice', 5),
    (5,'bill', 5),
    (6,'bill', 5),
    (7,'bill', 5),
    (8,'charlie', 1),
    (9,'charlie', 1),
    (10,'charlie', 1),
    (11,'charlie', 3),
    (12,'charlie', NULL),
    (13,'dave', 4),
    (14,'elliot', 5),
    (15,NULL, 1),
    (16,NULL, 1),
    (17,NULL, 1),
    (18,NULL, 1),
    (19,NULL, 1),
    (20,NULL, 8),
    (21,NULL, 9),
    (22,NULL, NULL),
    (23,NULL, NULL),
    (24,NULL, NULL),
    (25,NULL, NULL);

select assert_rollup('testjoin_rollup1');
select assert_rollup('testjoin_rollup2');
select assert_rollup('testjoin_rollup3');
select assert_rollup('testjoin_rollup4');

--select * from testjoin_rollup1 order by name;
