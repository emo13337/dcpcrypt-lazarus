# DCPcrypt CI/CD Pipeline

This directory contains GitHub Actions workflow definitions for automated building, testing, and releasing of DCPcrypt.

## Workflow Overview

### ci.yml

The main continuous integration workflow that runs on every push and pull request.

```mermaid
flowchart TD
    subgraph Triggers
        T1[Push to main/master/develop]
        T2[Pull Request]
        T3[Manual Dispatch]
    end

    subgraph Stage1[" "]
        BAT[build-and-test<br/>Linux Docker container]
    end

    subgraph Stage2[" "]
        REL[release<br/>Only on v* tags]
    end

    T1 --> BAT
    T2 --> BAT
    T3 --> BAT

    BAT --> REL
```

```
┌─────────────────────────────────────────────────────────────┐
│                        TRIGGERS                             │
│  - Push to main, master, develop                            │
│  - Pull requests to main, master, develop                   │
│  - Manual workflow dispatch                                 │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          v
┌─────────────────────────────────────────────────────────────┐
│                    build-and-test                            │
│                                                             │
│  Container: wimmercg/lazarus-docker:1.2.0                   │
│  (Debian 12 slim + FPC 3.2.2 + Lazarus)                    │
│                                                             │
│  - make check        (build + run 282 tests)                │
│  - make build-examples (console + GUI examples)             │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          v  (only on v* tags)
                ┌─────────────────────┐
                │      release        │
                │                     │
                │  Creates GitHub     │
                │  release            │
                └─────────────────────┘
```

### Pipeline Stages

**Stage 1: build-and-test**
- Runs on Ubuntu inside a Docker container with FPC and Lazarus pre-installed
- Docker image: `wimmercg/lazarus-docker:1.2.0` (Debian 12 slim, FPC 3.2.2, Lazarus from Git sources)
- Builds and runs all 282 tests via `make check`
- Builds all examples (console + GUI) via `make build-examples`
- No SourceForge dependency — the Docker image is built from Git sources

**Stage 2: release**
- Only triggered on version tags (v*)
- Creates GitHub release with auto-generated notes

## Jobs Description

| Job | Runs On | Container | Dependencies | Purpose |
|-----|---------|-----------|--------------|---------|
| `build-and-test` | ubuntu-latest | `wimmercg/lazarus-docker:1.2.0` | None | Build, test, and verify examples |
| `release` | ubuntu-latest | — | `build-and-test` | Create GitHub release (tags only) |

## Test Suites

| Test Program | Tests | Coverage |
|--------------|-------|----------|
| `test_hashes` | 90 | SelfTest, digest correctness, determinism, Burn for all 10 hashes |
| `test_ciphers` | 139 | SelfTest, encrypt/decrypt roundtrip, Burn, properties for all 20 ciphers |
| `test_block_modes` | 28 | ECB, CBC, CFB8bit, CFBblock, OFB, CTR for Rijndael and Blowfish |
| `test_base64` | 11 | Encode/decode roundtrips, RFC 4648 known values, binary data |
| `test_stream_encrypt` | 14 | Salt+IV stream encryption, PartialEncryptStream, OnProgressEvent |

**Total: 282 tests**

## Examples

| Example | Type | Build Tool |
|---------|------|------------|
| `demo_encrypt_string` | Console | `fpc` |
| `demo_file_encrypt` | Console | `fpc` |
| `EncryptStringsViaEncryptStream` | GUI (LCL) | `lazbuild` |
| `EncryptFileUsingThread` | GUI (LCL) | `lazbuild` |

## Docker Image

The CI uses [`wimmercg/lazarus-docker:1.2.0`](https://hub.docker.com/r/wimmercg/lazarus-docker) which provides:

- **Base**: Debian 12 slim
- **FPC**: 3.2.2 (compiled from Git tag)
- **Lazarus**: lazbuild (compiled from Git main branch)
- **No SourceForge**: everything is built from Git sources

Source: [ChrisWiGit/lazarus-docker](https://github.com/ChrisWiGit/lazarus-docker)

## Triggering Workflows

### Automatic Triggers

- **Push**: Any push to `main`, `master`, or `develop` branches
- **Pull Request**: Any PR targeting `main`, `master`, or `develop`

### Manual Trigger

1. Navigate to **Actions** tab in GitHub
2. Select **CI** workflow
3. Click **Run workflow**
4. Select branch and confirm

### Release Trigger

Releases are created automatically when pushing version tags:

```bash
git tag v2.0.5
git push origin v2.0.5
```

## Local Testing

Run the same tests locally using the Makefile:

```bash
make build            # compile all test programs
make test             # build and run all tests
make build-examples   # compile all examples (console + GUI)
make build-all        # compile everything (tests + examples)
make check            # clean, build and run (full verification)
make info             # show project information
```

Or manually:

```bash
# Build
fpc -Mdelphi -FEtests -Fusrc -Fusrc/Ciphers -Fusrc/Hashes -Futests tests/test_hashes.lpr

# Run
tests/test_hashes
```

## Troubleshooting

### Build Failures

| Issue | Solution |
|-------|----------|
| `Identifier not found: Result` | Ensure `-Mdelphi` flag is used (dcpbase64.pas requires Delphi mode) |
| GTK2 not found (GUI examples) | Install `libgtk2.0-dev` locally |

### Test Failures

| Issue | Solution |
|-------|----------|
| Gost SelfTest warning | Known upstream issue - test vectors don't match implementation. Encrypt/decrypt roundtrip works correctly. |
| Binary not found | Check that `-FEtests` flag places binaries in `tests/` directory |

## See Also

- [docs/README.md](../../docs/README.md) - Project documentation
- [docs/CHANGELOG.md](../../docs/CHANGELOG.md) - Version history
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [lazarus-docker](https://github.com/ChrisWiGit/lazarus-docker) - Docker image used in CI
