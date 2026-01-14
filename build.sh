#!/bin/bash
##################################################
# Unofficial LineageOS Perf kernel Compile Script
# Based on the original compile script by vbajs
# Forked by Riaru Moda
##################################################

setup_environment() {
    echo "Setting up build environment..."
    # Imports
    local MAIN_DEFCONFIG_IMPORT="$1"
    local SUBS_DEFCONFIG_IMPORT="$2"
    local KERNELSU_SEELCTOR="$3"
    local F2FS_SEELCTOR="$4"
    # Maintainer info
    export KBUILD_BUILD_USER=riaru
    export KBUILD_BUILD_HOST=ximiedits
    export GIT_NAME="riaru-compile"
    export GIT_EMAIL="riaru-compile@riaru.com"
    # GCC and Clang settings
    export CLANG_REPO_URI="https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b.git"
    export GCC_64_REPO_URI="https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git"
    export GCC_32_REPO_URI="https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9.git"
    export CLANG_DIR=$PWD/clang
    export GCC64_DIR=$PWD/gcc64
    export GCC32_DIR=$PWD/gcc32
    export PATH="$CLANG_DIR/bin/:$GCC64_DIR/bin/:$GCC32_DIR/bin/:/usr/bin:$PATH"
    # Defconfig Settings
    export MAIN_DEFCONFIG="arch/arm64/configs/vendor/$MAIN_DEFCONFIG_IMPORT"
    export SUBS_DEFCONFIG="arch/arm64/configs/vendor/$SUBS_DEFCONFIG_IMPORT"
    export COMPILE_MAIN_DEFCONFIG="vendor/$MAIN_DEFCONFIG_IMPORT"
    export COMPILE_SUBS_DEFCONFIG="vendor/$SUBS_DEFCONFIG_IMPORT"
    # KernelSU Settings
    if [[ "$KERNELSU_SEELCTOR" == "--ksu=KSU_NEXT" ]]; then
        export KSU_SETUP_URI="https://github.com/KernelSU-Next/KernelSU-Next"
        export KSU_BRANCH="legacy"
        export KSU_GENERAL_PATCH="https://github.com/ximi-mojito-test/mojito_krenol/commit/36105f0599f679bc76e2866de397d50a83339849.patch"
        export KSU_AVC_PATCH="https://github.com/ximi-mojito-test/mojito_krenol/commit/62205970b6a07a828c7587e675616f4f0835d82d.patch"
    elif [[ "$KERNELSU_SEELCTOR" == "--ksu=KSU_KOWX" ]]; then
        export KSU_SETUP_URI="https://github.com/KOWX712/KernelSU/"
        export KSU_BRANCH="master"
        export KSU_GENERAL_PATCH="https://github.com/ximi-mojito-test/mojito_krenol/commit/ebc23ea38f787745590c96035cb83cd11eb6b0e7.patch"
        export KSU_AVC_PATCH="https://github.com/ximi-mojito-test/mojito_krenol/commit/4d68fc7bde18bbf106db19481847c1044f22b0dd.patch"
    elif [[ "$KERNELSU_SEELCTOR" == "--ksu=KSU_BLXX" ]]; then
        export KSU_SETUP_URI="https://github.com/backslashxx/KernelSU"
        export KSU_BRANCH="master"
        export KSU_GENERAL_PATCH="https://github.com/ximi-mojito-test/mojito_krenol/commit/ebc23ea38f787745590c96035cb83cd11eb6b0e7.patch"
        export KSU_AVC_PATCH="https://github.com/ximi-mojito-test/mojito_krenol/commit/4d68fc7bde18bbf106db19481847c1044f22b0dd.patch"
    elif [[ "$KERNELSU_SEELCTOR" == "--ksu=NONE" ]]; then
        export KSU_SETUP_URI=""
        export KSU_BRANCH=""
        export KSU_GENERAL_PATCH=""
        export KSU_AVC_PATCH=""
    else
        echo "Invalid KernelSU selector. Use --ksu=KSU_NEXT, --ksu=KSU_KOWX, --ksu=KSU_BLXX, or --ksu=NONE."
        exit 1
    fi
    # DTBO Exports
    export DTBO_PATCH1="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/e517bc363a19951ead919025a560f843c2c03ad3.patch"
    export DTBO_PATCH2="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/a62a3b05d0f29aab9c4bf8d15fe786a8c8a32c98.patch"
    export DTBO_PATCH3="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/4b89948ec7d610f997dd1dab813897f11f403a06.patch"
    export DTBO_PATCH4="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/fade7df36b01f2b170c78c63eb8fe0d11c613c4a.patch"
    export DTBO_PATCH5="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/2628183db0d96be8dae38a21f2b09cb10978f423.patch"
    export DTBO_PATCH6="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/31f4577af3f8255ae503a5b30d8f68906edde85f.patch"
    # LN8K Exports
    export LN8K_PATCH1="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/e64a07f8d8beea4d7470e9ad4ef1b712d15909b5.patch"
    export LN8K_PATCH2="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/39af7bb35ee22c2e6accde8c413151eda6b985d8.patch"
    export LN8K_PATCH3="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/53133f4d9620f27d3d8fe3e021165cc93036cfb7.patch"
    export LN8K_PATCH4="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/b8a6b2aefce81a1f6f51b9a46113ace0624aebdd.patch"
    export LN8K_PATCH5="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/9d0cf7fd14477f290d7eeb8cb0107f29816935c0.patch"
    export LN8K_PATCH6="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/022c13d583a127e9cc5534c778ea6d250b4a0528.patch"
    export LN8K_PATCH7="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/2024605203354093ed2ec8294b7b0342baaf9c9d.patch"
    export LN8K_PATCH8="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/bc4d92b3b9a6fda3504ef887685ad271e8dfd08d.patch"
    export LN8K_PATCH9="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/39c4206ac149ebde881ca5e7be6f6f6a79f00ec6.patch"
    export LN8K_PATCH10="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/49afb7c867b8ce8e28faa9564a010a7a4daa1eab.patch"
    export LN8K_PATCH11="https://github.com/PixelOS-Devices-old/kernel_xiaomi_sm6150/commit/2b427aaf5af9748356d06f4048ef1f9b29ebf354.patch"
    # F2FS Exports
    if [[ "$F2FS_SEELCTOR" == "--f2fs=F2FS_TBYOOL" ]]; then
        export F2FS_PATCH="https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/02baeab5aaf5319e5d68f2319516efed262533ea.patch"
    elif [[ "$F2FS_SEELCTOR" == "--f2fs=NONE" ]]; then
        export F2FS_PATCH=""
    else
        echo "Invalid F2FS selector. Use --f2fs=F2FS_TBYOOL or --f2fs=NONE."
        exit 1
    fi
    # TheSillyOk's KSU_NEXT Exports
    export SILLY_KPATCH_NEXT_PATCH="https://github.com/TheSillyOk/kernel_ls_patches/raw/refs/heads/master/kpatch_fix.patch"
    export SILLY_SUSFS_GENERAL_PATCH="https://github.com/TheSillyOk/kernel_ls_patches/raw/refs/heads/master/susfs-2.0.0.patch"
    export SILLY_SUSFS_KSU_NEXT_PATCH="https://github.com/TheSillyOk/kernel_ls_patches/refs/heads/master/KSUN/KSUN-SUSFS-2.0.0.patch"
}

