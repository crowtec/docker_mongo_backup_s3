#!/bin/sh

set +e
envsubst < /root/.s3cfg-template > /root/.s3cfg
BACKUP_CRON_SCHEDULE=${BACKUP_CRON_SCHEDULE}
echo "${BACKUP_CRON_SCHEDULE} /app/backup" > /etc/crontabs/root
# Starting cron
crond -f -d 0
