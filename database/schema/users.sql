--
-- Populate users file
-- 
-- $Id: users.sql,v 1.6 2007/06/05 22:31:05 cosimo Exp $
--

/*use opera;*/

insert into users (username, realname, password, isadmin, createdon, language, lastlogon ) values
    ('cosimo', 'Cosimo Streppone',  sha1('cosimo'),  true,  now(), 'it', NULL),
    ('edoardo','Edoardo Sabadelli', sha1('edoardo'), false, now(), 'en', NULL),
    ('vetler', 'Vetle Roeim',       sha1('vetler'),  true,  now(), 'en', NULL),
    ('ftotti', 'Francesco Totti',   sha1('chanel'),  false, now(), 'it', NULL),
    ('vrossi', 'Valentino Rossi',   sha1('vrossi'),  false, now(), 'it', NULL);

