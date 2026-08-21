# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single flake providing multi-host NixOS configs and multi-user Home-Manager configs, driven by a
central `inventory/` of hosts and users. Modules are "self-gating" (see Architecture below) rather than
imperatively imported per host/user.

**This repo must live at `~/nix-config`** on any machine using the Home-Manager modules — out-of-store
symlinks (dotfiles) are resolved relative to that fixed path (see `lib/path.nix`).

## Commands

All common operations go through `just` (see `justfile`). Run `just` with no args to list targets.

```sh
# Apply configs (defaults: host=$(hostname -s), user=$(whoami))
just os-switch [host]        # nixos-rebuild switch
just hm-switch [user] [host] # home-manager switch

# Build without applying (useful to verify a change compiles)
just os-build [host]
just hm-build [user] [host]

# Garbage collection
just os-gc
just hm-gc

# Secrets (sops-nix)
just sops-rekey              # re-encrypt all secrets after adding/removing an age key

# Arbitrary nix command with this repo's experimental features enabled
just nix <cmd>
```

Flake-wide check (same as CI, see `.github/workflows/flake-check.yml`):

```sh
nix --extra-experimental-features "nix-command flakes pipe-operators" flake check --all-systems
```

There is no separate lint/test suite beyond `nix flake check`; correctness is largely enforced by the
NixOS/Home-Manager module system's own type/option evaluation, so a `just os-build`/`hm-build` for the
affected host/user is the practical way to "test" a change.

Dev shells (nixvim/nixd wired to a specific host or user config) are available per host/user, e.g.:

```sh
nix develop .#dev-theseus            # NixOS host shell
nix develop .#dev-allenl@theseus     # Home-Manager user@host shell
nix develop .#sops                   # age/sops/ssh-to-age tools
```

Initial machine bootstrap (disko partitioning, host key generation, install) is documented in
`docs/install.md`; VM setup for local testing/building in `docs/vm_setup.md`.

## Architecture

### Inventory-driven, not imperative imports

`inventory/` (schema in `inventory/schema.nix`, data in `inventory/data.nix`) is the single source of
truth for hosts and users: kind (server/laptop), os, gpu, tags (e.g. `gui`, `impermanent`), and which
users belong to which hosts. `flake.nix` generates `nixosConfigurations` and `homeConfigurations`
entirely from `inventory.nixosHostNames` / `inventory.userHostPairs` — adding a host or user means
editing `inventory/data.nix` plus creating `host/<hostname>/` or `home/<username>/`, not touching
`flake.nix`.

`ctx.nix` builds a per-evaluation context (`{ host, user }`) from the inventory given a `hostName` (and
optional `userName`), and is passed to every host/home module as the `ctx` special arg.

### Self-gating modules

Modules under `host/_modules/` and `home/_modules/` do **not** get conditionally imported by hosts/users.
Instead, `alnLib.importRecursive` (`lib/path.nix`) unconditionally imports every `.nix` file (and
subdirectory) under `_modules` that doesn't start with `_`, and each module decides internally whether it
applies, typically via `lib.mkIf` gated on an `aln.<feature>.enable` option whose default is derived from
`ctx`. Example (`home/_modules/de/default.nix`):

```nix
options.aln.de.enable = lib.mkEnableOption "de";
config.aln.de.enable = ctx.host.is.gui;
```

Downstream modules (e.g. `home/_modules/de/niri/default.nix`) then gate their own config on
`config.aln.de.enable`. When adding a new module, follow this pattern rather than adding conditional
imports elsewhere — check `ctx.host`/`ctx.user` (tags, `is.*`, `hasTag.*`, `can.*`) to self-determine
enablement.

Files/dirs prefixed with `_` (e.g. `_stylix.nix`, `de/dms/_widget.nix`) are excluded from
`importRecursive` — used for shared helpers that shouldn't be auto-loaded as standalone modules, or for
work-in-progress/disabled files.

### Directory layout

```
host/_modules/   - self-gating NixOS modules (imported by every host)
host/<hostname>/ - per-host config (configuration.nix, disko.nix, hardware-configuration.nix, network.nix)
home/_modules/   - self-gating Home-Manager modules (imported for every user)
home/<username>/ - per-user config
inventory/       - schema + data for hosts/users/pairings (source of truth for flake outputs)
lib/             - alnLib: importRecursive, out-of-store path helpers, quadlet helpers
secrets/         - sops-nix encrypted secrets, split under host/ and user/
scripts/         - standalone imperative scripts unrelated to nix modules
docs/            - install/VM-setup/imperative-post-install notes
```

### Secrets (sops-nix)

Each host has an SSH host key generated on install; sops-nix derives an age key from it at boot to
decrypt host secrets. For each user on a NixOS host, the host also decrypts that user's password and
their personal age key into `~/.config/sops/age/key.txt`, which the user's Home-Manager sops config then
uses to decrypt user secrets. `.sops.yaml` creation rules are order-sensitive (first regex match wins) —
check existing rules there before adding a new secret path. After adding/removing an age key, run
`just sops-rekey`.

### Notable conventions

- `pkgs-unstable`, `pkgs-nur`, `pkgs-aln` are injected as extra `_module.args` (see `flake.nix`) alongside
  the default `pkgs` (nixpkgs pinned to the `nixpkgs` input) — reach for these when a package is only in
  unstable/NUR/the author's own `aln-packages` flake.
- The Firefox-based-browser modules (`home/_modules/app/browser/firefox/`) are designed to be merged into
  any Firefox-based browser's HM options (`programs.firefox`, `programs.librewolf`, `programs.glide`,
  etc.), not just `programs.firefox` — see README for details.
- `barrybenson`'s self-hosted services run as rootful Podman containers via quadlet-nix
  (`host/barrybenson/selfhosted/`), with `userns=auto`.
