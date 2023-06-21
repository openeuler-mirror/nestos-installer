# nestos-installer

nestos-installer is a program to assist with installing NestOS. It can do the following:

* Install the operating system to a target disk, optionally customizing it
  with an Ignition config or first-boot kernel parameters
  ([`nestos-installer install`](docs/cmd/install.md))
* Download and verify an operating system image for various cloud,
  virtualization, or bare metal platforms ([`nestos-installer download`](docs/cmd/download.md))
* List NestOS images available for download
  ([`nestos-installer list-stream`](docs/cmd/list-stream.md))
* Embed an Ignition config in a live ISO image to customize the running
  system that boots from it ([`nestos-installer iso ignition`](docs/cmd/iso.md))
* Wrap an Ignition config in an initrd image that can be appended to the
  live PXE initramfs to customize the running system that boots from it
  ([`nestos-installer pxe ignition`](docs/cmd/pxe.md))

The options available for each subcommand are available in the
[Command Line Reference](docs/cmd.md) or via the `--help` option.

Take a look at the [Getting Started Guide](docs/getting-started.md) for more
information regarding how to download and use `nestos-installer`.

## about

nestos-installer 根据 coreos-installer 进行适配修改。
后期结合社区需求，会将上游社区（coreos-installer）的代码回合到本仓库，并由该仓库负责人维护。

## Contact

- Mail: duyiwei@kylinos.cn
- Reporting bugs: [issues](https://gitee.com/openeuler/nestos-installer/issues/new)


