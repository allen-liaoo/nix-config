Install VM (without secure boot):
```
virt-install --name nixos \
         --connect qemu:///session \
         --ram 8192 \
         --vcpus 2 \
         --disk path=$HOME/.local/share/libvirt/images/NixOS-25.11/nixos.x86_64.qcow2,size=20 \
         --network network=default,model=virtio \
         --graphics spice \
         --boot uefi \
         --features smm.state=off \
         --noautoconsole \
         --cdrom $HOME/.local/share/libvirt/images/nixos-minimal-25.11.7346.44bae273f9f8-x86_64-linux.iso
```

To reset VM:
```
virsh destroy nixos ; virsh undefine nixos --remove-all-storage --nvram
```

Make VM console accessible in host (run in virt-viewer nixos):
```
sudo systemctl enable --start serial-getty@ttyS0.service

# Where:
# open virt-viewer console
virt-viewer nixos
```

Open console in host:
```
virsh console nixos
```

Setup:
```
git clone https://github.com/allen-liaoo/nixos-config.git ; stty rows 40 cols 181 ; export host=vm 
```

To partition disk:
```
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake ./nixos-config#${host} && lsblk
```

Install nixos:
```
sudo nixos-install --no-channel-copy --no-root-password --flake ./nixos-config#${host} --root /mnt
```

Reboot.