CREATE TABLE slugs (
	slug  char(500) not null primary key,
	type  char(20),
	id    integer not null,
	state char(1) not null
);

