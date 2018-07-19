ARG WILDFLY_VERSION=10.1.0.Final
FROM jboss/wildfly:${WILDFLY_VERSION}

COPY sqlserver ${JBOSS_HOME}/modules/system/layers/base/com/microsoft/sqlserver
COPY start.sh /

# Set the SQLSRV_JDBC_VERSION env variable
ENV SQLSRV_JDBC_VERSION 6.4.0
ENV SQLSRV_JDBC_SHA512 518daa58a7c21a74483b7afc01a5e6c798d2c1dc24d0545414a83b92a592089251a686df3191c925912c3c60c41a68dd9e7660df604cf944e0aca0c2ad58924a
ENV JRE_VERSION=8

USER root

# Add the driver jar, and make wildfly the owner of the added folder
RUN cd $HOME \
	&& SQLSRV_JDBC_JAR=mssql-jdbc-${SQLSRV_JDBC_VERSION}.jre${JRE_VERSION}.jar \
    && curl -LO https://github.com/Microsoft/mssql-jdbc/releases/download/v${SQLSRV_JDBC_VERSION}/${SQLSRV_JDBC_JAR} \
    && sha512sum ${SQLSRV_JDBC_JAR} | grep $SQLSRV_JDBC_SHA512 \
    && mv ${SQLSRV_JDBC_JAR} ${JBOSS_HOME}/modules/system/layers/base/com/microsoft/sqlserver/main \
	&& sed -i "s#SQLSRV_JDBC_JAR#${SQLSRV_JDBC_JAR}#" ${JBOSS_HOME}/modules/system/layers/base/com/microsoft/sqlserver/main/module.xml \
    && chown -R jboss:0 ${JBOSS_HOME}/modules/system/layers/base/com/microsoft/sqlserver \
    && chmod -R 775 ${JBOSS_HOME}/modules/system/layers/base/com/microsoft/sqlserver \
    && chmod -R 664 ${JBOSS_HOME}/modules/system/layers/base/com/microsoft/sqlserver/main/* \
    && chown jboss:0 /start.sh \
    && chmod 550 /start.sh

USER jboss

ENV SQL_SERVER= SQL_SERVER_PORT=1433

CMD ["/start.sh", "-b", "0.0.0.0"]