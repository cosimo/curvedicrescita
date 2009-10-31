--
-- Questions
-- 
-- $Id$
--

BEGIN;

CREATE TABLE questions (
	id        integer not null primary key,
	title     text not null,
	slug      text not null,
	content   text not null,
	-- 0:closed, 1:open to site owner, 7:open to all
	open      integer not null default 7,
	createdby char(30) not null,
	createdon timestamp not null default current_timestamp,
	lastupdateby char(30),
	lastupdateon timestamp,
	keywords  text,
	-- 0:non public, 1:public, 3:frontpaged
	published integer not null default 0,
	views     integer not null default 0,
	favorited integer not null default 0,
	modified  timestamp not null
);

CREATE INDEX i_questions_title ON questions (title);

--CREATE TABLE question_keywords (
--	keyword text not null primary key,
--	occurrences integer not null default 0,
--);

COMMIT;