# Setup toolchain function
setup_toolchain() {
    echo "Setting up toolchain..."
    if [ ! -d "$PWD/clang" ]; then
        git clone $CLANG_REPO_URI --depth=1 clang &> /dev/null
    else
        echo "Local clang dir found, using it."
    fi
    if [ ! -d "$PWD/gcc64" ]; then
        git clone $GCC_64_REPO_URI --depth=1 gcc64 &> /dev/null
    else
        echo "Local gcc64 dir found, using it."
    fi
    if [ ! -d "$PWD/gcc32" ]; then
        git clone $GCC_32_REPO_URI --depth=1 gcc32 &> /dev/null
    else
        echo "Local gcc32 dir found, using it."
    fi
}

# Add patches function
add_patches() {
    echo "Applying patches..."
    # Apply DTBO patches
    wget -qO- $DTBO_PATCH1 | patch -s -p1
    wget -qO- $DTBO_PATCH2 | patch -s -p1
    wget -qO- $DTBO_PATCH3 | patch -s -p1
    wget -qO- $DTBO_PATCH4 | patch -s -p1
    wget -qO- $DTBO_PATCH5 | patch -s -p1
    wget -qO- $DTBO_PATCH6 | patch -s -p1
    # Apply LN8K patches
    wget -qO- $LN8K_PATCH1 | patch -s -p1
    wget -qO- $LN8K_PATCH2 | patch -s -p1
    wget -qO- $LN8K_PATCH3 | patch -s -p1
    wget -qO- $LN8K_PATCH4 | patch -s -p1
    wget -qO- $LN8K_PATCH5 | patch -s -p1
    wget -qO- $LN8K_PATCH6 | patch -s -p1
    wget -qO- $LN8K_PATCH7 | patch -s -p1
    wget -qO- $LN8K_PATCH8 | patch -s -p1
    wget -qO- $LN8K_PATCH9 | patch -s -p1
    wget -qO- $LN8K_PATCH10 | patch -s -p1
    wget -qO- $LN8K_PATCH11 | patch -s -p1
    echo "CONFIG_CHARGER_LN8000=y" >> $MAIN_DEFCONFIG
    # Apply general config patches
    sed -i 's/# CONFIG_PID_NS is not set/CONFIG_PID_NS=y/' $MAIN_DEFCONFIG
    sed -i 's/CONFIG_HZ_300=y/CONFIG_HZ_250=y/' $MAIN_DEFCONFIG
    echo "CONFIG_POSIX_MQUEUE=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_SYSVIPC=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_CGROUP_DEVICE=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_DEVTMPFS=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_IPC_NS=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_DEVTMPFS_MOUNT=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_EROFS_FS=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_FSCACHE=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_FSCACHE_STATS=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_FSCACHE_HISTOGRAM=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_SECURITY_SELINUX_DEVELOP=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_FS_ENCRYPTION=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_EXT4_ENCRYPTION=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_EXT4_FS_ENCRYPTION=y" >> $MAIN_DEFCONFIG
    # Apply kernel rename to defconfig
    sed -i 's/CONFIG_LOCALVERSION="-perf"/CONFIG_LOCALVERSION="-perf-neon"/' $MAIN_DEFCONFIG
    # Apply O3 flags into Kernel Makefile
    sed -i 's/KBUILD_CFLAGS\s\++= -O2/KBUILD_CFLAGS   += -O3/g' Makefile
    sed -i 's/LDFLAGS\s\++= -O2/LDFLAGS += -O3/g' Makefile
}

