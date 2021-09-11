FROM tomcat:9.0.52
LABEL MAINTAINER=kyree

ARG EXTRACTDIR=/iq/tmp/extract

RUN apt update  && \
    apt install -y unzip vim telnet && \
    mkdir -p $EXTRACTDIR

ARG databaseUsername "root"
ARG databasePassword "password"
ARG databaseType 

ENV DATABSE_USERNAME ${databaseUsername}
ENV DATABASE_PASSWORD ${databasePassword}
ENV DATABASE_TYPE ${databaseType}

## add scripts
ADD iq.init.sh /iq
ADD iq.init.commands /iq
ADD change-prop.sh /iq
ADD uncomment-prop.sh /iq


## add war
ADD identityiq.war /iq

RUN cp /iq/identityiq.war /iq/app-before-modify.war && \
    rm /iq/identityiq.war

## unzip war
RUN unzip /iq/app-before-modify.war -d $EXTRACTDIR && \
    chmod -R 777 /iq


RUN \
    touch /tmp/docker.build.log && \
    echo "databaseUsername = ${databaseUsername}" >> /tmp/docker.build.log && \
    echo "databasePassword = ${databasePassword}" >> /tmp/docker.build.log && \
    echo "databaseType = -${databaseType}-" >> /tmp/docker.build.log && \
    echo "----- SHOW PROPS ------ " >> /tmp/docker.build.log  && \
    cat /iq/tmp/extract/WEB-INF/classes/iiq.properties | grep dataSource | grep -v "#"  >> /tmp/docker.build.log  && \
    echo "-----  SHOW PROPS ------ "  >> /tmp/docker.build.log 


## change the database settings for local access
RUN sh /iq/change-prop.sh \
    ${EXTRACTDIR}/WEB-INF/classes/iiq.properties \
    dataSource.password \
    ${databasePassword} && \
    sh /iq/change-prop.sh \
    ${EXTRACTDIR}/WEB-INF/classes/iiq.properties \
    dataSource.username \ 
    ${databaseUsername}

RUN echo "$SHELL"  >> /tmp/docker.build.log ;

RUN if [ "$databaseType" = "MYSQL" ] ; then \
            echo 'a' >> /tmp/docker.build.log ;\
        fi 


RUN if [[ -z "$databaseType" ]] ; then \
        echo "db type not found" >> /tmp/docker.build.log ; \
    else \ 
        echo "db type found" >> /tmp/docker.build.log ; \
        echo "databaseType is ${databaseType}"; \
        if [ "$databaseType" = "MYSQL" ] ; then \
            echo "db type MYSQL found" >> /tmp/docker.build.log ; \
            sh /iq/change-prop.sh \
            ${EXTRACTDIR}/WEB-INF/classes/iiq.properties \
            dataSource.driverClassName \ 
            "com.mysql.cj.jdbc.Driver" >> /tmp/docker.build.log ;  \
            sh /iq/change-prop.sh \
            ${EXTRACTDIR}/WEB-INF/classes/iiq.properties \
            sessionFactory.hibernateProperties.hibernate.dialect \ 
            "org.hibernate.dialect.MySQL57Dialect"   >> /tmp/docker.build.log ;  \
            sh /iq/change-prop.sh \
            /iq/tmp/extract/WEB-INF/classes/iiq.properties \
            dataSource.url \
            "jdbc:mysql:\\/\\/localhost\\/identityiq?useServerPrepStmts=true\\&tinyInt1isBit=true\\&useUnicode=true\\&characterEncoding=utf8\\&useSSL=false" >> /tmp/docker.build.log ; \
        else \
            echo "db type ORACLE found" >> /tmp/docker.build.log ; \
            sh /iq/change-prop.sh \
            ${EXTRACTDIR}/WEB-INF/classes/iiq.properties \
            dataSource.driverClassName \ 
            "oracle.jdbc.driver.OracleDriver" >> /tmp/docker.build.log ; \
            sh /iq/change-prop.sh \
            /iq/tmp/extract/WEB-INF/classes/iiq.properties \
            sessionFactory.hibernateProperties.hibernate.dialect \ 
            "org.hibernate.dialect.Oracle8iDialect" >> /tmp/docker.build.log ; \
            sh /iq/change-prop.sh \
            /iq/tmp/extract/WEB-INF/classes/iiq.properties \
            dataSource.url \
            "jdbc:oracle:thin:@localhost:1521:XE " >> /tmp/docker.build.log ; \
        fi \
    fi

RUN echo "----- SHOW PROPS ------ " >> /tmp/docker.build.log  && \
    cat /iq/tmp/extract/WEB-INF/classes/iiq.properties | grep dataSource | grep -v "#"  >> /tmp/docker.build.log  && \
    echo "-----  SHOW PROPS ------ "  >> /tmp/docker.build.log 

RUN sh /iq/uncomment-prop.sh \
    ${EXTRACTDIR}/WEB-INF/classes/packtag.properties \
    resources.checktimestamps

RUN sh /iq/change-prop.sh \
    ${EXTRACTDIR}/WEB-INF/classes/packtag.properties \
    resources.checktimestamps \ 
    false



## run app init
RUN sh /iq/iq.init.sh \
   ${EXTRACTDIR} \
   /iq/iq.init.commands

## change the database to the target docker db for deploy
RUN if [[ -z "$databaseType" ]] ; then \
        echo "db type not found" >> /tmp/docker.build.log ; \
    else \ 
        echo "db type found" >> /tmp/docker.build.log ; \
        if [ "$databaseType" = "MYSQL" ] ; then \
            sh /iq/change-prop.sh \
            /iq/tmp/extract/WEB-INF/classes/iiq.properties \
            dataSource.url \
            "jdbc:mysql:\\/\\/sp-db\\/identityiq?useServerPrepStmts=true\\&tinyInt1isBit=true\\&useUnicode=true\\&characterEncoding=utf8\\&useSSL=false" ; \
        else \
            sh /iq/change-prop.sh \
            /iq/tmp/extract/WEB-INF/classes/iiq.properties \
            dataSource.url \
            "jdbc:oracle:thin:@sp-db:1521:XE " ; \
        fi \
    fi

## zip it
RUN cd ${EXTRACTDIR} && jar -cvf /iq/app.war *

## deploy it
RUN cp /iq/app.war /usr/local/tomcat/webapps/identityiq.war

