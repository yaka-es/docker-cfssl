FROM golang:1.7
MAINTAINER  Ankur Chauhan <ankur@malloc64.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN set -ex \
    && go get -u github.com/cloudflare/cfssl/cmd/cfssl \
    && go get -u github.com/cloudflare/cfssl/cmd/... \
    && go get bitbucket.org/liamstask/goose/cmd/goose \
    && git clone https://github.com/cloudflare/cfssl_trust.git /etc/cfssl \
    && mkbundle -f /etc/cfssl/int-bundle.crt /etc/cfssl/intermediate_ca/ \
    && mkbundle -f /etc/cfssl/ca-bundle.crt /etc/cfssl/trusted_roots/

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y ca-certificates bash nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /etc/cfssl/data \
    && chmod 777 $(find /etc/cfssl -type d) \
    && chmod 666 $(find /etc/cfssl -type f)

ENV CFSSL_CA_HOST=example.localnet \
    CFSSL_CA_ALGO=rsa \
    CFSSL_CA_KEY_SIZE=2048 \
    CFSSL_CA_ORGANIZATION="Brightcove, Inc." \
    CFSSL_CA_ORGANIZATIONAL_UNIT="RnA Internal Certificate Authority" \
    CFSSL_CA_POLICY_FILE=/etc/cfssl/data/ca_policy.json

VOLUME /etc/cfssl/data
WORKDIR /etc/cfssl/data
EXPOSE 443

COPY start-cfssl /start-cfssl
COPY nginx.conf /etc/nginx/nginx.conf

CMD [ "/start-cfssl" ]
