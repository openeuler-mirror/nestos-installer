---
layout: default
nav_order: 2
---

# Getting Started
{: .no_toc }

1. TOC
{:toc}

## On NestOS

nestos-installer is included in NestOS.  Just run
`nestos-installer` from the command line.  NestOS provides
[live CD and network boot images](https://nestos.org.cn)
you can run from RAM; you can use these to run nestos-installer to install
NestOS to disk.

## Run from a container
# not available in NestOS
You can run nestos-installer from a container.  You'll need to bind-mount
`/dev` and `/run/udev`, as well as a data directory if you want to access
files in the host.  For example:

```sh
sudo podman run --pull=always --privileged --rm \
    -v /dev:/dev -v /run/udev:/run/udev -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release \
    install /dev/vdb -i config.ign
```

## Via a openEuler RPM

`nestos-installer` is packaged in openEuler:

```sh
sudo dnf install nestos-installer
```

Note in fact you can also do this inside a `podman run --privileged` type
container configured similarly to the above for the "pre-built container"
path, not necessarily the host's root filesystem.
See also [toolbox](https://github.com/containers/toolbox).

## Install with Cargo

You can also install just the nestos-installer binary with Rust's Cargo package manager:

```sh
cargo install nestos-installer
```

## Build and install from source tree

To build from the source tree:

```sh
make
```

To install the binary and systemd units to a target rootfs
(e.g. under a
[coreos-assembler](https://github.com/coreos/coreos-assembler)
workdir):

```sh
make install DESTDIR=/my/dest/dir
```

## Run from a live image using kernel command-line options

If you want a fully automated install, you can configure the NestOS
live CD or netboot image to run nestos-installer and then reboot the system.
You do this by passing `nestos.inst.<arg>` arguments on the kernel command
line.

### Kernel command line options for nestos-installer running as a service

* `nestos.inst.install_dev` - The block device on the system to install to,
  such as `/dev/sda`.  Mandatory.
* `nestos.inst.stream` - Download and install the current release of
  NestOS from the specified stream.  Optional; defaults to
  installing from local media if run from NestOS live ISO or PXE media,
  and to `stable` on other systems.
* `nestos.inst.image_url` - Download and install the specified NestOS image,
  overriding `nestos.inst.stream`.  Optional.
* `nestos.inst.ignition_url` - The URL of the Ignition config.  Optional.
  If missing, no Ignition config will be embedded, which is probably not
  what you want.
* `nestos.inst.platform_id` - The Ignition platform ID of the platform the
  NestOS image is being installed on.  Optional; defaults to `metal`.
  Normally this should be specified only if installing inside a virtual
  machine.
* `nestos.inst.save_partlabel` - Comma-separated labels of partitions to
  preserve during the install.  Glob-style wildcards are permitted.  The
  specified partitions need not exist.  Optional.
* `nestos.inst.save_partindex` - Comma-separated indexes of partitions to
  preserve during the install.  Ranges (`m-n`) are permitted, and either `m`
  or `n` can be omitted.  The specified partitions need not exist.
  Optional.
* `nestos.inst.insecure` - Permit the OS image to be unsigned.  Optional.
* `nestos.inst.skip_reboot` - Don't reboot after installing.  Optional.

### Installing from ISO

Download a NestOS ISO image:

```
podman run --privileged --pull=always --rm -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release download -f iso
```

The ISO image can install in either legacy boot (BIOS) mode or in UEFI
mode. You can boot it in either mode, regardless of what mode the OS will
boot from once installed.

Burn the ISO to disk and boot it, or use ISO redirection via a LOM interface.
Alternatively you can use a VM like so:

```
virt-install --name cdrom --ram 4500 --vcpus 2 --disk size=20 --accelerate --cdrom /path/to/NestOS-xxx.iso --network default
```

Alternatively you can use `qemu` directly.  Create a disk image to use as
install target:

```
qemu-img create -f qcow2 fcos.qcow2 8G
```

Now, run the following qemu command:

```
qemu-system-x86_64 -accel kvm -name nestos -m 4500 -cpu host -smp 2 -netdev user,id=eth0,hostname=nestos -device virtio-net-pci,netdev=eth0 -drive file=/path/to/fcos.qcow2,format=qcow2  -cdrom /path/to/NestOS-xxx.iso
```

Once you have reached the boot menu, press `<TAB>` (isolinux) or
`e` (grub) to edit the kernel command line. Add the parameters to the
kernel command line telling it what you want it to do. For example:

- `nestos.inst.install_dev=/dev/sda`
- `nestos.inst.ignition_url=http://example.com/config.ign`

Now press `<ENTER>` (isolinux) or `<CTRL-x>` (grub) to kick off the
install.

The install will complete and eventually reboot the machine. After
reboot the machine will boot into the installed system and the
embedded Ignition config will run on first boot.

### Installing from PXE

Download a NestOS PXE kernel, initramfs, and rootfs image:

```
podman run --privileged --pull=always --rm -v .:/data -w /data \
    quay.io/coreos/coreos-installer:release download -f pxe
```

The PXE image can install in either legacy boot (BIOS) mode or in UEFI
mode. You can boot it in either mode, regardless of what mode the OS will
boot from once installed.

Here is an example `pxelinux.cfg` for booting the installer images with
PXELINUX:

```
DEFAULT pxeboot
TIMEOUT 20
PROMPT 0
LABEL pxeboot
    KERNEL fedora-coreos-32.20200809.2.1-live-kernel-x86_64
    APPEND initrd=fedora-coreos-32.20200809.2.1-live-initramfs.x86_64.img,fedora-coreos-32.20200809.2.1-live-rootfs.x86_64.img nestos.inst.install_dev=/dev/sda nestos.inst.ignition_url=http://192.168.1.101:8000/config.ign
IPAPPEND 2
```

If you don't know how to use this information to test a PXE install
you can start with something like
[these instructions](https://dustymabe.com/2019/01/04/easy-pxe-boot-testing-with-only-http-using-ipxe-and-libvirt/)
for testing out PXE installs via a local VM + libvirt.
