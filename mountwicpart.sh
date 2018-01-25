#!/bin/sh
IMG=$1
PART=$2
MNT=/mnt/${IMG}${PART}

SECOFFSET=`sudo fdisk -l -o Device,Start ${IMG} | awk -f part.awk -v selected=$PART`
OFFSET=$((512*$SECOFFSET))
echo Mount $IMG offset $SECOFFSET as $MNT

LOOPDEV=`sudo losetup -o $OFFSET --show -f $IMG`
sudo mkdir -p $MNT
sudo mount -o rw $LOOPDEV $MNT 
