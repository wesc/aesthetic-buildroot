default:
    @just --list

make-defconfigs:
    buildroot/support/kconfig/merge_config.sh -m -O buildroot/configs \
        buildroot/configs/qemu_aarch64_virt_defconfig \
        configs/qemu/defconfig \
        configs/common_defconfig
    mv buildroot/configs/.config buildroot/configs/aebr_qemu_defconfig
    buildroot/support/kconfig/merge_config.sh -m -O buildroot/configs \
        buildroot/configs/raspberrypi3_defconfig \
        configs/rpi3/defconfig \
        configs/common_defconfig
    mv buildroot/configs/.config buildroot/configs/aebr_rpi3_defconfig
