# GNU Coreutils for iOS 6

This repository contains an automated build script and instructions to cross-compile a modern version of GNU Coreutils from a Linux host (Debian/Ubuntu) targeting jailbroken iOS 6.0+ devices (ARMv7, e.g., iPhone 4s, iPad 2/3, iPod Touch 5).

To ensure system stability and avoid conflicts with iOS built-in commands, the binaries are configured to install into an isolated directory (`/opt/coreutils`).

# Installing from a .deb file (Recommended)
If you just want to use modern GNU Coreutils on your iOS 6 device without building them from source:
1. Go to the [Releases](https://github.com/YOUR_USERNAME/YOUR_REPO_NAME/releases) page.
2. Download the latest `coreutils-ios6_9.11-1_iphoneos-arm.deb`.
3. Transfer it to your device and install via iFile/Filza, or via SSH using `dpkg -i`.


---
# Building from sources

## 1. Prerequisites & Toolchain Setup

Before building, you need to set up the Theos toolchain and the legacy iOS 6.1 SDK on your Linux host.

### Step 0: Getting all the packages needed
Install all the packages you need. Here's a way to do it on a Debian/Ubuntu system:
```bash
sudo apt update
sudo apt install wget git unzip build-essential xz-utils libtinfo5 file -y
```
### Step 1: Install Theos
Clone the Theos framework into your home directory:
```bash
git clone --recursive https://github.com/theos/theos.git ~/theos
```
### Step 2: Install Linux-to-iOS Toolchain
Download and install the iOS toolchain for Linux. You can use the precompiled toolchain provided by the Theos team or community maintainers:
```bash
# Clean up any default toolchains
rm -rf ~/theos/toolchain

wget https://github.com/sbingner/llvm-project/releases/download/v10.0.0-1/linux-ios-arm64e-clang-toolchain.tar.lzma


mkdir -p /tmp/tc-extract
tar -xf linux-ios-arm64e-clang-toolchain.tar.lzma -C /tmp/tc-extract


mkdir -p ~/theos/toolchain/linux/iphone
cp -r /tmp/tc-extract/ios-arm64e-clang-toolchain/* ~/theos/toolchain/linux/iphone/
ln -s ~/theos/toolchain/linux/iphone/host ~/theos/toolchain/linux/host

rm -rf /tmp/tc-extract linux-ios-arm64e-clang-toolchain.tar.lzma
```

### Step 3: Add iOS 6.1 SDK
You'll need iOS 6.1 SDK for building. Download it and place it into your Theos SDK folder (`~/theos/sdks/iPhoneOS6.1.sdk/`)
```bash
wget https://github.com/growtopiajaw/iPhoneOS-SDK/releases/download/v1.0/iPhoneOS6.1.sdk.zip
unzip iPhoneOS6.1.sdk.zip
mkdir -p ~/theos/sdks/
mv iPhoneOS6.1.sdk ~/theos/sdks/
rm iPhoneOS6.1.sdk.zip
```

## 2. Building the coreutils

### Step 4: Clone the coreutils repository
Check the latest coreutils version on https://ftp.gnu.org/gnu/coreutils/, and download it (this example uses coreutils v9.11, use the most recent version)

```bash
wget https://ftp.gnu.org/gnu/coreutils/coreutils-9.11.tar.xz
tar -xf coreutils-9.11.tar.xz
cd coreutils-9.11
```

### Step 5: Add the `configure-for-ios6` script to coreutils folder
Copy the configure-for-ios6 script from this repository into the root directory of the unpacked Coreutils source code.

### Step 6: Configure and build
```bash
chmod +x configure-for-ios6

./configure-for-ios6
make -j$(nproc)
```

### Step 7: Sign the compiled binaries
iOS requires all binaries to be signed, otherwise they will be instantly terminated by the kernel (`Command received SIGKILL`). We use `ldid` to apply a pseudo-signature to all compiled utilities.

Run the automated signing script from the root of the coreutils directory:
```bash
chmod +x sign-binaries.sh
./sign-binaries.sh
```

## 3. Deploying & Installing on iOS
### Step 8: Check your stock coreutils version
Open MobileTerminal on your iOS device or SSH into it, then check the default version of `ls` (it is usually an old stock version or a basic BusyBox/Cydia implementation):
```bash
ls --version
```
### Step 9: Archive the signed binaries on Host
To transfer files efficiently, pack all the signed target binaries from the `src/` directory into a single tarball on your Linux host:
```bash
tar -czf coreutils-ios6.tar.gz -C src $(find src -maxdepth 1 -type f -executable ! -name "*.*" -exec basename {} \;)
```

### Step 10: Send the archive to your iPhone, extract and chmod +x your binaries
```bash
scp coreutils-ios6.tar.gz root@<IP_ADDRESS_OF_YOUR_IPHONE>:/usr/local/bin/
```
On your iPhone, run this to set up the binaries correctly. You can run this through SSH or MobileTerminal
```bash
cd /usr/local/bin
tar -xzf coreutils-ios6.tar.gz
rm coreutils-ios6.tar.gz
chmod +x *
```
---
## Additional info
Be aware, that I mostly wrote all this using Gemini, and not myself.

Tested on my iPhone 4s.