CREATE TABLE articles (
	id integer primary key,
	title varchar(500) not null,
	content text,
	createdby char(30) not null,
	createdon timestamp not null default current_timestamp,
	lastupdateby char(30),
	lastupdateon timestamp,
	keywords text,
	-- 0:non public, 1:public, 3:frontpaged
	published integer not null default 0,
	views int(11) not null default '0'
);

