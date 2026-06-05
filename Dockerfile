# Use a standard build image, then extract binary for minimal runtime
FROM rust:alpine AS builder
WORKDIR /app
COPY Cargo.toml ./
COPY src ./src

RUN --mount=type=cache,target=/root/.cargo REGISTRY=https://index.docker.io/v1/ cargo build --release --target x86_64-unknown-linux-musl

FROM alpine:latest AS runtime
WORKDIR /root/app
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/hello_world .
ENV RUST_BACKTRACE=1

RUN apk add ca-certificates && \
    adduser -D -S -u 65532 nobody appuser && \
    chown appuser:appuser /root/app/

USER nobody
CMD ["./hello_world"]
