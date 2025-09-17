#!/bin/sh
#
#    jcd
#
#    Copyright (c) Microsoft Corporation
#
#    All rights reserved.
#
#    MIT License
#
#    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
#    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#################################################################################
#
# makePackages.sh
#
# Builds the directory trees for DEB and RPM packages and, if suitable tools are
# available, builds the actual packages too.
#
#################################################################################

if [ "$5" = "" ]; then
    echo "Usage: $0 <SourceDir> <BinaryDir> <package name> <package version> <package release> <PackageType> <architecture>"
    exit 1
fi

# copy cmake vars
CMAKE_SOURCE_DIR=$1
PROJECT_BINARY_DIR=$2
PACKAGE_NAME=$3
PACKAGE_VER=$4
PACKAGE_REL=$5
PACKAGE_TYPE=$6
ARCHITECTURE=$7

DEB_PACKAGE_NAME="${PACKAGE_NAME}_${PACKAGE_VER}_${ARCHITECTURE}"
RPM_PACKAGE_NAME="${PACKAGE_NAME}-${PACKAGE_VER}-${PACKAGE_REL}"
BREW_PACKAGE_NAME="${PACKAGE_NAME}-mac-${PACKAGE_VER}"

if [ "$PACKAGE_TYPE" = "deb" ]; then
    DPKGDEB=`which dpkg-deb`

    if [ -d "${PROJECT_BINARY_DIR}/deb" ]; then
        rm -rf "${PROJECT_BINARY_DIR}/deb"
    fi

    # copy deb files
    mkdir -p "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}"
    sed -e "s/@PROJECT_VERSION_MAJOR@.@PROJECT_VERSION_MINOR@.@PROJECT_VERSION_PATCH@/$PACKAGE_VER/" -e "s/@ARCHITECTURE@/$ARCHITECTURE/" "${CMAKE_SOURCE_DIR}/dist/DEBIAN.in/control.in" > "${PROJECT_BINARY_DIR}/DEBIANcontrol"
    mkdir -p "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/DEBIAN"
    cp "${PROJECT_BINARY_DIR}/DEBIANcontrol" "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/DEBIAN/control"

    # include post-install script if present
    if [ -f "${CMAKE_SOURCE_DIR}/dist/DEBIAN.in/postinst.in" ]; then
        cp "${CMAKE_SOURCE_DIR}/dist/DEBIAN.in/postinst.in" "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/DEBIAN/postinst"
        chmod 755 "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/DEBIAN/postinst"
    fi

    mkdir -p "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/usr/bin"
    cp "${PROJECT_BINARY_DIR}/jcd" "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/usr/bin/"
    cp "${PROJECT_BINARY_DIR}/jcd_function.sh" "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/usr/bin/"
    chmod 755 "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/usr/bin/jcd"
    chmod 755 "${PROJECT_BINARY_DIR}/deb/${DEB_PACKAGE_NAME}/usr/bin/jcd_function.sh"

    # make the deb
    if [ "$DPKGDEB" != "" ]; then
        cd "${PROJECT_BINARY_DIR}/deb"
        "$DPKGDEB" -Zxz --build --root-owner-group "${DEB_PACKAGE_NAME}"
        RET=$?
    else
        echo "No dpkg-deb found"
        RET=1
    fi

    exit 0
fi

