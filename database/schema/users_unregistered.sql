--
-- Users that have signed up without registration
-- 
-- $Id: users.sql,v 1.6 2007/06/05 22:31:05 cosimo Exp $
--

BEGIN;

CREATE TABLE users_unregistered (
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

COMMIT;

