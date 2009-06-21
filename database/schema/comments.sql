/* $Id$ */

BEGIN;

CREATE TABLE comments (
	id integer primary key,
	type char(1) not null,      /* Type of comment? */
	rtype char(3) not null,     /* Comment to what? "art", "..." ? Article? */
	rid integer not null,       /* Which article? articles.id */
	content text,
	createdby char(30) not null,
	createdon timestamp not null default current_timestamp,
	lastupdateby char(30),
	lastupdateon timestamp,
	keywords text,
	-- 0:non public, 1:public
	published integer not null default 1,
	reputation integer not null default 0
);

CREATE INDEX i_comments_related ON comments (rtype, rid);

COMMIT;

