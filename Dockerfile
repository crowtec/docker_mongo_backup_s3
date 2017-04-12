FROM alpine:edge
MAINTAINER Crowtec <info@crowtec.eu>

RUN echo http://dl-4.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk --update add --no-cache mongodb-tools py2-pip openssl
RUN pip install awscli

RUN mkdir /backup

ENV S3_PATH=mongodb
ENV AWS_DEFAULT_REGION=us-east-1
ENV BACKUP_DIR=.

ADD entrypoint.sh /app/entrypoint
ADD backup.sh /app/backup

RUN chmod +x /app/*

# VOLUME /backup

CMD /app/entrypoint
