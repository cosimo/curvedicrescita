BEGIN TRANSACTION;
CREATE TABLE answers (
	id integer primary key,
	type char(1) not null,      /* Type of question? */
	rtype char(3) not null default 'que',
	rid integer not null,       /* Which question does this answer refer to? */
	content text,
	createdby char(100) not null,
	createdon timestamp not null default current_timestamp,
	lastupdateby char(100),
	lastupdateon timestamp,
	keywords text,
	-- 0:non public, 1:public
	published integer not null default 1,
	reputation integer not null default 0,
	modified timestamp
);
INSERT INTO "answers" VALUES(12,'Q','que',11,'<p>sono sempre sara,ho dimenticato di scrivere che ho 29 anni quindi la probabilit&agrave; &egrave; molto molto alta...</p>','ottavianisara@libero.it','2009-08-20 18:30:47',NULL,NULL,NULL,1,0,0);
INSERT INTO "answers" VALUES(15,'Q','que',11,'<p>sono ancora Sara,la ringrazio moltissimo per avermi risposto,purtroppo quando ho fatto la translucenza nucale ero a tredici settimane,la mia translucenza nucale era di 4,9 mm ... tantissima... e il mio rischio calcolato,in base anche al prelievo del sangue,&nbsp;di trisomia 21 &egrave; di 1:27....ho tanta tanta paura...non vogliamo fare l''amniocentesi perch&egrave; amiamo e desideriamo tantissimo il nostro piccolo angelo(sembra sia un maschietto)per&ograve; la paura &egrave; tanta...ho fatto anche un''altra ecografia la settimana dopo e sembra esserci l''osso nasale...la prego mi risponda...ho tanto bisogno che qualcuno ne parli con me...</p>
<p>&nbsp;</p>','ottavianisara@libero.it','2009-08-23 11:35:49',NULL,NULL,NULL,1,0,0);
INSERT INTO "answers" VALUES(18,'Q','que',11,'<p>Sono Sara, volevo ringraziarla per tutte le sue parole e informazioni,non faremo l''amnoicentesi perch&egrave; temiamo per il bambino,l''otto settembre quando sar&ograve; a 4mesi e mezzo,faremo un''ecografia,potremo vedere meglio l''osso nasale e il cuoricino,che sembrava funzionare bene,appena sapr&ograve; qualcosa di pi&ugrave;,dopo questa ecografia le far&ograve; sapere.Un''ultima domanda,una possibilit&agrave; su ventisette equivale,in percentuale a quante possibilit&agrave; che il bimbo sia affetto da trisomia 21?grazie ancora con tutto il cuore.</p>','ottavianisara@libero.it','2009-08-26 21:09:22',NULL,NULL,NULL,1,0,0);
INSERT INTO "answers" VALUES(20,'Q','que',11,'<p>Salve,sempre Sara,quindi ho circa il quattro per cento di possibilit&agrave; che non sia sano,ma mi rimane un 96 per cento che invece sia sano?</p>','ottavianisara@libero.it','2009-08-31 09:50:51',NULL,NULL,NULL,1,0,0);
INSERT INTO "answers" VALUES(21,'Q','que',11,'<p>sono sara,settimana scorsa ho fatto ecografia,sono stati visualizzati:ventricoli cerebrali,cervelletto,talami,cavo del setto pellucido,cisterna magna,colonna,orbite,labbra,profilo e osso nasale,4 camere cardiache,incrocio grossi vasi,stomaco,parete addominale,reni,vescica,ossa lunghe arti inferiori,ossa lunghe arit superiori,mani,piedi.</p>
<p>il commento &egrave;:feto singolo con attivit&agrave; cardiaca e motoria e normale quantit&agrave; di liquido amniotico.Biometria fetale compatibile con l''epoca di amenorrea riferita dalla paziente.Lo studio dell''anatomia fetale evidenzia focus iperecogeno nel contesto del ventricolo sinistro del cuore.</p>
<p>lei cosa ne pensa?</p>
<p>&nbsp;</p>','ottavianisara@libero.it','2009-09-15 19:05:33',NULL,NULL,NULL,1,0,0);
CREATE INDEX i_answers_question ON answers (rid);
COMMIT;
