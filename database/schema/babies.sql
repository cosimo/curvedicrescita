BEGIN;

CREATE TABLE babies (
	id integer primary key,
    parent1 char(30) not null,  /* users.username */
    parent2 char(30) not null,  /* users.username */
    gender char(1) not null default 'f',
	name char(30) not null,
	realname varchar(60),
    pic integer,                /* pics.id */
    birthdate date not null,
    birthdate_d integer not null,
    birthdate_m integer not null,
    birthdate_y integer not null,
    birthtime char(10),         /* per il calcolo dell'ascendente */
    zodiac integer not null,    /* zodiac sign, 1=ariete, 12=pesci */
    city varchar(60),           /* place where s?he was born */
    country char(2),            /* country where s?he was born */
	lat numeric(9,6),
	lon numeric(9,6),
    modified timestamp,         /* timestamp of last modification */
	memo text
);

COMMIT;

