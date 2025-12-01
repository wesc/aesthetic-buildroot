use std::env;
use std::fs;
use std::io::Write;
#[cfg(unix)]
use std::os::unix::fs::PermissionsExt;
use sha2::{Sha256, Digest};
use ed25519_dalek::SigningKey;

fn write_ssh_string(buf: &mut Vec<u8>, data: &[u8]) {
    let len = data.len() as u32;
    buf.extend_from_slice(&len.to_be_bytes());
    buf.extend_from_slice(data);
}

fn generate_key_content(seed_content: &[u8]) -> Vec<u8> {
    // Hash the content to get a deterministic 32-byte seed
    let mut hasher = Sha256::new();
    hasher.update(seed_content);
    let seed = hasher.finalize(); // GenericArray<u8, 32>

    // Convert GenericArray to [u8; 32]
    let seed_array: [u8; 32] = seed.into();

    let signing_key = SigningKey::from_bytes(&seed_array);
    let verifying_key = signing_key.verifying_key();

    let private_bytes = signing_key.to_bytes(); // 32 bytes (seed)
    let public_bytes = verifying_key.to_bytes(); // 32 bytes

    // Construct Dropbear format for ed25519
    // Format:
    // [len] "ssh-ed25519"
    // [len] privkey+pubkey (64 bytes)

    let mut key_data = Vec::new();
    write_ssh_string(&mut key_data, b"ssh-ed25519");

    let mut combined = Vec::with_capacity(64);
    combined.extend_from_slice(&private_bytes);
    combined.extend_from_slice(&public_bytes);
    write_ssh_string(&mut key_data, &combined);

    key_data
}

// Minimal error handling wrapper to avoid pulling in full error formatting machinery
fn run() -> Result<(), String> {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        return Err(format!("Usage: {} <input_seed_file> <output_key_file>\n", args.get(0).unwrap_or(&"dropbear-det-key".to_string())));
    }

    let input_path = &args[1];
    let output_path = &args[2];

    let seed_content = fs::read(input_path).map_err(|e| format!("Failed to read input: {}\n", e))?;
    let key_data = generate_key_content(&seed_content);

    fs::write(output_path, key_data).map_err(|e| format!("Failed to write output: {}\n", e))?;

    // Set permissions to 0600 on Unix systems
    #[cfg(unix)]
    {
        let mut perms = fs::metadata(output_path).map_err(|e| format!("Failed to read metadata: {}\n", e))?.permissions();
        perms.set_mode(0o600);
        fs::set_permissions(output_path, perms).map_err(|e| format!("Failed to set permissions: {}\n", e))?;
    }

    Ok(())
}

fn main() {
    if let Err(msg) = run() {
        let _ = std::io::stderr().write_all(msg.as_bytes());
        std::process::exit(1);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    fn get_fixture_path(filename: &str) -> PathBuf {
        let mut d = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
        d.push("tests/data");
        d.push(filename);
        d
    }

    #[test]
    fn test_regular_seed() {
        let path = get_fixture_path("regular_seed.txt");
        let content = fs::read(path).expect("Failed to read regular_seed.txt");
        let key_data = generate_key_content(&content);

        // Basic validation
        assert_eq!(key_data.len(), 4 + 11 + 4 + 64);
        // Check magic string "ssh-ed25519"
        let magic_len = u32::from_be_bytes(key_data[0..4].try_into().unwrap());
        assert_eq!(magic_len, 11);
        assert_eq!(&key_data[4..15], b"ssh-ed25519");
    }

    #[test]
    fn test_empty_seed() {
        let path = get_fixture_path("empty_seed.txt");
        let content = fs::read(path).expect("Failed to read empty_seed.txt");
        let key_data = generate_key_content(&content);

        assert_eq!(key_data.len(), 4 + 11 + 4 + 64);
        assert_eq!(&key_data[4..15], b"ssh-ed25519");
    }

    #[test]
    fn test_binary_seed() {
        let path = get_fixture_path("binary_seed.bin");
        let content = fs::read(path).expect("Failed to read binary_seed.bin");
        let key_data = generate_key_content(&content);

        assert_eq!(key_data.len(), 4 + 11 + 4 + 64);
        assert_eq!(&key_data[4..15], b"ssh-ed25519");
    }
}
