#!/bin/sh
IMG=$1

./umountwic.sh $IMG

echo Mount $IMG
sudo kpartx -avs $IMG 
sudo dmsetup remove /dev/mapper/loop0p6

sudo fsck -y /dev/mapper/loop0p1 
sudo fsck -y /dev/mapper/loop0p2
sudo fsck -y /dev/mapper/loop0p3
sudo fsck -y /dev/mapper/loop0p4
sudo fsck -y /dev/mapper/loop0p5
sudo fsck -y /dev/mapper/loop0p7

sudo mkdir -p /mnt/loop0p1
sudo mkdir -p /mnt/loop0p2
sudo mkdir -p /mnt/loop0p3
sudo mkdir -p /mnt/loop0p4
sudo mkdir -p /mnt/loop0p5
sudo mkdir -p /mnt/loop0p7

sudo mount -o rw /dev/mapper/loop0p1 /mnt/loop0p1/ 
sudo mount -o rw /dev/mapper/loop0p2 /mnt/loop0p2/
sudo mount -o rw /dev/mapper/loop0p3 /mnt/loop0p3/
sudo mount -o rw /dev/mapper/loop0p4 /mnt/loop0p4/
sudo mount -o rw /dev/mapper/loop0p5 /mnt/loop0p5/
sudo mount -o rw /dev/mapper/loop0p7 /mnt/loop0p7/

