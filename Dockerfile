FROM postgres:9.4

RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates curl  openssh-client && rm -rf /var/lib/apt/lists/* \
	&& curl -L https://github.com/odise/go-cron/releases/download/v0.0.7/go-cron-linux.gz | zcat > /usr/local/bin/go-cron \
	&& chmod a+x /usr/local/bin/go-cron \
	&& apt-get purge -y --auto-remove ca-certificates && apt-get clean

ENV SSH_REMOTE_USER **None**
ENV SSH_REMOTE_HOST **None**
ENV POSTGRES_DB_CONTAINER_NAME **None**
ENV POSTGRES_DB **None**
ENV POSTGRES_DB_FILE **None**
ENV POSTGRES_PORT 5432
ENV POSTGRES_USER **None**
ENV POSTGRES_USER_FILE **None**
ENV POSTGRES_PASSWORD **None**
ENV POSTGRES_PASSWORD_FILE **None**
ENV POSTGRES_EXTRA_OPTS '-Z9'
ENV SCHEDULE '@daily'
ENV BACKUP_DIR '/backups'
ENV BACKUP_KEEP_DAYS 7
ENV BACKUP_KEEP_WEEKS 4
ENV BACKUP_KEEP_MONTHS 6
ENV HEALTHCHECK_PORT 8080
COPY backup.sh /backup.sh

VOLUME /backups

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["exec /usr/local/bin/go-cron -s \"$SCHEDULE\" -p \"$HEALTHCHECK_PORT\" -- /backup.sh"]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f "http://localhost:$HEALTHCHECK_PORT/" || exit 1
