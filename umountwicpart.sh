#!/bin/sh
IMG=$1
PART=$2
MNT=/mnt/${IMG}${PART}

LOOPDEV=`awk '$2 == '\"${MNT}\"' {print $1}' /proc/mounts`

echo Unmount $MNT
sudo umount $MNT

if [ -n "${LOOPDEV}" ]; then
	echo Free $LOOPDEV
	sudo losetup -d $LOOPDEV
fi

if [ -d "${MNT}" ]; then
	echo Removing ${MNT}
	sudo rmdir ${MNT}
fi

