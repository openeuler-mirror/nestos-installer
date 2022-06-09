---
parent: Command line reference
nav_order: 2
---

# nestos-installer download

```
Download a NestOS image

USAGE:
    nestos-installer download [OPTIONS]

OPTIONS:
    -s, --stream <name>            NestOS stream [default: stable]
    -a, --architecture <name>      Target CPU architecture [default: x86_64]
    -p, --platform <name>          NestOS platform name [default: metal]
    -f, --format <name>            Image format [default: raw.xz]
    -u, --image-url <URL>          Manually specify the image URL
    -C, --directory <path>         Destination directory [default: .]
    -d, --decompress               Decompress image and don't save signature
        --insecure                 Skip signature verification
        --stream-base-url <URL>    Base URL for NestOS stream metadata
        --fetch-retries <N>        Fetch retries, or "infinite" [default: 0]
    -h, --help                     Print help information
```
