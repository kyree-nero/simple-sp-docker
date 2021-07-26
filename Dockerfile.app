FROM tomcat:latest
LABEL MAINTAINER=kyree

ARG EXTRACTDIR=/iq/tmp/extract

RUN apt update  && \
    apt install -y unzip vim telnet && \
    mkdir -p $EXTRACTDIR



## add scripts
ADD iq.init.sh /iq
ADD iq.init.commands /iq
ADD change-prop.sh /iq
#ADD create-archive.tc.sh /iq
ADD uncomment-prop.sh /iq


## add war
ADD identityiq.war /iq

RUN cp /iq/identityiq.war /iq/app-before-modify.war && \
    rm /iq/identityiq.war

## unzip war
RUN unzip /iq/app-before-modify.war -d $EXTRACTDIR && \
    chmod -R 777 /iq


## change the database settings for local access
RUN sh /iq/change-prop.sh \
    ${EXTRACTDIR}/WEB-INF/classes/iiq.properties \
    dataSource.password \
    password

RUN sh /iq/change-prop.sh \
    ${EXTRACTDIR}/WEB-INF/classes/iiq.properties \
    dataSource.username \ 
    root

RUN sh /iq/uncomment-prop.sh \
    ${EXTRACTDIR}/WEB-INF/classes/packtag.properties \
    resources.checktimestamps

RUN sh /iq/change-prop.sh \
    ${EXTRACTDIR}/WEB-INF/classes/packtag.properties \
    resources.checktimestamps \ 
    false

#RUN cp ${EXTRACTDIR}/WEB-INF/classes/iiq.properties /iq/iiq.properties.1


## change the database host to localhost briefly
RUN sh /iq/change-prop.sh \
    /iq/tmp/extract/WEB-INF/classes/iiq.properties \
    dataSource.url \
    "jdbc:mysql:\\/\\/localhost\\/identityiq?useServerPrepStmts=true\\&tinyInt1isBit=true\\&useUnicode=true\\&characterEncoding=utf8\\&useSSL=false"

# RUN cp ${EXTRACTDIR}/WEB-INF/classes/iiq.properties /iq/iiq.properties.2

## run app init
RUN sh /iq/iq.init.sh \
    ${EXTRACTDIR} \
    /iq/iq.init.commands

## change the database to the target docker db for deploy
RUN sh /iq/change-prop.sh \
    ${EXTRACTDIR}/WEB-INF/classes/iiq.properties \
    dataSource.url \
    "jdbc:mysql:\\/\\/sp-db\\/identityiq?useServerPrepStmts=true\\&tinyInt1isBit=true\\&useUnicode=true\\&characterEncoding=utf8\\&useSSL=false"

## zip it
#RUN sh /iq/create-archive.tc.sh /iq/tmp/extract
#cd $EXTRACTDIR
RUN cd ${EXTRACTDIR} && jar -cvf /iq/app.war *

## deploy it
RUN cp /iq/app.war /usr/local/tomcat/webapps/identityiq.war

