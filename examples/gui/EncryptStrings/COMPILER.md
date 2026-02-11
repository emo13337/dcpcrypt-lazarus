# EncryptStrings - Build Instructions

## Description

GUI application for string encryption/decryption using EncryptStream. Ported from Delphi VCL to Lazarus LCL.

Features:
- Encrypt and decrypt strings with any cipher + hash combination
- Salt + IV + EncryptStream/DecryptStream
- Hexadecimal display of encrypted output

## Requirements

- **Lazarus IDE** 2.0 or later (includes `lazbuild`)
- **Free Pascal Compiler (FPC)** 3.2.0 or later
- **GTK2** development libraries (Linux only)

### Linux (Debian/Ubuntu)

```bash
sudo apt-get install lazarus libgtk2.0-dev
```

### Linux (Fedora/RHEL)

```bash
sudo dnf install lazarus gtk2-devel
```

### Linux (Arch)

```bash
sudo pacman -S lazarus gtk2
```

### Windows / macOS

No additional dependencies beyond Lazarus.

## Build

### Using lazbuild (command line)

From the project root:

```bash
lazbuild examples/gui/EncryptStrings/EncryptStringsViaEncryptStream.lpi
```

### Using Makefile

From the project root:

```bash
make build-gui
```

### Using Lazarus IDE

1. Open `EncryptStringsViaEncryptStream.lpi` in Lazarus
2. Click **Run > Build** (or press Shift+F9)

## Project files

| File | Description |
|------|-------------|
| `EncryptStringsViaEncryptStream.lpi` | Lazarus project file |
| `EncryptStringsViaEncryptStream.lpr` | Program source |
| `uMain.pas` | Main form unit |
| `uMain.lfm` | Main form layout |
| `UnitUtilitaires.pas` | Utility functions |

## Cleanup

```bash
make clean-examples
```
