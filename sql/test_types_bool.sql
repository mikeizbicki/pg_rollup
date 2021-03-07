SET client_min_messages TO WARNING;
create or replace language plpython3u;
create extension if not exists pg_rollup;

create temporary table testbool (
    id serial primary key,
    a bool,
    b bool,
    c bool,
    d bool
);

select create_rollup(
    'testbool',
    'testbool_rollup1',
    rollups => $$
        bool_and(a),
        bool_and(b),
        bool_and(c),
        bool_and(d),
        bool_or(a),
        bool_or(b),
        bool_or(c),
        bool_or(d)
    $$
);

insert into testbool (a,b,c,d) values (TRUE,FALSE,NULL,NULL);
select assert_rollup('testbool_rollup1');
insert into testbool (a,b,c,d) values (TRUE,FALSE,NULL,NULL);
select assert_rollup('testbool_rollup1');
insert into testbool (a,b,c,d) values (FALSE,TRUE,TRUE,FALSE);
select assert_rollup('testbool_rollup1');
insert into testbool (a,b,c,d) values (NULL,NULL,FALSE,TRUE);
select assert_rollup('testbool_rollup1');
insert into testbool (a,b,c,d) values (TRUE,FALSE,NULL,NULL);
select assert_rollup('testbool_rollup1');