@echo off
echo Deployment...
ftp -v -i -s:deploy.ftp www.curvedicrescita.com
echo Done.
rem tar cvf cc.tar --exclude .svn --exclude templates/old database/data/babydiary.sqlite htdocs exec conf lib templates
