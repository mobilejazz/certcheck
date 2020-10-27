FROM alpine:3.10
RUN apk add --update --no-cache ca-certificates msmtp bash openssl coreutils \
    && rm -rf /tmp/*

# update sendmail alias
RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail

COPY certcheck.sh /
ENTRYPOINT /certcheck.sh