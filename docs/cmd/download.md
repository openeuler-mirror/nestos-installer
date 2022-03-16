---
layout: default
parent: Command line reference
nav_order: 2
---

# nestos-installer download

## Description

Download a NestOS image

## Usage

**nestos-installer download** [*options*]

## Options

| **--stream**, **-s** *name* | NestOS stream [default: stable] |
| **--architecture** *name* | Target CPU architecture [default: x86_64] |
| **--platform**, **-p** *name* | NestOS platform name [default: metal] |
| **--format**, **-f** *name* | Image format [default: raw.xz] |
| **--image-url**, **-u** *URL* | Manually specify the image URL |
| **--directory**, **-C** *path* | Destination directory [default: .] |
| **--decompress**, **-d** | Decompress image and don't save signature |
| **--insecure** | Skip signature verification |
| **--stream-base-url** *URL* | Base URL for NestOS stream metadata |
| **--fetch-retries** *N* | Fetch retries, or string "infinite" |
