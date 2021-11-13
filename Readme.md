Qemu/Catalina with Spice viewer remote viewer. 

Launch.sh for [Docker-OSX](https://github.com/sickcodes/Docker-OSX) - can adapt to [Quickemu](https://github.com/wimpysworld/quickemu). This setup is optimized for remote-viewer. If you want PCI/GPU passthrough look at [KVM-Opencore](https://github.com/thenickdude/KVM-Opencore). 

Mostly my own testing/tweaks/documentation.

## Working: 

- [multiple displays](https://github.com/jpmorrison/OSX-Qemu/issues/2) with Spice client
- Catalina: improved [Spice USB](https://github.com/jpmorrison/OSX-Qemu/issues/5#issue-1035464801) redirection (ich9-usb-ehci1)
- [Audio output/microphone](https://github.com/jpmorrison/OSX-Qemu/issues/4#issue-1035457873)
- Virtio-9P - with [NFS](https://github.com/jpmorrison/OSX-Qemu/issues/8#issue-1037696046) share
- [QMP port](https://github.com/jpmorrison/OSX-Qemu/issues/3#issue-1035396452) for qmp-shell/virsh  `./qmp-shell 172.17.0.3:7008`
- [Qemu Guest Agent](https://github.com/jpmorrison/OSX-Qemu/issues/6#issue-1035504816) for AppleQEMUGuestAgent/[QEMUGuestAgent](https://wiki.qemu.org/Features/GuestAgent)
- Seamless mouse: beware of unexpected display problems. https://gitlab.com/qemu-project/qemu/-/issues/723

## Almost working:

- Spice client folder sharing [WebDav](https://github.com/jpmorrison/OSX-Qemu/issues/7#issue-1035603758) using [phodav](https://gitlab.gnome.org/jpmorrison/phodav). Working-ish when built with Brew. IMO phodav is buggy and has weird build issues with glib.
- "Seamless" mouse with Spice remote-viewer works with libvirt config but not [bare-metal qemu cli](https://github.com/jpmorrison/OSX-Qemu/issues/9#issue-1051342057). Need more info. Update: working now

## Not working:

- spice-vdagent needs to be ported to MacOS - needed for ~~seamless mouse integration~~clipboard
- vdagent channel passthrough works and `cat /dev/tty.com.redhat.spice.0` on macos guest releases focus and shows mouse activity

## Issues

- Fixing boot order
- ACPI/guest sleeping/wakeup problems. 

## Acknowledgements

 [Docker-OSX](https://github.com/sickcodes/Docker-OSX) 
 
 [Quickemu](https://github.com/wimpysworld/quickemu)
 
 [OSX-KVM](https://github.com/kholia/OSX-KVM)
 
 
