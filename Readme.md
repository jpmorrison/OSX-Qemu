Qemu/Catalina/Spice viewer

Launch.sh for [Docker-OSX](https://github.com/sickcodes/Docker-OSX) - can adapt to [Quickemu](https://github.com/wimpysworld/quickemu)

Mostly my own testing/tweaks/documentation.

## Working: 

- [multiple displays](https://github.com/jpmorrison/OSX-Qemu/issues/2) with Spice client
- Spice USB redirection (ich9-usb-ehci1)
- Audio output/microphone
- QMP port for qmp-shell/virsh  `./qmp-shell 172.17.0.3:7008`
- [Qemu Guest Agent](https://github.com/jpmorrison/OSX-Qemu/issues/6#issue-1035504816) for AppleQEMUGuestAgent/[QEMUGuestAgent](https://wiki.qemu.org/Features/GuestAgent)

## Almost working:


- Spice client folder sharing (WebDav) using [phodav](https://gitlab.gnome.org/jpmorrison/phodav). Can mount/see folder but phodav hangs/slow after a single file copy. Unusable.

## Not working:

- Sprice virtio-serial passed through for Spice viewer seamless mouse integration/clipboard
- `cat /dev/tty.com.redhat.spice.0` on guest releases focus and shows mouse activity
- spice-vdagent still needs to be ported 

## Issues

- OpenCoreBoot using virtio doesn't remember your boot disk. I should put it pack to sata
