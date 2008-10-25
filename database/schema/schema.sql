/*
   MySQL Schema file for MyOperaTest application
   Cosimo 2007/05/24

   $Id: schema.sql,v 1.6 2007/06/05 22:31:05 cosimo Exp $
*/

/*use opera;*/

/* Articles file */
drop table if exists articles;
create table articles (

    /* Article primary key */
    id int UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,

    /* Title and content are text fields */
    title varchar(500),
    content text,

    /* User and date/time of original article creation */
    createdby     char(30)  not null,
    createdon     timestamp not null default now(),
    
    /* User and date/time of last article change */
    lastupdateby  char(30)  not null,
    lastupdateon  timestamp not null,

    /* Article keywords */
    keywords      text,

    /* Number of article views */
    views         integer not null default 0,

    /* Full text indexing required */
    FULLTEXT(title,content,keywords)

) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/* Users file */
drop table if exists users;
create table users (

    username  char(30)  not null PRIMARY KEY,
    realname  varchar(60),

    /* Password SHA1 hashes computed with Digest::SHA1::sha1_base64() are shorter (27 chars), but
       I chose sha1_hex() because it's the same hash format as MySQL's default sha1() function */
    password  char(40)  not null,
    isadmin   boolean   not null default false,
    createdon timestamp not null default now(),

    /* Clean-up users that logged on long time ago? */
    lastlogon timestamp not null,

    /* Language can be encoded as `zh_CN.UTF-8' */
    language  char(12)  not null default 'no_NO'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

/* Sessions table as managed by CGI::Session Perl module */
drop table if exists sessions;
create table sessions (
    id char(32) not null primary key,
    a_session text not null
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

