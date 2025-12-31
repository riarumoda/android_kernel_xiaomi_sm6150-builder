#!/bin/bash
###############################################
# Unofficial LineageOS Perf kernel Compile Script
# Based on the original compile script by vbajs
# Forked by Riaru Moda
###############################################

# Help message
help_message() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --ksu     Enable KernelSU support"
  echo "  --help    Show this help message"
}

# Environment setup
setup_environment() {
  echo "Setting up build environment..."
  export ARCH=arm64
  export KBUILD_BUILD_USER=riaru
  export KBUILD_BUILD_HOST=ximiedits
  export GCC64_DIR=$PWD/gcc64
  export GCC32_DIR=$PWD/gcc32
  export KSU_SETUP_URI="https://github.com/KernelSU-Next/KernelSU-Next"
  export KSU_BRANCH="legacy"
}

# Toolchain setup
setup_toolchain() {
  echo "Setting up toolchains..."

  if [ ! -d "$PWD/clang" ]; then
    echo "Cloning Clang..."
    git clone https://gitlab.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r547379.git --depth=1 -b 15.0 clang
  else
    echo "Local clang dir found, using it."
  fi

  if [ ! -d "$PWD/gcc32" ] && [ ! -d "$PWD/gcc64" ]; then
    echo "Downloading GCC..."
    ASSET_URLS=$(curl -s "https://api.github.com/repos/mvaisakh/gcc-build/releases/latest" | grep "browser_download_url" | cut -d '"' -f 4 | grep -E "eva-gcc-arm.*\.xz")
    for url in $ASSET_URLS; do
      wget --content-disposition -L "$url"
    done

    for file in eva-gcc-arm*.xz; do
      # The files are actually just plain tarballs named as .xz
      if [[ "$file" == *arm64* ]]; then
        tar -xf "$file" && mv gcc-arm64 gcc64
      else
        tar -xf "$file" && mv gcc-arm gcc32
      fi
      rm -rf "$file"
    done
  else
    echo "Local gcc dirs found, using them."
  fi
}

# Update PATH
update_path() {
  echo "Updating PATH..."
  export PATH="$PWD/clang/bin/:$GCC64_DIR/bin/:$GCC32_DIR/bin/:/usr/bin:$PATH"
}

# General Patches
add_patches() {
  echo "Adding patches..."
  wget -L https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder/-/raw/main/patches/4.14/add-rtl88xxau-5.6.4.2-drivers.patch -O rtl88xxau.patch
  patch -p1 < rtl88xxau.patch
  wget -L https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder/-/raw/main/patches/4.14/add-wifi-injection-4.14.patch -O wifi-injection.patch
  patch -p1 < wifi-injection.patch
  sed -i 's/# CONFIG_PID_NS is not set/CONFIG_PID_NS=y/' arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
  echo "CONFIG_POSIX_MQUEUE=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
  echo "CONFIG_SYSVIPC=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
  echo "CONFIG_CGROUP_DEVICE=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
  echo "CONFIG_DEVTMPFS=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
  echo "CONFIG_IPC_NS=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
  echo "CONFIG_DEVTMPFS_MOUNT=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
}

# KSU Setup
setup_ksu() {
  local arg="$1"
  if [[ "$arg" == "--ksu" ]]; then
    echo "Setting up KernelSU..."
    echo "CONFIG_KSU=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
    echo "CONFIG_KSU_LSM_SECURITY_HOOKS=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
    echo "CONFIG_KSU_MANUAL_HOOKS=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
    patch -p1 < ksu.patch
    patch -p1 < umount.patch
    git clone "$KSU_SETUP_URI" -b "$KSU_BRANCH" KernelSU
    cd drivers
    ln -sf ../KernelSU/kernel kernelsu
    cd ..
  else
    echo "KernelSU setup skipped."
  fi
}

# Compile kernel
compile_kernel() {
  echo -e "\nStarting compilation..."
  sed -i 's/CONFIG_LOCALVERSION="-perf"/CONFIG_LOCALVERSION="-perf-neon"/' arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
  make O=out ARCH=arm64 vendor/sdmsteppe-perf_defconfig
  make O=out ARCH=arm64 vendor/sweet.config
  make -j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    CROSS_COMPILE=$GCC64_DIR/bin/aarch64-elf- \
    CROSS_COMPILE_COMPAT=$GCC32_DIR/bin/arm-eabi-
}

# Main function
main() {
  case "$1" in
    --help)
      help_message
      exit 0
      ;;
  esac
  setup_environment
  setup_toolchain
  update_path
  add_patches
  setup_ksu "$1"
  compile_kernel
}

# Run the main function
main "$1"
