# Aesthetic Buildroot

A buildroot distribution with good taste.


## High Level Notes

- Systemd as init. journald is set up to keep up to 10M of logs.

- Root is mounted ro, `/var` is mounted as tmpfs, 50M in size.

- `/usr/bin/aebr-init` is executed, which configures the system from
  `/boot/aebr.conf`.

- Update scheme: the root image size is guaranteed to be exactly
  1GB. You can thus use `dd` with a new image and target the correct
  partition.

- We define two configs, one for the Raspberry Pi 3 and the other for
  Qemu: `aebr_rpi3_defconfig` and `aebr_qemu_defconfig`. If you have
  the ability to test other SBCs, feel free to submit an issue and I
  will work with you to integrate it.


## Development

Much of the development is driven by the `justfile`. After a change to
any Buildroot or Linux fragments in
`buildroot/board/aebr/{qemu,rpi3}/` you should rebuild the defconfigs:

```bash
just make-defconfigs
```

Then to build a target, for example Qemu:

```bash
just build-qemu
```

Go get some coffee, this might be a few hours.

Run `just` for the full menu of commands.

Roughly, the strategy is that hardware specific configurations are
placed in `buildroot/configs/aebr_PLATFORM_defconfig` and
`buildroot/board/PLATFORM`, and common files are in
`buildroot/board/aebr/` and
`buildroot/board/aebr/rootfs-overlay/`. The aesthetically pleasing
thing to do is to keep all non-boot logic in `rootfs-overlay/` using
runtime detection to alter behavior on the flashed devices if
necessary. Boot and bootloader specific configs are in the individual
platform directories.

Most of what Aesthetic does on boot is in the `/usr/bin/aebr-init`
script, so a good place to start tinkering would be:

1. Examine `buildroot/board/aebr/rootfs-overlay/`, and within it
`usr/bin/aebr-init`.

2. The various systemd configs in
`buildroot/board/aebr/rootfs-overlay/`.

3. Do a Qemu build and bring it up: `just build-qemu` and then if you
have `qemu-system-aarch64` installed on your platform: `just
boot-qemu`.


## Direct Build

You can build directly with the Buildroot commands:

```bash
cd buildroot
make aebr_qemu_defconfig
make
```

For further information, see the Buildroot project.


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


## Aesthetically Pleasing Notes

### Why The Root Partition Is Read-Only

We deploy on Raspberry Pi devices, which are notorious for suffering
from disk corruption on sudden power failure. Because the target
aplications for Aesthetic are small hobbyist projects that aren't
going to get clean shutdowns, we need to protect against this
possibility. Stock Buildroot on a Pi can not even `poweroff` cleanly
without disk corruption... Aesthetic fixes this by taking great care
to remove a writable root.

This does make some things awkward, however, so if you must you can
always remount the root drive:

```bash
mount -o remount,rw /
```

And the suggested strategy is then to create a new disk partition and
filesystem, call it `/data` that is always mounted rw. You should then
edit `/etc/fstab` appropriately so that root can remain ro and your
`/data` partition can be fsck'd without blocking boot. You may do this
if you consider yourself a big kid, and so go forth and search for
yourself on how this can be accomplished.


### Boot and `/boot/aebr.conf`

The system boots up and fairly early on runs the aebr-init systemd
unit. It's best to just see what's in the `/usr/bin/aebr-init` file to
understand what it does, but roughly it looks for `/boot/aebr.conf`
then performs various actions on boot to enable the system to function
as expected. The design of the system is that a single image can be
generated with which downstream users only need to configure the
`aebr.conf` file. In the case of the Raspberry Pi, that file exists on
the FAT32 boot partition, which is what the user sees plugging in a
flashed SD card into their USB port.

The rpi3 board sets the kernel command line parameter
`rpi3.platform=true`. This is then used as a condition to mount the
first partition of the disk as /boot. The strategy going forward is
that new boards should contain their own parameters, such as
`rpi4.platform=true`, and this is how we achieve portability in the
root overlay services and applications.


### SSH & Logins

Root login is enabled for console (the default password is
`aesthetic`), and if you do no customization also via SSH. This is
obviously not the Right Thing To Do, and so you can configure
`/boot/aebr.conf` to disable root logins via password and to enable
authorized keys (the preferred method). See `aebr.conf.template` for
further details.

Aesthetic uses Dropbear and sets up symlinks from
`/etc/default/dropbear` to `/run/dropbear`, where the boot process
draws from `aebr.conf` and writes into system configs that are then
wiped on reboot. The advantage is simplicity and the ability to keep
root read-only, but the disadvantage is that Aesthetic regenerates a
SSH host key on every boot, and so you will get a warning when trying
to SSH in. This is an acceptable annoyance as it's not intended that
users will be logging in all that often. That said, with a little
Buildroot customization you can get Dropbear to use a consistent SSH
host every time, but that is beyond the scope of this project.

The choice of disabling root logins via ssh and keeping a weak ass
password is that that target use case is a hobbyist application built
on Aesthetic and deployed in a home. If done as suggested, physical
console is the only way to log in using the root password, and general
root login is via ssh keys. Hopefully you aren't opening up any
external ssh ports to your device, but if you are then at least you're
protected from brute force login attempts.


### Wifi

The rpi3 version of the system sets up and configures iwd for wifi
support. See `aebr.conf` for how to configure.


### Your Application

As mentioned earlier in this doc, there is an example of the Cowsay
application and how to set it up with Aesthetic as a base. In general,
you'll need to set up your packages so that they run from `/run` or
`/var` rather than attempting to write to disk. There are various
examples of how to do this in Aesthetic, and no doubt a good coding
agent can stub out how to do it for your app.


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
