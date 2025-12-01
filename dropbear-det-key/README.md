# Dropbear Deterministic Key Generator

This tool generates a deterministic Dropbear SSH host key (Ed25519) from a given input file.

## Purpose

When building embedded systems or reproducible environments, it is often desirable to have a consistent SSH host key that is derived from a secret or configuration file, rather than generating a random key on first boot. This tool allows you to pre-seed the Dropbear host key in a deterministic way.

## Usage

```bash
dropbear-det-key <input_seed_file> <output_key_file>
```

### Arguments

*   `<input_seed_file>`: Path to any file (text or binary). The contents of this file are hashed to create the key seed.
*   `<output_key_file>`: Path where the generated Dropbear key will be written.

### Example

```bash
echo "my-secret-seed-value" > seed.txt
dropbear-det-key seed.txt /etc/dropbear/dropbear_ed25519_host_key
```

## How It Works

1.  **Input Hashing**: The tool reads the entire content of the input file and calculates its SHA-256 hash.
2.  **Key Generation**: The 32-byte SHA-256 hash is used as the private seed to generate an Ed25519 keypair.
3.  **Serialization**: The keypair is serialized into the Dropbear private key format:
    *   `ssh-ed25519` identifier (SSH string format)
    *   Combined private + public key material (64 bytes, SSH string format)
4.  **Permissions**: On Unix-like systems, the output file permissions are set to `0600` (read/write only for the owner) to satisfy SSH security requirements.

## Building

This project is a standard Rust application.

```bash
cargo build --release
```

To run tests:

```bash
cargo test
```
