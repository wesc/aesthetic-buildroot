# Aesthetic Buildroot

A buildroot distribution with taste.

## High Level Notes

- We define two configs, one for the Raspberry Pi 3 and the other for
  Qemu: `aebr_rpi3_defconfig` and `aebr_qemu_defconfig`. If you have
  the ability to test other SBCs, feel free to submit an issue and I
  will work with you to integrate it.

- Systemd as init. journald is set up to keep up to 10M of logs.

- `/var` is mounted as tmpfs, 50M in size.

- `/usr/bin/aebr-init` is executed, which configures the system from
  `/boot/aebr.conf`.

- Update scheme: the root image size is guaranteed to be exactly
  1GB. You can thus use `dd` with a new image and target the correct
  partition.

- The rpi3 board sets the kernel command line parameter
  rpi3.platform=true. This is then used as a condition to mount the
  first partition of the disk as /boot.


## Build

```bash
cd buildroot
make aebr_qemu_defconfig
make
```

Go get some coffee, this might be a few hours.


## Qemu Boot

To boot Qemu image from the `buildroot/` directory:

```bash
qemu-system-aarch64 -M virt -cpu cortex-a53 -nographic -smp 1 -kernel output/images/Image -append "rootwait root=/dev/vda ro console=ttyAMA0" -netdev user,id=eth0 -device virtio-net-device,netdev=eth0 -drive file=output/images/rootfs.ext4,if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0
```

Or if you have just installed:

```bash
just boot-qemu
```

This starts up emulation with a readonly `/root`.


## Rpi3 Boot

After flashing the rpi3 image, you can plug it in (or mount it from
the command line) and the `/boot` partition becomes available. You can
then create an `aebr.conf` file that will initialize things like the
wifi on boot. To see what is possible, take a look at
`buildroot/board/aebr/rootfs-overlay/boot/aebr.conf.template`.


## Customization

So you could just build and run aesthetic and that would be a hoot,
but you probably want to customize it with your own packages. The
easiest way to do this is to clone this repo and create a BR2_EXTERNAL
directory. In fact, this repo provides an example:

```bash
cd buildroot
make BR2_EXTERNAL=../cowsay-external aebr_qemu_defconfig
make menuconfig (then navigate to external packages and select cowsay)
make
```

Alternatively you can use subtree to pull in the `buildroot/` directory:

```bash
git subtree add --prefix=buildroot https://github.com/wesc/aesthetic-buildroot.git buildroot
```

After booting up the new image and logging in, run:

```bash
cowsay --random hello world
```

Do it more than once just for good measure.


## Subtree

The `buildroot/` directory was pulled in with the following subtree
command:

```bash
git subtree add --prefix=buildroot https://github.com/buildroot/buildroot.git 2025.02.5 --squash
```

To update the buildroot install to tag TAG:

```bash
git subtree pull --prefix=buildroot https://github.com/buildroot/buildroot.git TAG --squash
```


## TODO

- Makefile or justfile for some handy commands
