#!/bin/bash

STAGING_DIR="coreutils-deb-layout"

echo "======="
echo "Don't forget to change your version and maintaner name in the control file!"
echo "======="
read -n 1 -s -r -p "Press any key to continue..." 

echo "====> Preparing .deb package structure..."
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR/DEBIAN"
mkdir -p "$STAGING_DIR/usr/local/bin"

echo "====> Copying signed Mach-O binaries..."
count=0

for binary in src/*; do
    if [ -f "$binary" ] && [ -x "$binary" ] && [[ ! "$binary" == *.* ]]; then
        if file "$binary" | grep -q "Mach-O"; then
            cp "$binary" "$STAGING_DIR/usr/local/bin/"
            ((count++))
        fi
    fi
done

if [ "$count" -eq 0 ]; then
    echo "ERROR: No signed Mach-O binaries found in src/. Did you run sign-binaries.sh?"
    exit 1
fi

echo "====> Successfully copied $count binaries."

cat << 'EOF' > "$STAGING_DIR/DEBIAN/control"
Package: org.gnu.modern-coreutils
Name: Modern Coreutils
Version: 9.11-1
Architecture: iphoneos-arm
Description: Modern GNU Coreutils cross-compiled for legacy iOS 6.0+ devices. Safely installed into /usr/local/bin to prevent conflicts with stock utilities.
Maintainer: coteyka
Author: GNU
Section: Terminal
Priority: optional
EOF

echo "====> Building Debian package for iOS 6..."
dpkg-deb -Zgzip --build "$STAGING_DIR" coreutils-ios6_9.11-1_iphoneos-arm.deb

rm -rf "$STAGING_DIR"

echo "====> Done! Package created: coreutils-ios6_9.11-1_iphoneos-arm.deb"
