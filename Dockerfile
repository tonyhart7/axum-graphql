FROM --platform=linux/amd64 lukemathwalker/cargo-chef:latest-rust-1.72.0 AS chef

WORKDIR /app

FROM --platform=linux/amd64 chef AS planner

COPY . .

RUN cargo chef prepare --recipe-path recipe.json

FROM --platform=linux/amd64 chef AS builder

COPY --from=planner /app/recipe.json recipe.json

RUN cargo chef cook --release --recipe-path recipe.json

COPY . .

RUN cargo build --release

FROM alpine:latest

RUN addgroup -g 999 appuser && \
    adduser -u 999 -G appuser -s /bin/sh -D appuser

USER appuser

COPY --from=builder /app/target/release/axum-graphql /app

WORKDIR /app

ENV JAEGER_ENABLED=true

EXPOSE 8000

ENTRYPOINT ["./axum-graphql"]
