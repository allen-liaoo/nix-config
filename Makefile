FLAKE = ./.\#$(HOST)
DIR := $(shell pwd)

.PHONY: help env setup disko nixos-install nixos-rebuild nix-gc flake-update flake-check

help:
	@echo "Available targets:"
	@echo "  disko           - Run disko to format and mount disks (one time use)"
	@echo "  nixos-install   - Install NixOS using the specified flake"
	@echo "  nixos-rebuild   - Rebuild the NixOS configuration"
	@echo "  nix-gc          - Collect Nix garbage"
	@echo "  flake-update    - Update flake inputs"
	@echo "  flake-check     - Check the flake for errors"

env:
	@if [ -z "$(HOST)" ]; then \
		echo "HOST is not set"; \
		exit 1; \
	fi

setup: env
	@export EDITOR=vim
	@nix-shell -p vim

disko: env
	sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake $(FLAKE)
	nixos-generate-config --no-filesystems --root /mnt --dir $(DIR)
	@lsblk

nixos-install: env
	sudo nixos-install --no-channel-copy --no-root-password --flake $(FLAKE) --root /mnt
	@ln -s $(DIR) /mnt/etc/nixos

nixos-rebuild: env
	@echo "Rebuilding NixOS configuration..."
	@sudo nixos-rebuild switch --flake $(FLAKE)
	@echo "NixOS rebuild complete."

nix-gc: env
	@echo "Collecting Nix garbage..."
	@nix-collect-garbage -d
	@echo "Garbage collection complete."

flake-update: env
	@echo "Updating flake inputs..."
	@nix flake update
	@echo "Flake update complete."

flake-check: env
	@echo "Checking flake..."
	@nix flake check
	@echo "Flake check complete."
