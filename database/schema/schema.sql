CREATE TABLE articles (
	id integer primary key,
	title varchar(500) not null,
	content text,
	createdby char(30) not null,
	createdon timestamp not null default current_timestamp,
	lastupdateby char(30),
	lastupdateon timestamp,
	keywords text,
	views int(11) not null default '0'
);

CREATE TABLE sessions (
  id char(32) NOT NULL,
  a_session text NOT NULL,
  PRIMARY KEY (id)
);

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

