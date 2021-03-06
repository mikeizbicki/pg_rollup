SET client_min_messages TO WARNING;
create or replace language plpython3u;
create extension if not exists pgrollup;

create table messages (
    id serial primary key,
    id_user integer,
    text text
);


insert into messages (id_user, text) values
    (0, 'president obama'),
    (0, 'obama was president'),
    (1, 'president trump'),
    (1, 'president bush'),
    (2, 'george bush senior'),
    (2, 'obama obama obama obama obama obama'),
    (3, ''),
    (2, ''),
    (3, NULL),
    (2, NULL),
    (4, NULL),
    (NULL, ''),
    (NULL, 'obama president'),
    (NULL, 'president trump');
    
create materialized view messages_rollup1 as (
    select
        count(*),
        unnest(tsvector_to_array(to_tsvector(text))) AS tokens
    from messages
    group by tokens
);

create materialized view messages_rollup2 as (
    select 
        unnest(tsvector_to_array(to_tsvector(text))) AS tokens,
        count(id_user)
    from messages
    group by tokens
);

create materialized view messages_rollup3 as (
    select 
        count(id_user)
    from messages
);


select assert_rollup('messages_rollup1');
select assert_rollup('messages_rollup2');
select assert_rollup('messages_rollup3');


insert into messages (id_user, text) values
    (0, 'president obama'),
    (0, 'obama was president'),
    (1, 'president trump'),
    (1, 'president bush'),
    (2, 'george bush senior'),
    (2, 'obama obama obama obama obama obama'),
    (3, ''),
    (2, ''),
    (3, NULL),
    (2, NULL),
    (4, NULL),
    (NULL, ''),
    (NULL, 'obama president'),
    (NULL, 'president trump');

select assert_rollup('messages_rollup1');
select assert_rollup('messages_rollup2');
select assert_rollup('messages_rollup3');

drop table messages cascade;
