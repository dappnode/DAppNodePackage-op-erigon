ARG UPSTREAM_VERSION

FROM alpine:3.18.3 as build

RUN apk update && apk add wget && apk add tar

# Get OP Erigon from Github repo (The name of the file does not include the 'v' prefix in the version)
RUN wget https://github.com/testinprod-io/op-erigon/releases/download/${UPSTREAM_VERSION}/op-erigon_${UPSTREAM_VERSION:1}_linux_amd64.tar.gz

# Extract the tarball and geth the binary (called erigon)
RUN tar -xvf op-erigon_${UPSTREAM_VERSION:1}_linux_amd64.tar.gz && mv op-erigon_${UPSTREAM_VERSION:1}_linux_amd64/erigon /usr/local/bin/erigon

FROM alpine:3.18.3 as production

RUN apk update && apk add wget && apk add zstd

COPY --from=build /usr/local/bin/erigon /usr/local/bin/erigon

RUN mkdir /config

COPY /security/jwtsecret.hex /config/jwtsecret.hex
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]