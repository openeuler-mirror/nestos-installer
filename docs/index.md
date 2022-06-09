---
nav_order: 1
---

# NestOS Installer
# soon will available same as coreos
[![Container image](https://quay.io/repository/coreos/coreos-installer/status)](https://quay.io/repository/coreos/coreos-installer)
[![crates.io](https://img.shields.io/crates/v/coreos-installer.svg)](https://crates.io/crates/coreos-installer)

nestos-installer is a program to assist with installing NestOS
. It can do the following:

* Install the operating system to a target disk, optionally customizing it
  with an Ignition config or first-boot kernel parameters
  ([`nestos-installer install`](cmd/install.md))
* Download and verify an operating system image for various cloud,
  virtualization, or bare metal platforms ([`nestos-installer download`](cmd/download.md))
* List NestOS images available for download
  ([`nestos-installer list-stream`](cmd/list-stream.md))
* Embed an Ignition config in a live ISO image to customize the running
  system that boots from it ([`nestos-installer iso ignition`](cmd/iso.md))
* Wrap an Ignition config in an initrd image that can be appended to the
  live PXE initramfs to customize the running system that boots from it
  ([`nestos-installer pxe ignition`](cmd/pxe.md))

The options available for each subcommand are available in the
[Command Line Reference](cmd.md) or via the `--help` option.

Take a look at the [Getting Started Guide](getting-started.md) for more
information regarding how to download and use `nestos-installer`.
