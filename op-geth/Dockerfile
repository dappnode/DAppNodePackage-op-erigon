ARG UPSTREAM_VERSION

# TODO: DockerHub looks out of date for Optimism. We might need to build from source 
FROM us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:${UPSTREAM_VERSION}

RUN mkdir /config

COPY /security/jwtsecret.hex /config/jwtsecret.hex
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk update && apk add wget && apk add zstd

# Get Genesis file for Optimism (not needed for mainnet and goerli)
#RUN wget -O /config/genesis.json <URL to genesis JSON> # TODO: What is the genesis file?

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]