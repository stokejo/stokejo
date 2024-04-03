#!/bin/bash

wipefs -a $DISK
parted $DISK mklabel GPT

parted $DISK << EOF
mkpart primary 1MiB 8MiB
set 1 BIOS_GRUB on
EOF

parted $DISK << EOF
mkpart primary 8MiB 1GiB
mkpart primary 1GiB 100%
EOF

sleep 5

wipefs -a $DISK-part1
wipefs -a $DISK-part2
wipefs -a $DISK-part3
