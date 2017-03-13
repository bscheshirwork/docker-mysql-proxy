FROM debian:jessie
# docker build -t bscheshir/mysql-proxy:0.8.5 .
MAINTAINER BSCheshir <bscheshir.work@gmail.com>

ENV MYSQL_PROXY_VERSION 0.8.5
ENV MYSQL_PROXY_TAR_NAME mysql-proxy-$MYSQL_PROXY_VERSION-linux-debian6.0-x86-64bit

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install wget && \
    wget https://downloads.mysql.com/archives/get/file/$MYSQL_PROXY_TAR_NAME.tar.gz && \
    tar -xzvf $MYSQL_PROXY_TAR_NAME.tar.gz && \
    mv $MYSQL_PROXY_TAR_NAME /opt/mysql-proxy && \
    rm $MYSQL_PROXY_TAR_NAME.tar.gz && \
    DEBIAN_FRONTEND=noninteractive apt-get -y remove wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/ && \
    chown -R root:root /opt/mysql-proxy
RUN echo "#!/bin/bash\n\
\n\
exec /opt/mysql-proxy/bin/mysql-proxy \\\\\n\
--keepalive \\\\\n\
--log-level=debug \\\\\n\
--plugins=proxy \\\\\n\
--proxy-address=\${PROXY_DB_HOST}:\${PROXY_DB_PORT} \\\\\n\
--proxy-backend-addresses=\${REMOTE_DB_HOST}:\${REMOTE_DB_PORT} \\\\\n\
--proxy-lua-script=\${LUA_SCRIPT}\n\
" >> /opt/entrypoint.sh && \
    chmod u+x /opt/entrypoint.sh
EXPOSE 4040 4041

ENTRYPOINT [ "/opt/entrypoint.sh" ]


# For another derived image:

# --help-all
# --proxy-backend-addresses=mysql:3306
# --proxy-skip-profiling
# --proxy-backend-addresses=host:port
# --proxy-read-only-backend-addresses=host:port
# --keepalive
# --admin-username=User
# --admin-password=Password
# --log-level=crititcal
# The log level to use when outputting error messages.
# Messages with that level (or lower) are output.
# For example, message level also outputs message with info, warning, and error levels.