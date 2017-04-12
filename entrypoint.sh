#!/bin/sh

set +e

BACKUP_CRON_SCHEDULE=${BACKUP_CRON_SCHEDULE}
echo "${BACKUP_CRON_SCHEDULE} /app/backup" > /etc/crontabs/root
# Starting cron
crond -f -d 0
