git_repo := "https://github.com/allen-liaoo/nixos-config.git"
host_key_path := env_var_or_default("HOST_KEY_PATH", "/etc/ssh/ssh_host_ed25519_key")
nix_flags := "--extra-experimental-features 'nix-command flakes'"

dir := justfile_directory()

# Default target — list all targets
[private]
default:
    @just --list

# Rebuild the NixOS config
[group("update")]
os-switch hostname:
    sudo nixos-rebuild switch --flake "{{dir}}#{{hostname}}"

# Rebuild a Home Manager config
[group("update")]
home-switch hostname user:
    home-manager switch --flake "{{dir}}#{{user}}@{{hostname}}"

# Rebuild all Home Manager configs for host
[group("update")]
home-switch-all hostname:
    nix {{nix_flags}} eval .#homeConfigurations --apply 'builtins.attrNames' --json \
        | tr -d '[]"' | tr ',' '\n' \
        | grep '@{{hostname}}$' \
        | sed 's/@{{hostname}}$//' \
        | xargs -I{} just home-switch {{hostname}} {}

# Rebuild both NixOS and HomeManager configs
switch-all hostname:
    just os-switch {{hostname}}
    just home-switch-all {{hostname}}

# Update flake inputs
[group("update")]
flake-update:
    nix {{nix_flags}} flake update

# Check the flake for errors
flake-check:
    nix {{nix_flags}} flake check

# Collect Nix garbage
gc:
    sudo nix-collect-garbage -d

# Initial targets

# Run disko to format and mount disks
[group("initial")]
disko hostname:
    sudo nix {{nix_flags}} run github:nix-community/disko/latest -- \
        --mode destroy,format,mount \
        --flake "{{dir}}#{{hostname}}"
    @lsblk

# Install NixOS using the specified hostname
[group("initial")]
os-install hostname:
    sudo nixos-install --no-channel-copy --no-root-password \
        --flake "{{dir}}#{{hostname}}" \
        --root /mnt
    @echo "NixOS installed. Please reboot, clone repository, and run 'just os-setup' to use new configuration."

# Link config and generate hardware-configuration.nix (after install and reboot)
[group("initial")]
os-setup:
    @echo "Linking {{dir}} to /etc/nixos..."
    sudo ln -s {{dir}} /etc/nixos
    @echo "Adding hardware-configuration.nix... remember to commit it"
    sudo nixos-generate-config --no-filesystems --root /mnt --dir {{dir}}
    just switch {{hostname}} {{user}}

# Generate host age key for .sops.yaml (based on ssh host public key)
[group("initial")]
gen-host-key:
    nix-shell -p ssh-to-age --run 'cat {{host_key_path}}.pub | ssh-to-age'
    @echo "Add the above output to .sops.yaml under 'keys' > '&hosts'."
