FROM rust:latest AS dev

WORKDIR /workspace

RUN apt-get update && apt-get install -y make && rm -rf /var/lib/apt/lists/*

COPY Cargo.toml Cargo.lock ./

RUN cargo fetch

COPY . .

CMD ["cargo", "run"]
