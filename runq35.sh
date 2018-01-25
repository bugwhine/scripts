#!/bin/sh
#old script, lost current one :(

#bleeding edge
OVMF=/repo/${USER}/edk2/Build/OvmfX64/DEBUG_GCC48/FV/OVMF.fd
QEMU=~/repo/qemu/x86_64-softmmu/qemu-system-x86_64
#ubuntu
QEMU=/usr/bin/qemu-system-x86_64
#OVMF=/usr/share/ovmf/OVMF.fd

CMD="${QEMU} -nographic -smp 2 -m 2G \
	-bios ${OVMF} \
	-drive file=${1},index=1,format=raw \
	-smbios type=1,product=IDAVILLE \
	-cpu Nehalem \
	-machine q35 \
	-device e1000,netdev=user.0 \
	-netdev user,id=user.0,hostfwd=tcp::5555-:22 \
	"

TTYS4=" \
	-nodefaults \
	-chardev stdio,mux=on,id=char0 \
	-mon chardev=char0,mode=readline \
	-device pci-serial,chardev=char0 \
	-chardev socket,id=chartcp,server,host=0.0.0.0,port=4000 \
	-device isa-serial,chardev=chartcp \
       "
echo $CMD
#sleep 5
$CMD

