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
    local KERNELSU_SELECTOR="$3"
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
    if [[ "$KERNELSU_SELECTOR" == "--ksu=KSU_BLXX" ]]; then
        export KSU_SETUP_URI="https://github.com/backslashxx/KernelSU"
        export KSU_BRANCH="master"
        export KSU_GENERAL_PATCH="https://github.com/ximi-mojito-test/mojito_krenol/commit/ebc23ea38f787745590c96035cb83cd11eb6b0e7.patch"
    elif [[ "$KERNELSU_SELECTOR" == "--ksu=KSU_NEXT" ]]; then
        export KSU_SETUP_URI="https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh"
        export KSU_BRANCH="legacy"
        export KSU_GENERAL_PATCH="https://github.com/ximi-mojito-test/mojito_krenol/commit/8e25004fdc74d9bf6d902d02e402620c17c692df.patch"
    elif [[ "$KERNELSU_SELECTOR" == "--ksu=NONE" ]]; then
        export KSU_SETUP_URI=""
        export KSU_BRANCH=""
        export KSU_GENERAL_PATCH=""
    else
        echo "Invalid KernelSU selector. Use --ksu=KSU_BLXX, --ksu=KSU_NEXT, or --ksu=NONE."
        exit 1
    fi
    # DTBO Exports
    export DTBO_PATCH1="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/e517bc363a19951ead919025a560f843c2c03ad3.patch"
    export DTBO_PATCH2="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/a62a3b05d0f29aab9c4bf8d15fe786a8c8a32c98.patch"
    export DTBO_PATCH3="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/4b89948ec7d610f997dd1dab813897f11f403a06.patch"
    export DTBO_PATCH4="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/fade7df36b01f2b170c78c63eb8fe0d11c613c4a.patch"
    export DTBO_PATCH5="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/2628183db0d96be8dae38a21f2b09cb10978f423.patch"
    export DTBO_PATCH6="https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/31f4577af3f8255ae503a5b30d8f68906edde85f.patch"
    # Main LN8K Exports
    export LN8K_PATCH1="https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/7b73f853977d2c016e30319dffb1f49957d30b40.patch"
    export LN8K_PATCH2="https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/63dddc108d57dc43e1cd0da0f1445875f760cf97.patch"
    export LN8K_PATCH3="https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/95816dff2ecc7ddd907a56537946b5cf1e864953.patch"
    export LN8K_PATCH4="https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/330c60abc13530bd05287f9e5395d283ebfd6d0b.patch"
    export LN8K_PATCH5="https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/0477c7006b41a1763b3314af9eb300491b91fc25.patch"
    # Sub LN8K Exports
    export LN8K_PATCH6="https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/aa5ddad5be03aa7436e7ce6e84d46b280849acae.patch"
    export LN8K_PATCH7="https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/857638b0da6f80830122b8d1b45c7842970e76c3.patch"
    export LN8K_PATCH8="https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/3a68adff14cbedd09ce2a735d575c3bf92dd696f.patch"
    export LN8K_PATCH9="https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/30fcc15d5dcf2cfc3b83a5a7d4a77e2880639fa5.patch"
    export LN8K_PATCH10="https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/1a17a6fbbf59d901c4b3aec66c06a1c96cd89c7e.patch"
    # TheSillyOk's Exports
    export SILLY_KPATCH_NEXT_PATCH="https://github.com/TheSillyOk/kernel_ls_patches/raw/refs/heads/master/kpatch_fix.patch"
    # KernelSU umount patch
    export KSU_UMOUNT_PATCH="https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/64db0dfa2f8aa6c519dbf21eb65c9b89643cda3d.patch"
    # Simple GPU Algorithm exports
    export SIMPLEGPU_PATCH1="https://github.com/ximi-mojito-test/mojito_krenol/commit/466da67f1ee6a567c9bd60282123a07fc9ac75b5.patch"
    export SIMPLEGPU_PATCH2="https://github.com/ximi-mojito-test/mojito_krenol/commit/f87bd5e18caba7dd0ba0b5c9147d59bb21ff606f.patch"
    export SIMPLEGPU_PATCH3="https://github.com/ximi-mojito-test/mojito_krenol/commit/ebf97a47dc43b1285602c4d3cc9667377d021f1e.patch"
    # JackA1ltman SUSFS export
    export JACK_SUSFS_PATCH="https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd/raw/refs/heads/mainline/Patches/Patch/susfs_patch_to_4.14.patch"
    # vbajs KSU SUSFS Export
    export VB_KSU_SUSFS_PATCH="https://github.com/vbajs/KernelSU-Next/commit/d2befa1c56c53e11e3f22cbce06f506a7394140f.patch"
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
    # Apply DTBO patches
    echo "Applying DTBO patches..."
    wget -qO- $DTBO_PATCH1 | patch -s -p1
    wget -qO- $DTBO_PATCH2 | patch -s -p1
    wget -qO- $DTBO_PATCH3 | patch -s -p1
    wget -qO- $DTBO_PATCH4 | patch -s -p1
    wget -qO- $DTBO_PATCH5 | patch -s -p1
    wget -qO- $DTBO_PATCH6 | patch -s -p1
    # Apply LN8K patches
    echo "Applying LN8K patches..."
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
    echo "CONFIG_CHARGER_LN8000=y" >> $MAIN_DEFCONFIG
    # Apply Simple GPU Algorithm patches
    echo "Applying Simple GPU Algorithm patches..."
    wget -qO- $SIMPLEGPU_PATCH1 | patch -s -p1
    wget -qO- $SIMPLEGPU_PATCH2 | patch -s -p1
    wget -qO- $SIMPLEGPU_PATCH3 | patch -s -p1
    echo "CONFIG_SIMPLE_GPU_ALGORITHM=y" >> $MAIN_DEFCONFIG
    # Apply general config patches
    echo "Tuning the rest of default configs..."
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

