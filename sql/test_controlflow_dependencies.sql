SET client_min_messages TO WARNING;
/*
 * The purpose of this test file is a bit different than other test files;
 * we are not checking anywhere that the rollups created are correct;
 * instead, we are only checking that there are no errors when generating/using the rollup;
 * this will ensure that all the column dependencies are satisfied.
 * We are not trying trying to check that the dependencies for a particular type are satisfied,
 * but rather that the dependency checker is working;
 * therefore, there is no need to modify this file when adding a new algebra.
 */
create or replace language plpython3u;
create extension if not exists pgrollup;

create table testdeps (
    id serial primary key,
    a int,
    b int
);

insert into testdeps (a,b) values
    (0, 1),
    (0, 2),
    (0, 3),
    (0, 4),
    (0, 5),
    (1, 5),
    (1, 5),
    (1, 5),
    (2, 1),
    (2, 1),
    (2, 1),
    (2, 3),
    (2, NULL),
    (3, 4),
    (4, 5),
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

CREATE MATERIALIZED VIEW testdeps_rollup1 AS (
    SELECT
        a,
        avg(b)
    FROM testdeps
    GROUP BY a
);

CREATE MATERIALIZED VIEW testdeps_rollup2 AS (
    SELECT
        a,
        var_pop(b)
    FROM testdeps
    GROUP BY a
);

CREATE MATERIALIZED VIEW testdeps_rollup3 AS (
    SELECT
        a,
        count(b),
        var_pop(b)
    FROM testdeps
    GROUP BY a
);

CREATE MATERIALIZED VIEW testdeps_rollup4 AS (
    SELECT
        a,
        count(*),
        var_pop(b)
    FROM testdeps
    GROUP BY a
);

CREATE MATERIALIZED VIEW testdeps_rollup5 AS (
    SELECT
        avg(a),
        var_pop(b)
    FROM testdeps
);

CREATE MATERIALIZED VIEW testdeps_rollup6 AS (
    SELECT
        var_pop(a) AS var_pop_a,
        var_pop(b) AS var_pop_b
    FROM testdeps
);

CREATE MATERIALIZED VIEW testdeps_rollup7 AS (
    SELECT
        var_pop(a),
        variance(b)
    FROM testdeps
);

CREATE MATERIALIZED VIEW testdeps_rollup8 AS (
    SELECT
        variance(b)
    FROM testdeps
);

insert into testdeps (a,b) values
    (0, 1),
    (0, 2),
    (0, 3),
    (0, 4),
    (0, 5),
    (1, 5),
    (1, 5),
    (1, 5),
    (2, 1),
    (2, 1),
    (2, 1),
    (2, 3),
    (2, NULL),
    (3, 4),
    (4, 5),
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

drop table testdeps cascade;
