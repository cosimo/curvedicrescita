CREATE TABLE article_views (
	id integer primary key,
	views int(11) not null default '0',
	lastviewedby char(30) not null,
	lastviewedon timestamp not null default current_timestamp
);

