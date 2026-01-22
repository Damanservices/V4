#!/usr/bin/env bash
set -euo pipefail

# Simple SSH key manager
# Usage: ssh-manage.sh <ensure|export|create|upload> <owner|contributor> [--name filename] [--yes] [--title key-title]

CMD=${1:-}
ROLE=${2:-}
shift 2 || true

SSH_DIR="$HOME/.ssh"
OUT_DIR="$(pwd)/keys"
mkdir -p "$OUT_DIR"

confirm() {
  if [[ "${*}" == *"--yes"* ]]; then
    return 0
  fi
  read -rp "$1 [y/N]: " yn
  [[ "$yn" =~ ^[Yy]$ ]]
}

find_key_pair() {
  # Look for common key files
  candidates=("$SSH_DIR/id_ed25519" "$SSH_DIR/id_rsa" "$SSH_DIR/id_ecdsa")
  for c in "${candidates[@]}"; do
    if [[ -f "$c" ]]; then
      echo "$c"
      return 0
    fi
  done
  return 1
}

generate_key() {
  local name="$1"
  local keypath="$SSH_DIR/$name"
  echo "Generating new ed25519 key -> $keypath"
  ssh-keygen -t ed25519 -f "$keypath" -N "" -q -C "$name@$(hostname)"
  chmod 600 "$keypath"
  chmod 644 "$keypath.pub"
  echo "$keypath"
}

save_pub_copy() {
  local pub="$1"
  local role="$2"
  cp "$pub" "$OUT_DIR/$role.pub"
  echo "Saved public key copy: $OUT_DIR/$role.pub"
}

upload_to_github() {
  local pub="$1"
  local title="$2"
  if ! command -v gh &>/dev/null; then
    echo "gh CLI not found. Install it or copy the key manually."
    echo "Public key content:\n" && cat "$pub"
    return 1
  fi
  echo "Uploading $pub to GitHub as title '$title'"
  gh ssh-key add "$pub" --title "$title"
}

case "$CMD" in
  ensure)
    if [[ -z "$ROLE" ]]; then echo "Role required: owner|contributor"; exit 1; fi
    # Try to find existing key
    EX=$(find_key_pair || true)
    if [[ -n "$EX" ]]; then
      echo "Found existing key: $EX"
      save_pub_copy "$EX.pub" "$ROLE"
      echo "Fingerprint:" && ssh-keygen -lf "$EX.pub"
      exit 0
    fi
    if confirm "No key found. Create a new key for $ROLE?" "$@"; then
      KEYNAME="id_ed25519_$ROLE"
      NEWKEY=$(generate_key "$KEYNAME")
      save_pub_copy "$NEWKEY.pub" "$ROLE"
      echo "Fingerprint:" && ssh-keygen -lf "$NEWKEY.pub"
    else
      echo "Aborted."
      exit 2
    fi
    ;;
  upload)
    if [[ -z "$ROLE" ]]; then echo "Role required: owner|contributor"; exit 1; fi
    TITLE="${3:-$ROLE-$(hostname)}"
    PUBFILE="$OUT_DIR/$ROLE.pub"
    if [[ ! -f "$PUBFILE" ]]; then
      echo "No public key copy found for $ROLE. Use 'ensure' first."; exit 1
    fi
    if confirm "Upload $PUBFILE to GitHub?" "$@"; then
      upload_to_github "$PUBFILE" "$TITLE"
    else
      echo "Aborted upload. Public key content:" && cat "$PUBFILE"
      exit 2
    fi
    ;;
  export)
    # print the public key
    PUB=$(find_key_pair || true)
    if [[ -n "$PUB" ]]; then
      cat "$PUB.pub"
      exit 0
    fi
    echo "No key found."; exit 1
    ;;
  create)
    if [[ -z "$ROLE" ]]; then echo "Role required: owner|contributor"; exit 1; fi
    KEYNAME="id_ed25519_$ROLE"
    if [[ -f "$SSH_DIR/$KEYNAME" ]]; then
      echo "Key already exists: $SSH_DIR/$KEYNAME"; exit 1
    fi
    NEWKEY=$(generate_key "$KEYNAME")
    save_pub_copy "$NEWKEY.pub" "$ROLE"
    ;;
  *)
    echo "Usage: $0 <ensure|create|upload|export> <owner|contributor> [--yes] [--title title]"
    exit 1
    ;;
esac
