#!/bin/bash
##################################################
# Unofficial LineageOS Perf kernel Compile Script
# Based on the original compile script by vbajs
# Forked by Riaru Moda
##################################################

# Help message
help_message() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --ksu          Enable KernelSU support"
  echo "  --no-ksu       Disable KernelSU support"
  echo "  --ln8000       Enable ln8k charging support"
  echo "  --no-ln8000    Disable ln8k charging support"
  echo "  --help         Show this help message"
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
      wget -nv --content-disposition -L "$url"
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
  echo "CONFIG_EROFS_FS=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
  echo "CONFIG_F2FS_FS_COMPRESSION=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
  echo "CONFIG_F2FS_FS_LZ4=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
}

add_ln8k() {
  local arg="$1"
  if [[ "$arg" == "--ln8000" ]]; then
    echo "Adding ln8k patches..."
    wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/05d8eac3722dcf920b716908d910ee704a77950e.patch" -O ln8k1.patch
    wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/eb3509401751b1e90a9b42e2f51326f2ef943af3.patch" -O ln8k2.patch
    wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/785c8f7976798acfc5cf300a320a43b3f39bcb13.patch" -O ln8k3.patch
    wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/e26ba40f3fac0238e410f8a29fa72aac012d75d2.patch" -O ln8k4.patch
    wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/6e50130d7bc99d1cc64196541af7a1780a703253.patch" -O ln8k5.patch
    patch -p1 < ln8k1.patch
    patch -p1 < ln8k2.patch
    patch -p1 < ln8k3.patch
    patch -p1 < ln8k4.patch
    patch -p1 < ln8k5.patch
    echo "CONFIG_CHARGER_LN8000=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
    sed -i 's|#define LN8000_IIN_CFG_DEFAULT          2000000     /* 2A=2,000,000uA, input current limit */|#define LN8000_IIN_CFG_DEFAULT          3000000     /* 3A=3,000,000uA, input current limit */|' drivers/power/supply/ti/ln8000_charger.h
    sed -i 's|		ln8000_charger,tdie-prot-disable;|		// ln8000_charger,tdie-prot-disable;|' arch/arm64/boot/dts/qcom/xiaomi/sweet/sweet-sdmmagpie.dtsi
    sed -i 's|		ln8000_charger,iin-ocp-disable;|		// ln8000_charger,iin-ocp-disable;|' arch/arm64/boot/dts/qcom/xiaomi/sweet/sweet-sdmmagpie.dtsi
    sed -i 's|		ln8000_charger,tbat-mon-disable;|		// ln8000_charger,tbat-mon-disable;|' arch/arm64/boot/dts/qcom/xiaomi/sweet/sweet-sdmmagpie.dtsi
    sed -i 's|		ln8000_charger,bus-ocp-threshold = <3750>;|		ln8000_charger,bus-ocp-threshold = <4500>;|' arch/arm64/boot/dts/qcom/xiaomi/sweet/sweet-sdmmagpie.dtsi
    sed -i 's|		ln8000_charger,bus-ocp-alarm-threshold = <3500>;|		ln8000_charger,bus-ocp-alarm-threshold = <4250>;|' arch/arm64/boot/dts/qcom/xiaomi/sweet/sweet-sdmmagpie.dtsi
  elif [[ "$arg" == "--no-ln8000" ]]; then
    echo "ln8k setup skipped."
  fi
}

add_dtbo() {
  echo "Adding dtbo compile support..."
  wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/e517bc363a19951ead919025a560f843c2c03ad3.patch" -O dtbo1.patch
  wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/a62a3b05d0f29aab9c4bf8d15fe786a8c8a32c98.patch" -O dtbo2.patch
  wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/4b89948ec7d610f997dd1dab813897f11f403a06.patch" -O dtbo3.patch
  wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/fade7df36b01f2b170c78c63eb8fe0d11c613c4a.patch" -O dtbo4.patch
  wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/2628183db0d96be8dae38a21f2b09cb10978f423.patch" -O dtbo5.patch
  wget -L "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/31f4577af3f8255ae503a5b30d8f68906edde85f.patch" -O dtbo6.patch
  patch -p1 < dtbo1.patch
  patch -p1 < dtbo2.patch
  patch -p1 < dtbo3.patch
  patch -p1 < dtbo4.patch
  patch -p1 < dtbo5.patch
  patch -p1 < dtbo6.patch
}

# KSU Setup
setup_ksu() {
  local arg="$1"
  if [[ "$arg" == "--ksu" ]]; then
    echo "Setting up KernelSU..."
    echo "CONFIG_KSU=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
    echo "CONFIG_KSU_LSM_SECURITY_HOOKS=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
    echo "CONFIG_KSU_MANUAL_HOOKS=y" >> arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
    wget -L "https://github.com/ximi-mojito-test/mojito_krenol/commit/36105f0599f679bc76e2866de397d50a83339849.patch" -O ksu.patch
    patch -p1 < ksu.patch
    patch -p1 < ksumakefile.patch
    patch -p1 < umount.patch
    git clone "$KSU_SETUP_URI" -b "$KSU_BRANCH" KernelSU
    cd drivers
    ln -sfv ../KernelSU/kernel kernelsu
    cd ..
  elif [[ "$arg" == "--no-ksu" ]]; then
    echo "KernelSU setup skipped."
  fi
}

# Compile kernel
compile_kernel() {
  echo -e "\nStarting compilation..."
  sed -i 's/CONFIG_LOCALVERSION="-perf"/CONFIG_LOCALVERSION="-perf-neon"/' arch/arm64/configs/vendor/sdmsteppe-perf_defconfig
  ulimit -s unlimited
  make O=out ARCH=arm64 vendor/sdmsteppe-perf_defconfig
  make O=out ARCH=arm64 vendor/sweet.config
  make -j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    LD=ld.lld \
    AR=llvm-ar \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CC=clang \
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
  add_dtbo
  add_ln8k "$2"
  setup_ksu "$1"
  compile_kernel
}

# Run the main function
main "$1" "$2"
