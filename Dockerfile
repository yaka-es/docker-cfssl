#
# docker-cfssl/Dockerfile
#

FROM golang:alpine

# install bash, nginx, git and go
# clean out apk cache files
RUN set -ex \
    && apk add --no-cache --virtual --update build-base git bash nginx \
    && rm -rf /var/cache/apk/*

# install cloudflare cfssl and goose (for certdb migrations)
# bundle up trusted intermediate ca certs and roots
# point nginx nginx logs to stdout + stderr
# make /etc/cfssl/data and adjust permissions
RUN set -ex \
    && go get -u github.com/cloudflare/cfssl/cmd/cfssl \
    && go get -u github.com/cloudflare/cfssl/cmd/... \
    && go get bitbucket.org/liamstask/goose/cmd/goose \
    && git clone https://github.com/cloudflare/cfssl_trust.git /etc/cfssl \
    && mkbundle -f /etc/cfssl/int-bundle.crt /etc/cfssl/intermediate_ca/ \
    && mkbundle -f /etc/cfssl/ca-bundle.crt /etc/cfssl/trusted_roots/ \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir /etc/cfssl/data \
    && chmod 755 $(find /etc/cfssl -type d) \
    && chmod 644 $(find /etc/cfssl -type f)

# define defaults for env variables
ENV CFSSL_CA_HOST=example.local \
    CFSSL_CA_ALGO=rsa \
    CFSSL_CA_KEY_SIZE=4096 \
    CFSSL_CA_ORGANIZATION="Example, Inc." \
    CFSSL_CA_ORGANIZATIONAL_UNIT="Internal Certificate Authority" \
    CFSSL_CA_POLICY_FILE=/etc/cfssl/data/ca_policy.json \
    CFSSL_CA_COMMON_NAME="Example Root CA"

# define volumes and workdir
VOLUME /etc/cfssl/data
WORKDIR /etc/cfssl/data

# expose ssl port for nginx to server requests
EXPOSE 443

# copy in files for running cfssl and nginx config
COPY start-cfssl /start-cfssl
COPY nginx.conf /etc/nginx/nginx.conf

# define entrypoint command
CMD [ "/start-cfssl" ]
