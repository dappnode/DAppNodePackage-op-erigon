ARG UPSTREAM_VERSION

FROM testinprod/op-erigon:${UPSTREAM_VERSION}-amd64 as production

RUN apk update && apk add wget && apk add zstd

RUN mkdir /config

COPY /security/jwtsecret.hex /config/jwtsecret.hex
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]