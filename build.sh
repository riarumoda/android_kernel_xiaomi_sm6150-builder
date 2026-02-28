#!/bin/bash
##################################################
# MuhanadAbdulrahman CR (SM6150) Compile Script
# Based on the original compile script by vbajs/Riaru
##################################################

setup_environment() {
    echo "Setting up build environment..."
    # Imports
    local MAIN_DEFCONFIG_IMPORT="$1"
    local SUBS_DEFCONFIG_IMPORT="$2"
    local KERNELSU_SELECTOR="$3"
    local LN8K_SELECTOR="$4"

    # Maintainer info - Updated for your fork
    export KBUILD_BUILD_USER="Muhanad"
    export KBUILD_BUILD_HOST="CR-Project"
    export GIT_NAME="MuhanadAbdulrahman"
    export GIT_EMAIL="muhanad@github.com"

    # Toolchain Settings - Using Proton Clang (Recommended for SM6150/CR)
    export CLANG_REPO_URI="https://github.com/kdrag0n/proton-clang.git"
    
    # GCC is usually required for some legacy parts of SM6150 kernels
    export GCC_64_REPO_URI="https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git"
    export GCC_32_REPO_URI="https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9.git"
    
    export CLANG_DIR=$PWD/clang
    export GCC64_DIR=$PWD/gcc64
    export GCC32_DIR=$PWD/gcc32
    
    # Corrected Pathing
    export PATH="$CLANG_DIR/bin:$GCC64_DIR/bin:$GCC32_DIR/bin:/usr/bin:$PATH"

    # Defconfig Settings
    export MAIN_DEFCONFIG="arch/arm64/configs/vendor/$MAIN_DEFCONFIG_IMPORT"
    export SUBS_DEFCONFIG="arch/arm64/configs/vendor/$SUBS_DEFCONFIG_IMPORT"
    export COMPILE_MAIN_DEFCONFIG="vendor/$MAIN_DEFCONFIG_IMPORT"
    export COMPILE_SUBS_DEFCONFIG="vendor/$SUBS_DEFCONFIG_IMPORT"

    # KernelSU & SUSFS Settings
    if [[ "$KERNELSU_SELECTOR" == "--ksu=KSU_BLXX" ]]; then
        export KSU_SETUP_URI="https://github.com/backslashxx/KernelSU/raw/refs/heads/master/kernel/setup.sh"
        export KSU_BRANCH="master"
    elif [[ "$KERNELSU_SELECTOR" == "--ksu=KSU_NEXT" ]]; then
        export KSU_SETUP_URI="https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh"
        export KSU_BRANCH="legacy"
    fi

    # Patches remain as per your source requirements
    export DTBO_PATCH1="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/e517bc363a19951ead919025a560f843c2c03ad3.patch"
    # ... (rest of your patch exports remain the same)
}

setup_toolchain() {
    echo "Setting up toolchain..."
    # Clone Clang if not present
    [ ! -d "$CLANG_DIR" ] && git clone $CLANG_REPO_URI --depth=1 clang &> /dev/null
    [ ! -d "$GCC64_DIR" ] && git clone $GCC_64_REPO_URI --depth=1 gcc64 &> /dev/null
    [ ! -d "$GCC32_DIR" ] && git clone $GCC_32_REPO_URI --depth=1 gcc32 &> /dev/null
}

add_patches() {
    echo "Applying hardware and optimization patches..."
    # Applying DTBO patches
    for patch_url in $DTBO_PATCH1 $DTBO_PATCH2 $DTBO_PATCH3 $DTBO_PATCH4 $DTBO_PATCH5 $DTBO_PATCH6; do
        wget -qO- $patch_url | patch -s -p1 || echo "Patch failed: $patch_url"
    done

    # Optimization: Forced O3
    echo "Applying O3 optimizations..."
    sed -i 's/-O2/-O3/g' Makefile
    
    # Append CR specific configs
    {
        echo "CONFIG_SIMPLE_GPU_ALGORITHM=y"
        echo "CONFIG_EROFS_FS=y"
        echo "CONFIG_SECURITY_SELINUX_DEVELOP=y"
    } >> $MAIN_DEFCONFIG
}

compile_kernel() {
    echo "Starting kernel compilation for SM6150..."
    
    # Build Output directory
    mkdir -p out
    
    # Make defconfig
    make -s O=out ARCH=arm64 $COMPILE_MAIN_DEFCONFIG $COMPILE_SUBS_DEFCONFIG

    # Compilation using Clang + LLD
    make -j$(nproc --all) \
        O=out \
        ARCH=arm64 \
        CC=clang \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE=aarch64-linux-android- \
        CROSS_COMPILE_ARM32=arm-linux-androideabi- \
        LD=ld.lld \
        AR=llvm-ar \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip
        
    if [ -f "out/arch/arm64/boot/Image.gz-dtb" ]; then
        echo "Build Successful!"
    else
        echo "Build Failed!"
        exit 1
    fi
}

main() {
    if [ $# -lt 3 ]; then
        echo "Usage: $0 <MAIN_CONFIG> <SUBS_CONFIG> <KSU_TYPE> <LN8K_BOOL>"
        exit 1
    fi
    setup_environment "$1" "$2" "$3" "$4"
    setup_toolchain
    add_patches
    # add_ln8k (called if needed)
    # add_ksu (called if needed)
    compile_kernel
}

main "$1" "$2" "$3" "$4"
