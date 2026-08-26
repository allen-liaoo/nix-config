# securew2-joinnow

Runs Ohio State's `SecureW2_JoinNow.run` enrollment client for eduroam. This is a Python
enrollment tool (not a GUI installer) that opens your browser for OSU SSO + Duo, requests
a signed TLS client cert from SecureW2, writes it to `~/.joinnow/tls-client-certs/`, and
then talks directly to system NetworkManager over D-Bus to create/replace the `eduroam`
wifi connection profile.

It requires an internet connection to authenticate (any connection works — you don't need
to already be on eduroam), and a graphical session (opens your default browser, may show a
D-Bus/polkit prompt to authorize the NetworkManager connection change).

Deliberately **not** managed via `ensureProfiles` in `host/<host>/network.nix`: the tool
deletes and recreates the `eduroam` connection every run, which would fight a
nix-declared profile. Re-run this by hand whenever the cert expires (roughly annual) or
`eduroam` stops connecting.

## Usage

```sh
nix-shell scripts/securew2-joinnow/shell.nix
# inside the FHS shell:
./SecureW2_JoinNow.run
```

Follow the prompts: OSU username (`lastname.#`), password, then approve the Duo push in
your browser. On success it connects to `eduroam` directly; check with
`nmcli connection show eduroam`.
