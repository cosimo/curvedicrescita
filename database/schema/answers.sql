/* $Id$ */

BEGIN;

CREATE TABLE answers (
	id integer primary key,
	type char(1) not null,      /* Type of question? */
	rtype char(3) not null default 'que',
	rid integer not null,       /* Which question does this answer refer to? */
	content text,
	createdby char(100) not null,
	createdon timestamp not null default current_timestamp,
	lastupdateby char(100),
	lastupdateon timestamp,
	keywords text,
	-- 0:non public, 1:public
	published integer not null default 1,
	reputation integer not null default 0,
	modified timestamp
);

CREATE INDEX i_answers_question ON answers (rid);

COMMIT;

