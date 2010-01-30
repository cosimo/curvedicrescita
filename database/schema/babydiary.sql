 
BEGIN;

CREATE TABLE babydiary (
        id        integer not null primary key,
        baby      integer not null,     /* babies.id */
        entrydate date not null,
        entrytype integer not null,     /* vaccino,primo dentino,primo giorno di scuola,semplice nota,etc... */
        year      integer not null,
        month     integer not null,
        day       integer not null,
        time      timestamp not null,
        weight    numeric(6,3),
        height    numeric(6,3),
        headcirc  numeric(6,3),
        bmi       numeric(6,3),
        pic       integer,              /* pics.id */
        url       text,                 /* pic url? */
        status    char(200),            /* think twitter status */
        notes     text
);

CREATE INDEX i_babydiary_baby ON babydiary (baby);
CREATE INDEX i_babydiary_date ON babydiary (entrydate);

COMMIT;
