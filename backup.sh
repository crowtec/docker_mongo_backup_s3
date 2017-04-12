#!/bin/sh
echo "Crowtec Backup tool is starting..."

backup_name="$(date -u +%Y-%m-%d_%H-%M-%S)_UTC.enc"

mongo_host=$(echo $MONGO_URL | sed -n "s/^mongodb\:\/\/\(\S*\)\:.*$/\1/p")
mongo_port=$(echo $MONGO_URL | sed -n "s/^mongodb\:\/\/.*\:\(\S*\)\/.*$/\1/p")
mongo_database=$(echo $MONGO_URL | sed -n "s/^mongodb\:\/\/.*\/\(\S*\)$/\1/p")

cd /tmp/
# Create backup
mongodump -h ${mongo_host}:${mongo_port} -d ${mongo_database} -o dump
echo "Backup created"
# Compress backup
tar -cvzf dump.gz dump
echo "Backup compressed"
# Encrypt backup
openssl enc -aes-256-cbc -e -in dump.gz -out ${backup_name} -k ${ENCRYPT_PWD}
echo "Backup encrypted"

base_dir="s3://${S3_BUCKET}/${S3_PATH}"

# Upload daily backup
aws s3 cp "${backup_name}" "${base_dir}/daily/${backup_name}"
echo "Daily backup uploaded"

# Upload monthly backup
if [ "$(date -u +%d)" == "01" ];
then
  aws s3 cp "${backup_name}" "${base_dir}/monthly/$(date -u +%Y)/$(date -u +%m)/${backup_name}"
  echo "Monthly backup uploaded"
fi

# Remove extra backups
daily_list=$(aws s3 ls "${base_dir}/daily/")
daily_size=$(echo "${daily_list}" | wc -l)
echo "Daily size is ${daily_size}"

while [ ${daily_size} -gt ${MAX_BACKUPS} ];
do
  file_tbd=$(echo "${daily_list}" | sort | head -n 1 | awk '{ print $NF }')
  aws s3 rm "${base_dir}/daily/${file_tbd}"
  daily_size=$(expr $daily_size - 1)
  echo "Removed 1 backup"
done

# Clean tmp
rm -rf /tmp/*
echo "/tmp cleaned"

echo "All finished! *CAW*"
