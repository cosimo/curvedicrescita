--
-- Populate users file
-- 
-- $Id: users.sql,v 1.6 2007/06/05 22:31:05 cosimo Exp $
--

BEGIN;

CREATE TABLE users (
    username  char(30) not null,
    realname  varchar(60) not null,
    password  char(40) not null,
    isadmin   int not null default '0',
    createdon timestamp not null default current_timestamp,
    lastlogon timestamp,
    language  char(12) not null default 'it_IT',
    gender    char(1) not null default 'f',
    pregnancy char(1) not null default '0',
    children  int not null default 0,
    memo      varchar(200) default '',
    primary key (username)
);

INSERT INTO "users" VALUES('tamara','Tamara De Zotti','V8GDJBECK',1,'2008-11-08 11:18:36','2009-01-16 09:58:04','it','f','4',2,'');
INSERT INTO "users" VALUES('cosimo','Cosimo Streppone','TecLS29Neo',1,'2008-11-08 11:18:58','2009-01-15 08:18:00','en','m','0',2,'');
INSERT INTO "users" VALUES('antonietta','Antonietta Faino','baccellina',0,'2008-11-08 14:44:35','2009-01-09 20:54:01','it_IT','f','4',2,'');

COMMIT;

