FROM centos/mariadb-101-centos7:10.1

USER root

ENV JAVA_HOME /usr/lib/jvm/java-openjdk

RUN yum install -y java-1.8.0-openjdk-devel expect

EXPOSE 3306

VOLUME ["/var/lib/mysql/data"]

COPY custom/cleanup.sh /tmp/checker.sh

RUN chown mysql:mysql /tmp/checker.sh && \
    chmod +x /tmp/checker.sh
	
USER 27

ENTRYPOINT ["container-entrypoint"]

CMD ["sh","-c","(run-mysqld) & (/tmp/checker.sh &) & (tail -f /dev/null)"]