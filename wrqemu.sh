#!/bin/sh
if [ -z "${BUILDDIR}" ]; then
	echo "Please run from bitbake shell"
	exit
fi

QEMU=${BUILDDIR}/tmp-glibc/sysroots-components/x86_64/qemu-native/usr/bin/qemu-system-x86_64

if [ -z "$1" ]; then
	KERNEL=${BUILDDIR}/tmp-glibc/deploy/images/axxiax86-64/bzImage
else
	KERNEL=$1
fi

DRIVE=${BUILDDIR}/tmp-glibc/deploy/images/axxiax86-64/wrlinux-image-snr-sim-axxiax86-64.ext4

$QEMU -kernel $KERNEL -cpu Nehalem,-kvm_pv_unhalt,-kvm_pv_eoi,-kvm_steal_time -drive file=${DRIVE},format=raw \
-nographic -m 2G --append "root=/dev/hda rw rootfstype=ext4 console=ttyS4" \
-snapshot -smp 4 -no-kvm -device e1000,netdev=user.0 -netdev user,id=user.0,hostfwd=tcp::5555-:22 \
-smbios type=1,product=IDAVILLE \
-nodefaults \
-chardev stdio,mux=on,id=char0 \
-mon chardev=char0,mode=readline \
-device pci-serial,chardev=char0
