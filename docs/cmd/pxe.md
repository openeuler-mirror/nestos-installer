---
layout: default
parent: Command line reference
nav_order: 5
---

# nestos-installer pxe
{: .no_toc }

1. TOC
{:toc}

# nestos-installer pxe ignition wrap

## Description

Wrap an Ignition config in an initrd image

## Usage

**nestos-installer pxe ignition wrap**

## Options

| **--ignition-file**, **-i** *path* | Ignition config to wrap [default: stdin] |
| **--output**, **-o** *path* | Write to a file instead of stdout |

# nestos-installer pxe ignition unwrap

## Description

Show the wrapped Ignition config in an initrd image

## Usage

**nestos-installer pxe ignition unwrap** *initrd*

## Arguments

| **initrd** | initrd image |
