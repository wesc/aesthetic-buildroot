default:
    @just --list

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

boot-qemu:
    qemu-system-aarch64 -M virt -cpu cortex-a53 -nographic -smp 1 -kernel output/images/Image -append "rootwait root=/dev/vda ro console=ttyAMA0" -netdev user,id=eth0 -device virtio-net-device,netdev=eth0 -drive file=output/images/rootfs.ext4,if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0
