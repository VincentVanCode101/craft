FROM alpine:3.18

RUN apk add --no-cache shellcheck bash

WORKDIR /workdir

COPY . /workdir

ENTRYPOINT ["/workdir/bin/entrypoint.sh"]
