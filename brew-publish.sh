#!/bin/bash

#
# brew-publish.sh
#
# Script to help publish jcd to Homebrew
#
# Usage: ./brew-publish.sh <version> [release-url]
#

set -e

if [ "$1" = "" ]; then
    echo "Usage: $0 <version> [release-url]"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0"
    echo "  $0 1.0.0 https://github.com/microsoft/jcd/releases/download/v1.0.0/jcd-mac-1.0.0.zip"
    echo ""
    echo "If release-url is not provided, the script will assume the standard GitHub release format."
    exit 1
fi

VERSION=$1
RELEASE_URL=$2

# Determine architecture
if [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then
    ARCH="arm64"
else
    ARCH="x86_64"
fi

echo "Building jcd v${VERSION} for Homebrew (${ARCH})..."

# Build the project
echo "Building project..."
cargo build --release

# Generate the package
echo "Generating Homebrew package..."
./makePackages.sh . target/release jcd "${VERSION}" 0 brew "${ARCH}"

BREW_DIR="target/release/brew"
ZIP_FILE="${BREW_DIR}/jcd-mac-${VERSION}.zip"
FORMULA_FILE="${BREW_DIR}/jcd.rb"

if [ ! -f "${ZIP_FILE}" ]; then
    echo "Error: Package file not found: ${ZIP_FILE}"
    exit 1
fi

if [ ! -f "${FORMULA_FILE}" ]; then
    echo "Error: Formula file not found: ${FORMULA_FILE}"
    exit 1
fi

# Extract SHA256
SHA256=$(grep 'sha256' "${FORMULA_FILE}" | cut -d'"' -f2)

echo ""
echo "============================================"
echo "Homebrew package generated successfully!"
echo "============================================"
echo "Package file: ${ZIP_FILE}"
echo "Formula file: ${FORMULA_FILE}"
echo "SHA256: ${SHA256}"
echo ""

if [ "$RELEASE_URL" != "" ]; then
    echo "Updating formula with custom release URL..."
    sed -i.bak "s|https://github.com/microsoft/jcd/releases/download/v${VERSION}/jcd-mac-${VERSION}.zip|${RELEASE_URL}|g" "${FORMULA_FILE}"
    rm "${FORMULA_FILE}.bak"
    echo "Formula updated with URL: ${RELEASE_URL}"
    echo ""
fi

echo "Next steps for Homebrew publishing:"
echo ""
echo "1. Upload the ZIP file to your GitHub release:"
echo "   ${ZIP_FILE}"
echo ""
echo "2. Create or update a Homebrew tap repository with the formula:"
echo "   ${FORMULA_FILE}"
echo ""
echo "3. For a personal tap, create a repository named homebrew-<tapname>"
echo "   Example: homebrew-jcd"
echo ""
echo "4. Add the formula to the Formula/ directory in your tap:"
echo "   cp ${FORMULA_FILE} /path/to/homebrew-jcd/Formula/"
echo ""
echo "5. Users can then install with:"
echo "   brew tap <username>/<tapname>"
echo "   brew install jcd"
echo ""
echo "6. For the official Homebrew repository, submit a PR to:"
echo "   https://github.com/Homebrew/homebrew-core"
echo ""

# Show formula content
echo "Generated formula content:"
echo "=========================="
cat "${FORMULA_FILE}"