#!/bin/bash

ROOT_POOL_NAME="main"
BOOT_POOL_NAME="boot"

HOSTNAME="stokejo"
DISK="/dev/disk/by-id/"

cat << EOF >> /etc/apt/sources.list.d/backports.list
deb http://deb.debian.org/debian bookworm-backports main contrib
EOF

apt update

apt install dkms debootstrap parted
apt install -t bookworm-backports zfs-dkms --no-install-recommends
apt install -t bookworm-backports util-linux zfsutils-linux

. wipe.sh

zpool create -o ashift=12 \
	-o cachefile=/etc/zfs/zpool.cache \
	-o compatibility=grub2 \
	-O devices=off \
	-O acltype=posixacl -O xattr=sa \
	-O normalization=formD \
	-O relatime=on \
	-O canmount=off -O mountpoint=/boot -R /mnt \
	$BOOT_POOL_NAME $DISK-part2

zpool create -o ashift=12 \
	-O acltype=posixacl -O xattr=sa -O dnodesize=auto \
	-O normalization=formD \
	-O relatime=on \
	-O canmount=off -O mountpoint=/ -R /mnt \
	$ROOT_POOL_NAME $DISK-part3

zfs create -o canmount=noauto -o mountpoint=/ $ROOT_POOL_NAME/ROOT
zfs mount $ROOT_POOL_NAME/ROOT

zfs create -o mountpoint=/boot $BOOT_POOL_NAME/BOOT

debootstrap bookworm /mnt

mkdir /mnt/etc/zfs
cp /etc/zfs/zpool.cache /mnt/etc/zfs/

hostname $HOSTNAME
hostname > /mnt/etc/hostname

rm /mnt/etc/apt/sources.list

cat << EOF >> /mnt/etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main contrib
deb-src http://deb.debian.org/debian bookworm main contrib

deb http://deb.debian.org/debian-security bookworm-security main contrib
deb-src http://deb.debian.org/debian-security bookworm-security main contrib

deb http://deb.debian.org/debian bookworm-updates main contrib
deb-src http://deb.debian.org/debian bookworm-updates main contrib
EOF

cat << EOF >> /mnt/etc/apt/sources.list.d/backports.list
deb http://deb.debian.org/debian bookworm-backports main contrib
EOF

mount --make-private --rbind /sys /mnt/sys && mount --make-private --rbind /proc /mnt/proc
mount --make-private --rbind /dev /mnt/dev

cp stage_2.sh /mnt/stage_2.sh

chroot /mnt /usr/bin/env ROOT_POOL_NAME=$ROOT_POOL_NAME \
	BOOT_POOL_NAME=$BOOT_POOL_NAME \
	DISK=$DISK bash --login