if [ "$PACKAGE_TYPE" = "rpm" ]; then
    RPMBUILD=`which rpmbuild`

    if [ -d "${PROJECT_BINARY_DIR}/rpm" ]; then
        rm -rf "${PROJECT_BINARY_DIR}/rpm"
    fi

    # copy rpm files
    mkdir -p "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}/SPECS"
    sed -e "s/@PROJECT_VERSION_MAJOR@.@PROJECT_VERSION_MINOR@.@PROJECT_VERSION_PATCH@/$PACKAGE_VER/" -e "s/@PROJECT_VERSION_TWEAK@/0/" "${CMAKE_SOURCE_DIR}/dist/SPECS.in/spec.in" > "${PROJECT_BINARY_DIR}/SPECS.spec"
    cp -a "${PROJECT_BINARY_DIR}/SPECS.spec" "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}/SPECS/${RPM_PACKAGE_NAME}.spec"
    mkdir "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}/BUILD/"
    echo "HELLO"${CMAKE_SOURCE_DIR}
    cp "${CMAKE_SOURCE_DIR}/${PROJECT_BINARY_DIR}/jcd" "${CMAKE_SOURCE_DIR}/${PROJECT_BINARY_DIR}/jcd_function.sh" "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}/BUILD/"
    chmod 755 "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}/BUILD/jcd"
    chmod 755 "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}/BUILD/jcd_function.sh"

    # make the rpm
    if [ "$RPMBUILD" != "" ]; then
        cd "${PROJECT_BINARY_DIR}/rpm/${RPM_PACKAGE_NAME}"
        "$RPMBUILD" --define "_topdir `pwd`" -v -bb "SPECS/${RPM_PACKAGE_NAME}.spec"
        RET=$?
        cp RPMS/$(uname -m)/*.rpm ..
    else
        echo "No rpmbuild found"
        RET=1
    fi
fi

if [ "$PACKAGE_TYPE" = "brew" ]; then
    
    if [ -d "${PROJECT_BINARY_DIR}/brew" ]; then
        rm -rf "${PROJECT_BINARY_DIR}/brew"
    fi
    
    # Create brew package directory
    mkdir -p "${PROJECT_BINARY_DIR}/brew"
    
    # Create staging directory for the package
    BREW_STAGING_DIR="${PROJECT_BINARY_DIR}/brew/staging"
    mkdir -p "${BREW_STAGING_DIR}"
    
    # Copy files to staging
    cp "${PROJECT_BINARY_DIR}/jcd" "${BREW_STAGING_DIR}/"
    cp "${PROJECT_BINARY_DIR}/jcd_function.sh" "${BREW_STAGING_DIR}/"
    chmod 755 "${BREW_STAGING_DIR}/jcd"
    chmod 755 "${BREW_STAGING_DIR}/jcd_function.sh"
    
    # Create the zip file
    cd "${BREW_STAGING_DIR}"
    zip "../${BREW_PACKAGE_NAME}.zip" jcd jcd_function.sh
    cd - > /dev/null
    
    # Generate SHA256 checksum
    BREW_ZIP_PATH="${PROJECT_BINARY_DIR}/brew/${BREW_PACKAGE_NAME}.zip"
    if command -v sha256sum >/dev/null 2>&1; then
        SHA256=$(sha256sum "${BREW_ZIP_PATH}" | cut -d' ' -f1)
    elif command -v shasum >/dev/null 2>&1; then
        SHA256=$(shasum -a 256 "${BREW_ZIP_PATH}" | cut -d' ' -f1)
    else
        echo "Warning: No SHA256 utility found, using placeholder"
        SHA256="<SHA256_PLACEHOLDER>"
    fi
    
    # Generate Homebrew formula
    if [ -f "${CMAKE_SOURCE_DIR}/dist/homebrew/jcd.rb.in" ]; then
        # Use placeholder URL for now - this would be replaced with actual release URL
        DOWNLOAD_URL="https://github.com/microsoft/jcd/releases/download/v${PACKAGE_VER}/${BREW_PACKAGE_NAME}.zip"
        
        sed -e "s|@DOWNLOAD_URL@|${DOWNLOAD_URL}|g" \
            -e "s|@SHA256@|${SHA256}|g" \
            -e "s|@VERSION@|${PACKAGE_VER}|g" \
            "${CMAKE_SOURCE_DIR}/dist/homebrew/jcd.rb.in" > "${PROJECT_BINARY_DIR}/brew/jcd.rb"
            
        echo "Generated Homebrew formula: ${PROJECT_BINARY_DIR}/brew/jcd.rb"
        echo "ZIP file: ${BREW_ZIP_PATH}"
        echo "SHA256: ${SHA256}"
    else
        echo "Warning: Homebrew formula template not found at ${CMAKE_SOURCE_DIR}/dist/homebrew/jcd.rb.in"
    fi
    
    # Copy the zip to the main directory for compatibility
    cp "${BREW_ZIP_PATH}" "${PROJECT_BINARY_DIR}/${BREW_PACKAGE_NAME}.zip"
fi
exit $RET