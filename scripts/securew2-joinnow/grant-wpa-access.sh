#!/usr/bin/env sh
# Grant wpa_supplicant (which runs as its own unprivileged user) read access to the
# enrolled eduroam .p12 keys. OpenSSL writes them as 0600, so a default ACL on the
# directory doesn't help (the ACL mask ends up ---); this has to run after enrollment.

for f in "$HOME"/.joinnow/tls-client-certs/*.p12; do
  [ -e "$f" ] || continue
  setfacl -m u:wpa_supplicant:r "$f" && echo "Granted wpa_supplicant read access to $f"
done
