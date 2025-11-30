default:
    @just --list

# Generate defconfigs
make-defconfigs:
    buildroot/support/kconfig/merge_config.sh -m -O buildroot/configs \
        buildroot/configs/qemu_aarch64_virt_defconfig \
        buildroot/board/aebr/qemu/defconfig \
        buildroot/board/aebr/common_defconfig
    mv buildroot/configs/.config buildroot/configs/aebr_qemu_defconfig
    buildroot/support/kconfig/merge_config.sh -m -O buildroot/configs \
        buildroot/configs/raspberrypi3_defconfig \
        buildroot/board/aebr/rpi3/defconfig \
        buildroot/board/aebr/common_defconfig
    mv buildroot/configs/.config buildroot/configs/aebr_rpi3_defconfig

# Build both QEMU and Raspbery Pi 3 images
build-all: && build-qemu build-rpi3

# Build QEMU image
[working-directory: 'buildroot']
build-qemu:
    make O=output/qemu aebr_qemu_defconfig
    time make O=output/qemu

# Build Raspberry Pi 3 image
[working-directory: 'buildroot']
build-rpi3:
    make O=output/rpi3 aebr_rpi3_defconfig
    time make O=output/rpi3

# Clean
[working-directory: 'buildroot']
clean:
    make clean

# Deeper clean
[working-directory: 'buildroot']
distclean:
    make distclean

# Boot QEMU with the buildroot image (pass 'ssh' to enable SSH port forwarding on localhost:2222)
[working-directory: 'buildroot/output/qemu/images']
boot-qemu ssh="":
    #!/usr/bin/env bash
    NETDEV_OPTS="user,id=eth0"
    if [ -n "{{ssh}}" ]; then
        NETDEV_OPTS="${NETDEV_OPTS},hostfwd=tcp::2222-:22"
    fi
    ../host/bin/qemu-system-aarch64 \
        -M virt \
        -cpu cortex-a53 \
        -nographic \
        -smp 1 \
        -kernel Image \
        -append "rootwait root=/dev/vda ro console=ttyAMA0" \
        -netdev "${NETDEV_OPTS}" \
        -device virtio-net-device,netdev=eth0 \
        -drive file=rootfs.ext4,if=none,format=raw,id=hd0 \
        -device virtio-blk-device,drive=hd0
