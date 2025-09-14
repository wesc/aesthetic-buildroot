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

build-all: && build-qemu build-rpi3

[working-directory: 'buildroot']
build-qemu:
    make O=output/qemu aebr_qemu_defconfig
    make O=output/qemu

[working-directory: 'buildroot']
build-rpi3:
    make O=output/rpi3 aebr_rpi3_defconfig
    make O=output/rpi3

[working-directory: 'buildroot']
clean:
    make clean

[working-directory: 'buildroot']
distclean:
    make distclean

[working-directory: 'buildroot/output/qemu/images']
boot-qemu:
    qemu-system-aarch64 -M virt -cpu cortex-a53 -nographic -smp 1 -kernel Image -append "rootwait root=/dev/vda ro console=ttyAMA0" -netdev user,id=eth0 -device virtio-net-device,netdev=eth0 -drive file=rootfs.ext4,if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0
    # to enable ssh port forwarding from local port 2222 to the qemu instance use the command below
    # qemu-system-aarch64 -M virt -cpu cortex-a53 -nographic -smp 1 -kernel Image -append "rootwait root=/dev/vda ro console=ttyAMA0" -netdev user,id=eth0,hostfwd=tcp::2222-:22 -device virtio-net-device,netdev=eth0 -drive file=rootfs.ext4,if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0
