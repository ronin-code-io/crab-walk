FROM rust:1.79-alpine AS chef
USER root
RUN apk add --no-cache musl-dev & cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json

RUN cargo chef cook --release --recipe-path recipe.json

COPY . .
RUN cargo build --release --bin crab-walk

FROM debian:buster-slim as runtime

USER root

WORKDIR /usr/local/bin

COPY --from=builder /app/target/release/crab-walk ./
CMD ["crab-walk"]
