# Periodically backup PostgreSQL container by using pg_dump over ssh using docker to local filesystem

It's same as [docker-postgres-backup-local](https://github.com/prodrigestivill/docker-postgres-backup-local), 
But:
1. Used `pg_dump` over ssh
2. Backup from remote PostgreSQL container


## Usage

```bash
    $ git clone https://github.com/omidraha/periodic-pgdump-over-ssh && cd periodic-pgdump-over-ssh
    $ docker build -t omidraha/periodic-pgdump-over-ssh .
    $ mv env.example.sh env.sh
    $ source env.sh
    $ docker-compose up -d
```

### Environment Variables

| env variable | description |
|--|--|
| SSH_REMOTE_USER | Username of remote server. Defaults to `ubuntu`. |
| SSH_REMOTE_HOST | Host of remote server. Defaults to `example.com`. |
| POSTGRES_DB_CONTAINER_NAME | Postgres container name on the remote server. Defaults to `db_1`. |
| POSTGRES_DB | Comma or space separated list of postgres databases to backup. Required. |
| POSTGRES_USER | Postgres connection parameter; postgres user to connect with. Required. |
