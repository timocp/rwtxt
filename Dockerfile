FROM golang:1.26.1-bookworm as builder

WORKDIR /src

RUN apt-get update && apt-get install -y --no-install-recommends \
    git make gcc g++ libc6-dev sqlite3 libsqlite3-dev gzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV CGO_ENABLED=1
ENV GOBIN=/go/bin
ENV PATH="/go/bin:${PATH}"

COPY . .

RUN make exec

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

VOLUME /data
EXPOSE 8152
COPY --from=builder /src/rwtxt /rwtxt

ENTRYPOINT ["/rwtxt"]
CMD ["--db","/data/rwtxt.db","--resizeonrequest","--resizewidth","600"]
