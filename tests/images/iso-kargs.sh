#!/bin/bash
# change coreos to nestos
set -xeuo pipefail
PS4='${LINENO}: '

fatal() {
    echo "$@" >&2
    exit 1
}

digest() {
    # Ignore filename
    sha256sum "${1:--}" | awk '{print $1}'
}

grepq() {
    # Emulate grep -q without actually using it, to avoid propagating write
    # errors to the writer after a match, which would cause problems with
    # -o pipefail
    grep "$@" > /dev/null
}

iso=$1; shift
iso=$(realpath "${iso}")

s390x=
if [[ "${iso}" == *.s390x.* ]]; then
    s390x=1
    if [[ "${iso}" == *2023-03.s390x.* ]]; then
        echo "Skipped; kargs not supported on s390x before July 2023"
        exit 0
    fi
fi

tmpd=$(mktemp -d)
trap 'rm -rf "${tmpd}"' EXIT
cd "${tmpd}"

if [ "${iso%.xz}" != "${iso}" ]; then
    xz -dc "${iso}" > test.iso
else
    cp --reflink=auto "${iso}" "test.iso"
fi
iso=test.iso
out_iso="${iso}.out"

# Sanity-check the ISO doesn't somehow already have the karg we're testing with.
if nestos-installer iso kargs show "${iso}" | grepq foobar; then
    fatal "Unexpected foobar karg in iso kargs"
fi

orig_hash=$(digest "${iso}")

# Stream modification to stdout.
stdout_hash=$(nestos-installer iso kargs modify -a foobar=oldval -a dodo -o - "${iso}" | tee "${out_iso}" | digest)
nestos-installer iso kargs show "${out_iso}" | grepq 'foobar=oldval dodo'
nestos-installer iso kargs modify -d foobar=oldval -d dodo -o - "${out_iso}" > "${iso}"
if nestos-installer iso kargs show "${iso}" | grepq 'foobar'; then
    fatal "Unexpected foobar karg in iso kargs"
fi
hash=$(digest "${iso}")
if [ "${orig_hash}" != "${hash}" ]; then
    fatal "Hash doesn't match original hash: ${hash} vs ${orig_hash}"
fi

# Test all the modification operations.
nestos-installer iso kargs modify -a foobar=oldval -a dodo "${iso}"
nestos-installer iso kargs show "${iso}" | grepq 'foobar=oldval dodo'
hash=$(digest "${iso}")
if [ "${stdout_hash}" != "${hash}" ]; then
    fatal "Streamed hash doesn't match modified hash: ${stdout_hash} vs ${hash}"
fi
rm "${out_iso}"
nestos-installer iso kargs modify -r foobar=oldval=newval "${iso}" -o "${out_iso}"
nestos-installer iso kargs show "${out_iso}" | grepq 'foobar=newval dodo'
rm "${iso}"
nestos-installer iso kargs modify -d foobar=newval -d dodo "${out_iso}" -o "${iso}"
if nestos-installer iso kargs show "${iso}" | grepq 'foobar'; then
    fatal "Unexpected foobar karg in iso kargs"
fi

hash=$(digest "${iso}")
if [ "${orig_hash}" != "${hash}" ]; then
    fatal "Hash doesn't match original hash: ${hash} vs ${orig_hash}"
fi

# Test the largest karg; we get the full area length from --header and subtract
# the default kargs size to get the size of the overflow embed area.
embed_size=$(nestos-installer dev show iso --kargs "${iso}" | jq .length)
embed_default_kargs_size=$(nestos-installer iso kargs show --default "${iso}" | wc -c)
embed_usable_size=$((${embed_size} - ${embed_default_kargs_size} - 1))

long_karg=$(printf '%*s' $((embed_usable_size)) | tr ' ' "k")
nestos-installer iso kargs modify -a "${long_karg}" "${iso}"
nestos-installer iso kargs show "${iso}" | grepq " ${long_karg}\$"
nestos-installer iso kargs reset "${iso}"
long_karg=$(printf '%*s' $((embed_usable_size + 1)) | tr ' ' "k")
if nestos-installer iso kargs modify -a "${long_karg}" "${iso}" 2>err.txt; then
    fatal "Was able to put karg longer than area?"
fi
grepq 'kargs too large for area' err.txt

# Test `reset`.
nestos-installer iso kargs modify -a foobar "${iso}"
rm "${out_iso}"
nestos-installer iso kargs reset "${iso}" -o "${out_iso}"
hash=$(digest "${out_iso}")
if [ "${orig_hash}" != "${hash}" ]; then
    fatal "Hash doesn't match original hash: ${hash} vs ${orig_hash}"
fi
nestos-installer iso kargs reset "${iso}" -o - > "${out_iso}"
hash=$(digest "${out_iso}")
if [ "${orig_hash}" != "${hash}" ]; then
    fatal "Hash doesn't match original hash: ${hash} vs ${orig_hash}"
fi
nestos-installer iso kargs reset "${iso}"
hash=$(digest "${iso}")
if [ "${orig_hash}" != "${hash}" ]; then
    fatal "Hash doesn't match original hash: ${hash} vs ${orig_hash}"
fi

# Check modification against expected ground truth.
nestos-installer iso kargs modify -a foobar=val "${iso}"
offset=$(nestos-installer dev show iso --kargs "${iso}" | jq -r .kargs[0].offset)
length=$(nestos-installer dev show iso --kargs "${iso}" | jq -r .kargs[0].length)
expected_args="$(nestos-installer iso kargs show --default "${iso}") foobar=val"
expected_args_len="$(echo -n "${expected_args}" | wc -c)"
if [[ -n "${s390x}" ]]; then
    # There is no filler or newline character on s390x's kargs line, but null bytes:
    #    $ hexdump -C -s 138457 -n 896 builds/latest/s390x/*.iso
    #    00021cd9  69 67 6e 69 74 69 6f 6e  2e 70 6c 61 74 66 6f 72  |ignition.platfor|
    #    00021ce9  6d 2e 69 64 3d 6d 65 74  61 6c 00 00 00 00 00 00  |m.id=metal......|
    # Create temp file with kargs and nulls and compare it to bytes of the iso image:
    echo -n "${expected_args}" > cmdline.s390x
    truncate -s "${length}" cmdline.s390x
    if ! cmp -s <(dd if=${iso} skip=${offset} count=${length} bs=1 status=none) cmdline.s390x; then
        fatal "Failed to manually round-trip kargs"
    fi
else
    filler="$(printf '%*s' $((${length} - ${expected_args_len} - 1)) | tr ' ' '#')"
    if ! echo -en "${expected_args}\n${filler}" | cmp -s <(dd if=${iso} skip=${offset} count=${length} bs=1 status=none) -; then
        fatal "Failed to manually round-trip kargs"
    fi
fi

# Done
echo "Success."
