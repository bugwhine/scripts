#!/bin/sh
IMG=$1

echo Clean up old mounts for $IMG
sudo umount /mnt/loop0p1
sudo umount /mnt/loop0p2
sudo umount /mnt/loop0p3
sudo umount /mnt/loop0p4
sudo umount /mnt/loop0p5
sudo umount /mnt/loop0p7
sudo kpartx -d $IMG
