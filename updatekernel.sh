#!/bin/sh
IMG=$1
KERNEL=$2

PART=1
MNT=/mnt/${IMG}${PART}

SECOFFSET=`sudo fdisk -l -o Device,Start ${IMG} | awk -f part.awk -v selected=$PART`
OFFSET=$((512*$SECOFFSET))
echo Mount $IMG offset $SECOFFSET as $MNT

LOOPDEV=`sudo losetup -o $OFFSET --show -f $IMG`
sudo mkdir -p $MNT
sudo mount -o rw $LOOPDEV $MNT 

sudo md5sum ${MNT}/bzImage
sudo cp ${KERNEL} ${MNT}/bzImage
sudo md5sum ${MNT}/bzImage

echo Unmount $MNT
sudo umount -d $MNT

if [ -d "${MNT}" ]; then
	echo Removing ${MNT}
	sudo rmdir ${MNT}
fi
