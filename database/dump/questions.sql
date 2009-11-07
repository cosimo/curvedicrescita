BEGIN TRANSACTION;
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
	published  integer not null default 0,
	views      integer not null default 0,
	favorited  integer not null default 0,
    reputation integer not null default 0,
	answers    integer not null default 0,
	modified   timestamp
);
INSERT INTO "questions" VALUES(7,'Mia figlia di 1 mese ha troppa fame?','mia-figlia-1-mese-troppa-fame','<p>salve!mia figlia ha quasi un mese ed ha sempre troppa fame. allatta esclusivamente al seno e ci&ograve; che ni preoccupa &egrave; che (specialmente di sera) allatta continuativamente per circa 5 ore.</p>
<p>nonostante ci&ograve; la trovo insoddisfatta. il seno pare contenga molto latte, ma la bimba appare nervosa. il mio buon senso mi suggerisce di darle l''aggiunta almeno soltanto prima di andare a dormire. sar&agrave; una buona idea?</p>
<p>&nbsp;</p>
<p>a presto</p>',7,'saralibera@hotmail.it','2009-08-08 11:08:47',NULL,NULL,NULL,1,35,0,0,0,0);
INSERT INTO "questions" VALUES(9,'Bimbo di due mesi che mangia troppo poco?','bimbo-due-mesi-mangia-troppo-poco','<p>salve il mio bimbo che ha circa 2 mesi (li compie giorno 19/08) allatta al mio seno ogni 2 ore a volta anche ogni ora, per&ograve; continua a prendere peso ora pesa 4,5 Kg, mi sento dire spesso che questo e causa del mio latte leggero? E'' vero?</p>',7,'giuseppe.ancora70@gmail.com','2009-08-12 00:41:13',NULL,NULL,NULL,1,43,0,0,0,0);
INSERT INTO "questions" VALUES(11,'Ho tanta paura dopo l''esito della translucenza','ho-tanta-paura-dopo-esito-translucenza-nucale','<p>ho tanta paura...la trnslucenza nucale ha dato esito1,27 .. .. .. non vogliamo fare l''amniocentesi perch&egrave; lo terremo comunque per&ograve; ho molta paura..sono oggi alla quindicesima settimana..</p>',7,'ottavianisara@libero.it','2009-08-20 18:25:46',NULL,NULL,NULL,1,90,0,0,0,0);
INSERT INTO "questions" VALUES(28,'Bimba alla 30a settimana con due soft markers. Dobbiamo preoccuparci?','bimba-30a-settimana-due-soft-markers-dobbiamo-preoccuparci','<p>salve sono gianfranco e con mia moglie stiamo aspettando la nascita della nostra prima bambina (siamo adesso quasi alla 30 sett)dopo tutti gli esami di routine il feto presenta due soft markers(cordone ombelicale con arteria unica e golf ball) bisogna dire che le misure sono nella norma e che il tri-test &egrave; risultato negativo!!dobbiamo preoccuparci?o meglio cosa dobbiamo fare per stare un p&ograve; pi&ugrave; tranquilli???</p>',7,'pallido06@libero.it','2009-10-09 18:26:48',NULL,NULL,NULL,1,94,0,0,0,0);
CREATE INDEX i_questions_title ON questions (title);
COMMIT;
