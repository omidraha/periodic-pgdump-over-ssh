#!/usr/bin/env bash
export SSH_REMOTE_USER=ubuntu
export SSH_REMOTE_HOST=example.com
export POSTGRES_DB_CONTAINER_NAME=db_1
export POSTGRES_DB=postgres
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres
export POSTGRES_PORT=5432
export POSTGRES_DB_FILE=**None**
export POSTGRES_USER_FILE=**None**
export POSTGRES_PASSWORD_FILE=**None**
export POSTGRES_EXTRA_OPTS='-Z9'
export SCHEDULE='@every 6h'
export BACKUP_DIR='/backups'
export BACKUP_KEEP_DAYS=7
export BACKUP_KEEP_WEEKS=4
export BACKUP_KEEP_MONTHS=6
export HEALTHCHECK_PORT=8080

