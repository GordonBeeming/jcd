# Homebrew Publishing for jcd

This document provides detailed instructions for publishing jcd to Homebrew.

## Overview

The jcd project includes comprehensive Homebrew support with:
- Automated formula generation
- SHA256 checksum calculation
- Proper installation scripts
- Shell integration setup
- Test suite for the formula

## Files

- `dist/homebrew/jcd.rb.in` - Homebrew formula template
- `brew-publish.sh` - Helper script for publishing workflow
- Enhanced `makePackages.sh` with brew support

## Quick Start

1. **Build and generate the Homebrew package**:
   ```bash
   ./brew-publish.sh 1.0.0
   ```

2. **Upload the ZIP file to GitHub releases**:
   ```bash
   # Upload target/release/brew/jcd-mac-1.0.0.zip to your GitHub release
   ```

3. **Copy the formula to your Homebrew tap**:
   ```bash
   cp target/release/brew/jcd.rb /path/to/homebrew-tapname/Formula/
   ```

## Detailed Publishing Process

### 1. Prepare the Release

Ensure your version is set correctly in `Cargo.toml` and build the project:

```bash
cargo build --release
```

### 2. Generate the Homebrew Package

Use the brew publish script:

```bash
./brew-publish.sh <version> [custom-url]
```

This will:
- Build the project
- Create a ZIP package with the binary and shell function
- Generate a Homebrew formula with correct SHA256
- Display next steps

### 3. Upload Release Assets

Upload the generated ZIP file (`target/release/brew/jcd-mac-<version>.zip`) to your GitHub release.

### 4. Publish to Homebrew

#### Option A: Custom Tap (Recommended for initial publishing)

1. Create a repository named `homebrew-<tapname>` (e.g., `homebrew-jcd`)
2. Create a `Formula/` directory
3. Copy the generated formula:
   ```bash
   cp target/release/brew/jcd.rb /path/to/homebrew-jcd/Formula/
   ```
4. Commit and push

Users can then install with:
```bash
brew tap username/tapname
brew install jcd
```

#### Option B: Official Homebrew Core

Submit a pull request to [homebrew-core](https://github.com/Homebrew/homebrew-core) following their guidelines.

### 5. Test the Formula

Test the formula locally:

```bash
brew install --build-from-source target/release/brew/jcd.rb
```

Or test from the tap:
```bash
brew tap username/tapname
brew install jcd
```

## Formula Features

The generated Homebrew formula includes:

- **Proper metadata**: Description, homepage, license
- **Dependencies**: Bash for the shell function
- **Installation**: Installs both binary and shell function
- **Setup helper**: `jcd-setup` command for easy configuration
- **User guidance**: Detailed caveats about shell integration
- **Test suite**: Validates installation and basic functionality

## Post-Installation

After installation via Homebrew, users need to add shell integration:

```bash
# Add to ~/.bashrc or ~/.zshrc
export JCD_BINARY="$(brew --prefix)/bin/jcd"
source $(brew --prefix)/bin/jcd_function.sh
```

Or run `jcd-setup` for instructions.

## Troubleshooting

### SHA256 Mismatch
If you get SHA256 mismatch errors, regenerate the formula after uploading the correct ZIP file to GitHub.

### Shell Function Not Working
Ensure users have sourced the shell function and set the JCD_BINARY environment variable correctly.

### Binary Not Found
Check that the binary is executable and in the expected location after Homebrew installation.

## Architecture Support

The current implementation supports:
- x86_64 (Intel Macs)
- arm64 (Apple Silicon Macs)

The architecture is automatically detected during the build process.