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
# inside the shell:
securew2-joinnow   # enroll; runs SecureW2_JoinNow.run in an FHS env
grant-wpa-access   # let wpa_supplicant read the enrolled key
```

`securew2-joinnow`: follow the prompts: OSU username (`lastname.#`), password, then approve
the Duo push in your browser. It then creates the eduroam profile; check with
`nmcli connection show | grep eduroam` (the tool may name it e.g. `eduroam [db6d8fe3]`).

`grant-wpa-access`: grants `wpa_supplicant` read access (ACL) to the enrolled
`~/.joinnow/tls-client-certs/*.p12` keys. They're written as `0600`, and wpa_supplicant runs
as its own unprivileged user, so without this EAP-TLS fails with
`Failed to load private key ... Permission denied` (and the tool reports the network as
"not in range"). Run it after enrolling, then reconnect. A default ACL on the directory
can't replace this step: the `0600` create mode masks it out. It also can't run inside the
FHS env, whose user namespace doesn't map wpa_supplicant's uid.

Don't delete `~/.joinnow` itself (deleting files inside it is fine). wpa_supplicant sees it
through a bind mount set up when the service starts. If the
directory is recreated, the mount still points at the old, deleted one, and every new
cert/key fails with `No such file or directory`. If that happens, run
`sudo systemctl restart wpa_supplicant`.
