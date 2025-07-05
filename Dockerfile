ARG BASE_IMAGE=localhost/oraclelinux:8
FROM ${BASE_IMAGE}
LABEL maintainer="Gaurav Tiwari<gaurav.aiuverse@ibm.com>"

ARG INSTALLER
RUN : ${INSTALLER:?}

# Set environment variables
ENV OGG_HOME="/u01/ogg"
ENV OGG_DEPLOYMENT_HOME="/u02"
ENV OGG_TEMPORARY_FILES="/u03"
ENV OGG_DEPLOYMENT_SCRIPTS="/u01/ogg/scripts"
ENV JAVA_HOME="/usr/lib/jvm/java-11"
ENV PATH="${OGG_HOME}/bin:${JAVA_HOME}/bin:${PATH}"
ENV CLASSPATH="${OGG_HOME}/lib/*:/opt/ogg/dependencies/cassandra-java-driver/*"

# Install system dependencies
RUN dnf install -y java-11-openjdk wget unzip && dnf clean all

# Copy installers and scripts
COPY install-*.sh /tmp/
COPY ${INSTALLER} /tmp/installer.zip
COPY bin/ /usr/local/bin/
COPY cassandra-drivers/ /opt/ogg/dependencies/cassandra-java-driver/
COPY config/dirprm/ ${OGG_HOME}/dirprm/
COPY config/cassandra.props ${OGG_HOME}/dirprm/cassandra.props

# Install GoldenGate and configure deployment during build
RUN chmod +x /tmp/* /usr/local/bin/*
RUN /tmp/install-prerequisites.sh && /tmp/install-deployment.sh \
    rm -rf /tmp/* /etc/nginx

# Copy nginx certs if needed (optional)
COPY nginx/ /etc/nginx/

# Expose required ports
EXPOSE 443 7809 9011 9012 9015

# Declare volumes
VOLUME [ "${OGG_DEPLOYMENT_HOME}", "${OGG_TEMPORARY_FILES}", "${OGG_DEPLOYMENT_SCRIPTS}" ]

# Healthcheck (optional)
HEALTHCHECK --start-period=90s --retries=1 \
  CMD [ "/usr/local/bin/healthcheck" ]

# Entry point starts replicat and keeps container alive
ENTRYPOINT ["/usr/local/bin/start.sh"]