# Add F2FS patch function
add_f2fs() {
    if [ -n "$F2FS_PATCH" ]; then
        echo "Applying F2FS patch..."
        wget -qO- $F2FS_PATCH | patch -s -p1
        # Manual Config Enablement
        echo "CONFIG_F2FS_FS_COMPRESSION=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_F2FS_FS_LZ4=y" >> $MAIN_DEFCONFIG
    else
        echo "No F2FS patch to apply."
    fi
}

# Add KernelSU function
add_ksu() {
    if [ -n "$KSU_SETUP_URI" ]; then
        echo "Setting up KernelSU..."
        git clone $KSU_SETUP_URI --branch $KSU_BRANCH KernelSU &> /dev/null
        wget -qO- $KSU_GENERAL_PATCH | patch -s -p1
        wget -qO- $KSU_AVC_PATCH | patch -s -p1
        # Manual Symlink Creation
        cd drivers
        ln -sfv ../KernelSU/kernel kernelsu
        cd ..
        # Manual Makefile and Kconfig Editing
        sed -i '$a \\nobj-$(CONFIG_KSU) += kernelsu/' drivers/Makefile
        sed -i '/endmenu/i source "drivers/kernelsu/Kconfig"\n' drivers/Kconfig
        # Manual Config Enablement
        echo "CONFIG_KSU=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_LSM_SECURITY_HOOKS=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_MANUAL_HOOKS=y" >> $MAIN_DEFCONFIG
        # KernelSU Next Specific: SUSFS & KPatch Next support
        if [[ "$KSU_SETUP_URI" == *"KernelSU-Next"* ]]; then
            wget -qO- $SILLY_SUSFS_GENERAL_PATCH | patch -s -p1
            wget -qO- $SILLY_SUSFS_KSU_NEXT_PATCH | patch -s -p1
            wget -qO- $SILLY_KPATCH_NEXT_PATCH | patch -s -p1
            # Manual Config Enablement
            echo "CONFIG_KSU_SUSFS=y" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_SUS_PATH=n" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=n" >> $MAIN_DEFCONFIG
        fi
    else
        echo "No KernelSU to set up."
    fi
}

# Compile kernel function
compile_kernel() {
    # Do a git cleanup before compiling
    echo "Cleaning up git before compiling..."
    git config user.email $GIT_EMAIL
    git config user.name $GIT_NAME
    git config set advice.addEmbeddedRepo true
    git add .
    git commit -m "cleanup: applied patches before build"
    # Start compilation
    echo "Starting kernel compilation..."
    make -s O=out ARCH=arm64 $COMPILE_MAIN_DEFCONFIG $COMPILE_SUBS_DEFCONFIG
    make -j$(nproc --all) \
        O=out \
        ARCH=arm64 \
        CC=clang \
        LD=ld.lld \
        AR=llvm-ar \
        AS=llvm-as \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        CROSS_COMPILE=aarch64-linux-android- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
        CLANG_TRIPLE=aarch64-linux-gnu-
}

# Main function
main() {
    # Check if all four arguments are valid
    echo "Validating input arguments..."
    if [ $# -ne 4 ]; then
        echo "Usage: $0 <MAIN_DEFCONFIG_IMPORT> <SUBS_DEFCONFIG_IMPORT> <KERNELSU_SELECTOR> <F2FS_SELECTOR>"
        echo "Example: $0 sdmsteppe-perf_defconfig sweet.config --ksu=KSU_NEXT --f2fs=F2FS_TBYOOL"
        exit 1
    fi
    if [ ! -f "arch/arm64/configs/vendor/$1" ]; then
        echo "Error: MAIN_DEFCONFIG_IMPORT '$1' does not exist."
        exit 1
    fi
    if [ ! -f "arch/arm64/configs/vendor/$2" ]; then
        echo "Error: SUBS_DEFCONFIG_IMPORT '$2' does not exist."
        exit 1
    fi
    setup_environment "$1" "$2" "$3" "$4"
    setup_toolchain
    add_patches
    add_f2fs
    add_ksu
    compile_kernel
}

# Run the main function
main "$1" "$2" "$3" "$4"