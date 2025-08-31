# Aesthetic Buildroot

A buildroot distribution with taste.

## High Level Notes

- `/var` is mounted as tmpfs, 50M in size

- set `journald.conf` to keep up to 10M of logs

- `/usr/bin/aebr-init` is executed, which configures the system from
  `/boot`

- Update scheme: the root image size is guaranteed to be exactly
  1GB. You can thus use `dd` with a new image and target the correct
  partition.

- The rpi3 board sets the kernel command line parameter
  rpi3.platform=true. This is then used as a condition to mount the
  first partition of the disk as /boot.


## Qemu

From the `buildroot/` directory:

```bash
qemu-system-aarch64 -M virt -cpu cortex-a53 -nographic -smp 1 -kernel output/images/Image -append "rootwait root=/dev/vda ro console=ttyAMA0" -netdev user,id=eth0 -device virtio-net-device,netdev=eth0 -drive file=output/images/rootfs.ext4,if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0
```

This starts up emulation with a readonly `/root`.


## Subtree

The `buildroot/` directory was pulled in with the following subtree
command:

```bash
git subtree add --prefix=buildroot https://github.com/buildroot/buildroot.git 2025.02.5 --squash
```


## TODO

- Attempt a buildroot subtree update.

- Note upgradability in the future, but for now you just gotta flash a
  new drive. Make sure the output images contain partition specific
  images. Write instructions on how to flash those.

- Reorg so that overlay is shared, there's a common set of br2 configs
  and linux fragments, and then there are board specific br2 and linux
  fragments. Set up a Makefile to auto generate the board specific
  ones.

- Makefile for running qemu.
