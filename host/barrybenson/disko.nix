{ config, lib, pkgs, ... }:

{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          # BIOS boot partition — required for GRUB on BIOS/GPT systems
          # Not mounted; GRUB embeds its core image here
          BIOS = {
            size = "1M";
            type = "EF02";
            priority = 1;
          };

          # Separate /boot so GRUB doesn't need to read btrfs to find its own files
          boot = {
            size = "1G";
            priority = 2;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot";
            };
          };

          # Swap — sized to match your current setup
          swap = {
            size = "30G";
            priority = 3;
            content = {
              type = "swap";
            };
          };

          # Main btrfs partition — takes the remainder (~900G)
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # force overwrite
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@containers" = {
                  mountpoint = "/var/lib/containers";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
