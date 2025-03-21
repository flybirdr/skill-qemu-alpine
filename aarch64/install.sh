#!/bin/bash

URL_DISTR="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-virt-3.21.3-aarch64.iso"
URL_EFI="http://ftp.de.debian.org/debian/pool/main/e/edk2/qemu-efi-aarch64_2025.02-3_all.deb"

DISK_NAME="alpine.aarch64.qcow2"
DISK_SIZE="8G"

# Download Alpine
if [ ! -f $(basename $URL_DISTR) ]; then
	wget $URL_DISTR
fi

# Download efi for arm
if [ ! -f $(basename $URL_EFI) ]; then
	wget $URL_EFI
  dpkg -x $(basename $URL_EFI) tmp
  mv ./tmp/usr/share/AAVMF/AAVMF_CODE* ./
  rm -rf tmp
fi

# Create qemu disc
if [ ! -f "$DISK_NAME" ]; then
  qemu-img create -f qcow2 "$DISK_NAME" "$DISK_SIZE"
fi

# Run qemu
qemu-system-aarch64 -accel tcg,thread=multi \
  -machine virt \
  -cpu cortex-a53 -smp cores=4 \
  -m 2048 \
  -bios AAVMF_CODE.fd \
  -cdrom $(basename $URL_DISTR) \
  -drive format=qcow2,file=$DISK_NAME \
  -nographic \
  -nic user,model=virtio \
  -rtc base=utc,clock=host
