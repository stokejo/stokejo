#!/bin/bash

ln -s /proc/self/mounts /etc/mtab

apt update && apt install locales

# Choose en_US.UTF-8 then C.UTF8
dpkg-reconfigure locales

apt install console-setup

# Hit enter every time
dpkg-reconfigure tzdata keyboard-configuration console-setup

apt install dpkg-dev linux-headers-generic linux-image-generic
apt install dkms

apt install -t bookworm-backports zfs-dkms --no-install-recommends
apt install -t bookworm-backports zfsutils-linux
apt install -t bookworm-backports zfs-initramfs

echo REMAKE_INITRD=yes > /etc/dkms/zfs.conf

apt install grub-pc
apt purge os-prober

passwd

# Install bootloader
update-initramfs -c -k all

REPLACEMENT="root=ZFS=$ROOT_POOL_NAME/ROOT"

sed -i -e \
	"s#GRUB_CMDLINE_LINUX=\"\"#GRUB_CMDLINE_LINUX=\"$REPLACEMENT\"#g" \
	"/etc/default/grub"

update-grub && grub-install $DISK

mkdir /etc/zfs/zfs-list.cache
touch /etc/zfs/zfs-list.cache/$BOOT_POOL_NAME
touch /etc/zfs/zfs-list.cache/$ROOT_POOL_NAME

echo ""
echo "NOW COMPLETE INSTRUCTION"
echo ""
