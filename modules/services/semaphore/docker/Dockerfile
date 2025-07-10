FROM semaphoreui/semaphore:latest

USER root

RUN apk --no-cache add tzdata && ln -s /usr/share/zoneinfo/Australia/Darwin /etc/localtime

RUN apk --no-cache add \
    su-exec \
    python3 \
    py3-pip \
    build-base \
    python3-dev \
    krb5-dev \
    krb5

RUN pip3 install --upgrade pip \
    && pip3 install \
    pywinrm \
    requests \
    pykerberos \
    krb5 \
    ldap3 \
    dnspython \
    pyspnego \
    pyspnego[kerberos] \
    sansldap

USER semaphore
