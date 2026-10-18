FROM ubuntu:22.04 AS build

ARG RUST_VERSION=1.88.0
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential ca-certificates curl git pkg-config libssl-dev \
    && rm -rf /var/lib/apt/lists/*
RUN curl --fail --show-error --silent --location https://sh.rustup.rs --output /tmp/rustup-init.sh \
    && sh /tmp/rustup-init.sh -y --profile minimal --default-toolchain "${RUST_VERSION}" \
    && rm /tmp/rustup-init.sh
ENV PATH=/root/.cargo/bin:${PATH}
WORKDIR /src
COPY . .
RUN git apply --check patches/windows-itunes-client-info.patch \
    && git apply patches/windows-itunes-client-info.patch \
    && cargo build --locked --release --package plumesign

FROM scratch
COPY --from=build /src/target/release/plumesign /plumesign
