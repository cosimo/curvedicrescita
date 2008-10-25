--
-- --------------------------------------------------------
-- USE THIS ONLY IN CASE OF PROBLEMS WITH OTHER FILES HERE
-- Cosimo
-- ---------------------------------------------------------

DROP TABLE babydiary.articles;
CREATE TABLE babydiary.articles (
  id int(10) NOT NULL,
  title varchar(500) default NULL,
  content text,
  createdby char(30) NOT NULL,
  createdon timestamp NOT NULL default CURRENT_TIMESTAMP,
  lastupdateby char(30) NOT NULL,
  lastupdateon timestamp NOT NULL,
  keywords text,
  views int(11) NOT NULL default '0',
  PRIMARY KEY  (id)
);

/*
INSERT INTO articles VALUES (
    2,
    'Compare and contrast of Perl with C',
    'This is a brief comparison of Perl & C.\r\n\r\nC (196x)\r\n  - Low level language compiled to machine code. Fast!\r\n  - Staticly typed. No generic programming.\r\n  - C programs portable only if using only the standard library\r\n    (sometimes even with stdlib this is not the case)\r\n  - Manual memory allocation. No garbage collector.\r\n  - No Object-Orientation built in the language (it didn\'t exist!)\r\n    but there are structures and function pointers.\r\n  - No exceptions\r\n  - External libraries link and extensions are easy to develop\r\n  - Debugging and profiling is easy. Many tools available (gdb, gprof).\r\n  - No CPAN ;-)\r\n\r\nPerl (1987)\r\n\r\n  - Very high level language with some peculiar low-level C-like features,\r\n    (ex.: sysopen, syswrite, ioctl)\r\n  - Two-pass interpreter. Source is parsed into bytecode. Bytecode is run.\r\n  - Dynamicly typed. Variables don\'t need their type declared.\r\n    Generic programming is naturally possible.\r\n  - Portable like nothing else! Personally I\'ve seen it run under Windows,\r\n    Mac OS 9/X, Linux, BSD, AS/400, Novell Netware and OS/2.\r\n  - Automatic reference-counting garbage collector\r\n  - \"Add-on\" Object-Oriented system. It was included in Perl from V5.0\r\n    with a mechanism that is very simple even if not \"pure\", based\r\n    essentially on \"bless\" keyword.\r\n  - Very simple exceptions (eval/die). Finer exception handling requires\r\n    installation of additional classes (Error.pm for example)\r\n  - Developing/building extensions is a complex task (XS)\r\n  - Debugger is not so friendly (ddd?).\r\n    Profiling and benchmarking is better (Devel::DProf, Benchmark)\r\n  - CPAN :-)\r\n',
    'cosimo',
    '2007-05-28 19:47:33',
    '',
    '0000-00-00 00:00:00',
    'perl c compare programming language',
    3
);
*/

DROP TABLE babydiary.sessions;
CREATE TABLE babydiary.sessions (
  id char(32) NOT NULL,
  a_session text NOT NULL,
  PRIMARY KEY (id)
);

DROP TABLE babydiary.users;
CREATE TABLE babydiary.users (
  username char(30) NOT NULL,
  realname varchar(60) default NULL,
  password char(40) NOT NULL,
  isadmin  int NOT NULL default '0',
  reatedon timestamp NOT NULL default CURRENT_TIMESTAMP,
  lastlogon timestamp NOT NULL default '0000-00-00 00:00:00',
  language char(12) NOT NULL default 'no_NO',
  PRIMARY KEY (username)
);

