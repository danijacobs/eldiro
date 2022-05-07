# Build Stage: 
FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install -f cargo-fuzz

# ADD . /mayhem-cmake-example <-- the file where Docker and Mayhem file are
ADD . /eldiro
WORKDIR /eldiro

# Build Instructions 
RUN cd fuzz && ${HOME}/.cargo/bin/cargo fuzz build

# Package Stage
FROM ubuntu:20.04

## path in builder stage
COPY --from=builder eldiro/fuzz/target/x86_64-unknown-linux-gnu/release/main /