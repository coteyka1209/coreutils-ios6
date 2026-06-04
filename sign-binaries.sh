#!/bin/bash

if [ ! -f "linux64/ldid" ]; then
    echo "====> ldid not found. Downloading v42..."
    wget -q https://github.com/xerub/ldid/releases/download/42/ldid.zip
    unzip -q -o ldid.zip
    rm ldid.zip
fi

chmod +x linux64/ldid

if ! command -v file &> /dev/null; then
    echo "====> 'file' command not found. Installing..."
    sudo apt update && sudo apt install file -y
fi

echo "====> Starting pseudo-signing of iOS Mach-O binaries in src/..."

count=0

for binary in src/*; do
    if [ -f "$binary" ] && [ -x "$binary" ] && [[ ! "$binary" == *.* ]]; then
        if file "$binary" | grep -q "Mach-O"; then
            echo "Signing: $binary"
            ./linux64/ldid -S "$binary"
            if [ $? -eq 0 ]; then
                ((count++))
            fi
        else
            echo "Skipping host/non-Mach-O binary: $binary"
        fi
    fi
done

echo "====> Done! Successfully signed $count iOS binaries."
