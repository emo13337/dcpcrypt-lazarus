# Console Examples - Build Instructions

## Requirements

- **Free Pascal Compiler (FPC)** 3.2.0 or later
- No IDE or external dependencies required

## Build all at once (Makefile)

From the project root:

```bash
make build-console
```

## Build individually (fpc)

From the project root:

```bash
# String encryption/decryption (Salt + IV + EncryptStream/DecryptStream)
fpc -FEexamples/console -Fusrc -Fusrc/Ciphers -Fusrc/Hashes examples/console/demo_encrypt_string.lpr

# File encryption with progress callback
fpc -FEexamples/console -Fusrc -Fusrc/Ciphers -Fusrc/Hashes examples/console/demo_file_encrypt.lpr

# Hash files using all 10 hash algorithms
fpc -FEexamples/console -Fusrc -Fusrc/Ciphers -Fusrc/Hashes examples/console/demo_hash_file.lpr

# Hash large files (>5 GB) with real-time progress
fpc -FEexamples/console -Fusrc -Fusrc/Ciphers -Fusrc/Hashes examples/console/demo_hash_large_file.lpr
```

## Compiler flags

| Flag | Purpose |
|------|---------|
| `-FEexamples/console` | Output directory for compiled binaries |
| `-Fusrc` | Unit search path: core units |
| `-Fusrc/Ciphers` | Unit search path: cipher implementations |
| `-Fusrc/Hashes` | Unit search path: hash implementations |

## Examples

### demo_encrypt_string

Encrypt/decrypt strings using Salt + IV + EncryptStream/DecryptStream. Tests all 20 ciphers with SHA-256 key derivation.

```bash
./examples/console/demo_encrypt_string
```

### demo_file_encrypt

Encrypt/decrypt files using EncryptStream with `OnProgressEvent` callback. Generates a test file, encrypts it, decrypts it, and verifies the result.

```bash
./examples/console/demo_file_encrypt
```

### demo_hash_file

Hash files using all 10 available hash algorithms (MD4, MD5, SHA-1, SHA-256, SHA-384, SHA-512, RipeMD-128, RipeMD-160, Haval, Tiger). Generates a test file and optionally hashes a user-supplied file.

```bash
./examples/console/demo_hash_file
./examples/console/demo_hash_file /path/to/file
```

### demo_hash_large_file

Hash large files (>5 GB) with real-time progress display (%, MB/s, elapsed time). Uses manual `Hash.Update()` loop with 64 KB blocks to avoid the `UpdateStream` integer counter overflow on files larger than ~17 GB. Algorithms: MD5, SHA-256, SHA-512.

```bash
# Hash an existing file
./examples/console/demo_hash_large_file /path/to/large/file

# Generate and hash a 5 GB test file (default, in /tmp)
./examples/console/demo_hash_large_file

# Generate and hash a 1 GB test file
./examples/console/demo_hash_large_file --size=1

# Use a different directory for the test file (e.g. if /tmp is a small tmpfs)
./examples/console/demo_hash_large_file --size=2 --dir=/home/user
```

Options:
- `--size=N` : size of the generated test file in GB (default: 5)
- `--dir=<path>` : directory for the test file (default: /tmp)

## Cleanup

```bash
make clean-examples
```
