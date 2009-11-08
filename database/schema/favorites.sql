/* $Id: answers.sql 307 2009-11-08 15:48:24Z cosimo_2 $ */

BEGIN;

CREATE TABLE favorites (
	rtype char(30) not null default 'question',
	rid integer not null,
	points integer not null default 0,
	createdby char(100) not null,
	createdon timestamp not null default current_timestamp,
	note text
);

COMMIT;

