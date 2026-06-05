# --- Stage 1: Build the Rust application ---
FROM rust:1.75-bookworm AS builder

# Set working directory
WORKDIR /app

# Copy dependency files first (for layer caching)
COPY Cargo.toml .
COPY Cargo.lock .

# Install dependencies
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    cargo build --release

# Copy source code
COPY src/ ./src/

# Build again with all files present
RUN cargo build --release

# --- Stage 2: Final runtime image (minimal, no Rust toolchain) ---
FROM debian:bookworm-slim

# Install any system dependencies if needed
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built binary from builder stage
COPY --from=builder /app/target/release/ ./target/release/

# Set executable permission (if using a compiled binary)
RUN chmod +x /app/target/release/*.bin \
    || true  # Optional: adjust if your build outputs something else

# Expose ports if your app needs them (not needed for CLI hello-world)
EXPOSE 8080  # Example port if you add HTTP

# Default command to run the application
ENTRYPOINT ["/app/target/release/hello_world"]

# Alternative: Run as a script or binary directly
CMD ["./target/release/hello_world"]
