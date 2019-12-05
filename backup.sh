#! /bin/sh

set -e

if [ "${POSTGRES_DB}" = "**None**" -a "${POSTGRES_DB_FILE}" = "**None**" ]; then
  echo "You need to set the POSTGRES_DB or POSTGRES_DB_FILE environment variable."
  exit 1
fi

if [ "${POSTGRES_HOST}" = "**None**" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=${POSTGRES_PORT_5432_TCP_ADDR}
    POSTGRES_PORT=${POSTGRES_PORT_5432_TCP_PORT}
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ "${POSTGRES_USER}" = "**None**" -a "${POSTGRES_USER_FILE}" = "**None**" ]; then
  echo "You need to set the POSTGRES_USER or POSTGRES_USER_FILE environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "**None**" -a "${POSTGRES_PASSWORD_FILE}" = "**None**" ]; then
  echo "You need to set the POSTGRES_PASSWORD or POSTGRES_PASSWORD_FILE environment variable or link to a container named POSTGRES."
  exit 1
fi

#Process vars
if [ "${POSTGRES_DB_FILE}" = "**None**" ]; then
  POSTGRES_DBS=$(echo "${POSTGRES_DB}" | tr , " ")
elif [ -r "${POSTGRES_DB_FILE}" ]; then
  POSTGRES_DBS=$(cat "${POSTGRES_DB_FILE}")
else
  echo "Missing POSTGRES_DB_FILE file."
  exit 1
fi
if [ "${POSTGRES_USER_FILE}" = "**None**" ]; then
  export PGUSER="${POSTGRES_USER}"
elif [ -r "${POSTGRES_USER_FILE}" ]; then
  export PGUSER=$(cat "${POSTGRES_USER_FILE}")
else
  echo "Missing POSTGRES_USER_FILE file."
  exit 1
fi
if [ "${POSTGRES_PASSWORD_FILE}" = "**None**" ]; then
  export PGPASSWORD="${POSTGRES_PASSWORD}"
elif [ -r "${POSTGRES_PASSWORD_FILE}" ]; then
  export PGPASSWORD=$(cat "${POSTGRES_PASSWORD_FILE}")
else
  echo "Missing POSTGRES_PASSWORD_FILE file."
  exit 1
fi
POSTGRES_HOST_OPTS="-p ${POSTGRES_PORT} ${POSTGRES_EXTRA_OPTS}"
KEEP_DAYS=${BACKUP_KEEP_DAYS}
KEEP_WEEKS=`expr $(((${BACKUP_KEEP_WEEKS} * 7) + 1))`
KEEP_MONTHS=`expr $(((${BACKUP_KEEP_MONTHS} * 31) + 1))`

#Initialize dirs
mkdir -p "/var/opt/pgbackups/daily/" "/var/opt/pgbackups/weekly/" "/var/opt/pgbackups/monthly/"


#Loop all databases
for DB in ${POSTGRES_DBS}; do
  #Initialize filename vers
  DFILE="/var/opt/pgbackups/daily/${DB}-`date +%Y%m%d-%H%M%S`.sql.gz"
  WFILE="/var/opt/pgbackups/weekly/${DB}-`date +%G%V`.sql.gz"
  MFILE="/var/opt/pgbackups/monthly/${DB}-`date +%Y%m`.sql.gz"
  echo "Backup file will be store in  ${DFILE}"
  #Create dump
  echo "Creating dump of ${DB} database from ${SSH_REMOTE_USER}@${SSH_REMOTE_HOST} inside of ${POSTGRES_DB_CONTAINER_NAME} container ..."
  ssh ${SSH_REMOTE_USER}@${SSH_REMOTE_HOST} docker exec ${POSTGRES_DB_CONTAINER_NAME} pg_dump -U  ${PGUSER} ${POSTGRES_HOST_OPTS} ${DB} > ${DFILE}
  #Copy (hardlink) for each entry
  ln -vf "${DFILE}" "${WFILE}"
  ln -vf "${DFILE}" "${MFILE}"
  #Clean old files
  echo "Cleaning older than ${KEEP_DAYS} days for ${DB} database from ${SSH_REMOTE_USER}@${SSH_REMOTE_HOST} inside of ${POSTGRES_DB_CONTAINER_NAME} container ..."
  find "/var/opt/pgbackups/daily" -maxdepth 1 -mtime +${KEEP_DAYS} -name "${DB}-*.sql*" -exec rm -rf '{}' ';'
  find "/var/opt/pgbackups/weekly" -maxdepth 1 -mtime +${KEEP_WEEKS} -name "${DB}-*.sql*" -exec rm -rf '{}' ';'
  find "/var/opt/pgbackups/monthly" -maxdepth 1 -mtime +${KEEP_MONTHS} -name "${DB}-*.sql*" -exec rm -rf '{}' ';'
done

echo "SQL backup uploaded successfully"
