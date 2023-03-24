FROM golang:1.20.2 as builder

ARG BUILDER_VERSION=v0.74.0

WORKDIR /build

COPY . /build

# clone otel repo
RUN git clone https://github.com/open-telemetry/opentelemetry-collector --single-branch --branch ${BUILDER_VERSION}

ENV CGO_ENABLED=0

# build ocb
RUN cd opentelemetry-collector && \ 
    go build -C ./cmd/builder/ -o /usr/bin/ocb
    
# build otelcol with ocb
RUN ocb --config builder.yaml

FROM alpine:3.17.2

COPY --from=builder /build/dist/otelcol /usr/bin/otelcol
    
ENTRYPOINT [ "otelcol" ]
CMD ["--help"]