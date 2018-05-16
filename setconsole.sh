#!/bin/sh
IMG=$1
TTY=$2

EARLYPRINTK=$TTY
#note only ttyS0,1,2,3 can be used with earlyprintk
#otherwise use syntax
#serial=0x3098,115200
if [ -n "$3" ]
then
	EARLYPRINTK=$3
fi
PART=5
MNT=/mnt/${IMG}${PART}

SECOFFSET=`sudo fdisk -l -o Device,Start ${IMG} | awk -f part.awk -v selected=$PART`
OFFSET=$((512*$SECOFFSET))
echo Mount $IMG offset $SECOFFSET as $MNT

LOOPDEV=`sudo losetup -o $OFFSET --show -f $IMG`
sudo mkdir -p $MNT
sudo mount -o rw $LOOPDEV $MNT 

echo updating ${MNT}/startup.nsh
sudo sed -i 's/console=\S*/console='${TTY}'/' ${MNT}/startup.nsh
sudo sed -i 's/earlyprintk=\S*/earlyprintk='${EARLYPRINTK}'/' ${MNT}/startup.nsh
cat ${MNT}/startup.nsh

echo Unmount $MNT
sudo umount -d $MNT

if [ -d "${MNT}" ]; then
	echo Removing ${MNT}
	sudo rmdir ${MNT}
fi
