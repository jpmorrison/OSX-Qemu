#!/bin/bash
set -eux
sudo chown    $(id -u):$(id -g) /dev/kvm 2>/dev/null || true
sudo chown -R $(id -u):$(id -g) /dev/snd 2>/dev/null || true
RAM=half

# try: CPU=host
CPU=kvm64
SMP=8
CPUID_FLAGS="vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,+hypervisor,+pcid,+pdpe1gb,+pclmulqdq,+vmx,+rdtscp,+tsc-deadline,+ss,+ds-cpl,+dtes64,+pdcm,+xtpr,+vmx-vintr-pending,check"
AUDIO_DRIVER="spice"
EXTRA="-nographic -spice disable-ticketing=on,port=3001,streaming-video=all,disable-copy-paste=off,disable-agent-file-xfer=off -enable-kvm"


# export NFS share to guest
PUBLIC=/mnt
PUBLIC_TAG="NFS"
# NFS + root_squash + unprivileged qemu needs security_model=none otherwise use mapped-xattr
SECURITY=none
#SECURITY=mapped-xattr

sudo mount -t nfs 172.17.0.1:/export/vm /mnt


[[ "${RAM}" = max ]] && export RAM="$(("$(head -n1 /proc/meminfo | tr -dc "[:digit:]") / 1000000"))"
[[ "${RAM}" = half ]] && export RAM="$(("$(head -n1 /proc/meminfo | tr -dc "[:digit:]") / 2000000"))"
echo RAM=$RAM
sudo chown -R $(id -u):$(id -g) /dev/snd 2>/dev/null || true
exec qemu-system-x86_64 -m ${RAM:-2}000 \
-cpu ${CPU:-Penryn},${CPUID_FLAGS:-vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,+hypervisor,+pcid,+pdpe1gb,+pclmulqdq,check,}${BOOT_ARGS} \
-D /dev/null \
-machine q35,${KVM-"accel=kvm:tcg"} \
-usb -device usb-kbd -device usb-mouse \
-smp ${CPU_STRING:-${SMP:-4},cores=${CORES:-4},threads=2} \
-device isa-applesmc,osk=ourhardworkbythesewordsguardedpleasedontsteal\(c\)AppleComputerInc \
-drive if=pflash,format=raw,readonly=on,file=/home/arch/OSX-KVM/OVMF_CODE.fd \
-drive if=pflash,format=raw,file=/home/arch/OSX-KVM/OVMF_VARS-1024x768.fd \
-smbios type=2 \
-audiodev ${AUDIO_DRIVER:-alsa},id=hda -device ich9-intel-hda -device hda-duplex,audiodev=hda \
-drive id=OpenCoreBoot,if=virtio,snapshot=on,format=qcow2,file=${BOOTDISK:-/home/arch/OSX-KVM/OpenCore-Catalina/OpenCore.qcow2} \
-drive id=MacHDD,if=virtio,file=${IMAGE_PATH:-/home/arch/OSX-KVM/mac_hdd_ng.img},format=${IMAGE_FORMAT:-qcow2} \
-drive id=InstallMedia,if=virtio,file=/home/arch/OSX-KVM/BaseSystem.img,format=qcow2 \
-netdev user,id=net0,hostfwd=tcp::${INTERNAL_SSH_PORT:-10022}-:22,hostfwd=tcp::${SCREEN_SHARE_PORT:-5900}-:5900,${ADDITIONAL_PORTS} \
-device ${NETWORKING:-vmxnet3},netdev=net0,id=net0,mac=${MAC_ADDRESS:-52:54:00:09:49:17} \
-device virtio-serial-pci \
-chardev spicevmc,id=vdagent0,name=vdagent \
-device virtserialport,chardev=vdagent0,name=com.redhat.spice.0 \
-device virtio-mouse \
-device virtio-keyboard \
-qmp-pretty telnet::7008,server=on,nowait,nodelay \
-boot menu=on \
-vga std \
-device secondary-vga \
-serial none \
-fsdev local,id=fsdev0,path=${PUBLIC},security_model=$SECURITY -device virtio-9p-pci,fsdev=fsdev0,mount_tag=${PUBLIC_TAG} \
-device ich9-usb-ehci1,id=usb \
-device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on \
-device ich9-usb-uhci2,masterbus=usb.0,firstport=2 \
-device ich9-usb-uhci3,masterbus=usb.0,firstport=4 \
-chardev spicevmc,id=usbredirchardev1,name=usbredir \
-device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \
-chardev spicevmc,id=usbredirchardev2,name=usbredir \
-device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \
-chardev spicevmc,id=usbredirchardev3,name=usbredir \
-device usb-redir,chardev=usbredirchardev3,id=usbredirdev3 \
-device virtserialport,chardev=charchannel1,id=channel1,name=org.spice-space.webdav.0 \
-chardev spiceport,name=org.spice-space.webdav.0,id=charchannel1 \
-device virtserialport,chardev=charchannel2,id=channel2,name=org.spice-space.stream.0 \
-chardev spiceport,name=org.spice-space.stream.0,id=charchannel2 \
-chardev socket,path=/tmp/qga.sock,server=on,nowait,id=qga0 \
-device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0 \
-chardev socket,telnet=on,host=0.0.0.0,port=7009,server=on,nowait,nodelay,id=console0 \
-device virtconsole,chardev=console0,id=console0 \
${EXTRA:-}