# Add KernelSU function
add_ksu() {
    if [ -n "$KSU_SETUP_URI" ]; then
        echo "Setting up KernelSU..."
        # Apply umount backport and kpatch fixes
        wget -qO- $KSU_UMOUNT_PATCH | patch -s -p1
        wget -qO- $SILLY_KPATCH_NEXT_PATCH | patch -s -p1
        if [[ "$KSU_SETUP_URI" == *"backslashxx/KernelSU"* ]]; then
            # Apply manual hook
            # disable for now, we're gonna use hookless mode
            # wget -qO- $KSU_GENERAL_PATCH | patch -s -p1
            # Clone repository
            git clone $KSU_SETUP_URI --branch $KSU_BRANCH KernelSU &> /dev/null
            # Manual symlink creation
            cd drivers
            ln -sfv ../KernelSU/kernel kernelsu
            cd ..
            # Manual Makefile and Kconfig Editing
            sed -i '$a \\nobj-$(CONFIG_KSU) += kernelsu/' drivers/Makefile
            sed -i '/endmenu/i source "drivers/kernelsu/Kconfig"\n' drivers/Kconfig
            # Manual Config Enablement
            echo "CONFIG_KSU=y" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_TAMPER_SYSCALL_TABLE=y" >> $MAIN_DEFCONFIG
        elif [[ "$KSU_SETUP_URI" == *"KernelSU-Next/KernelSU-Next"* ]]; then
            # Apply manual hook
            wget -qO- $KSU_GENERAL_PATCH | patch -s -p1
            # Run Setup Script
            curl -LSs $KSU_SETUP_URI | bash -s $KSU_BRANCH
            # Manual Config Enablement
            echo "CONFIG_KSU=y" >> $MAIN_DEFCONFIG
            echo "KSU_MANUAL_HOOK=y" >> $MAIN_DEFCONFIG
            # Apply susfs patches
            echo "Applying SUSFS patches..."
            wget -qO- $JACK_SUSFS_PATCH | patch -s -p1
            # Apply ksu susfs patches
            cd KernelSU-Next
            git revert -n 8002f62
            wget -qO- $VB_KSU_SUSFS_PATCH | patch -s -p1
            git config user.email $GIT_EMAIL
            git config user.name $GIT_NAME
            git config set advice.addEmbeddedRepo true
            git add .
            git commit -m "cleanup: applied patches before build" &> /dev/null
            cd ..
            # Enable susfs configs
            echo "CONFIG_KSU_SUSFS=y" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_SUS_PATH=y" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_SUS_MOUNT=n" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_SUS_KSTAT=y" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_SPOOF_UNAME=y" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_ENABLE_LOG=y" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=n" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y" >> $MAIN_DEFCONFIG
            echo "CONFIG_KSU_SUSFS_SUS_MAP=y" >> $MAIN_DEFCONFIG
            # Disable custom susfs configs
            echo "CONFIG_KSU_SUSFS_TRY_UMOUNT=n" >> $MAIN_DEFCONFIG
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
    git commit -m "cleanup: applied patches before build" &> /dev/null
    # Start compilation
    echo "Starting kernel compilation..."
    make -s O=out ARCH=arm64 $COMPILE_MAIN_DEFCONFIG $COMPILE_SUBS_DEFCONFIG &> /dev/null
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
        echo "Usage: $0 <MAIN_DEFCONFIG_IMPORT> <SUBS_DEFCONFIG_IMPORT> <KERNELSU_SELECTOR>"
        echo "Example: $0 sdmsteppe-perf_defconfig sweet.config --ksu=KSU_BLXX"
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
    add_ksu
    compile_kernel
}

# Run the main function
main "$1" "$2" "$3" "$4"