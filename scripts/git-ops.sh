#!/usr/bin/env bash
set -euo pipefail

# Simple Git SSH helper
# Usage: git-ops.sh <clone|push|pull|sync|status> [--repo owner/repo] [--branch main] [--dir path]

CMD=${1:-}
shift || true
BRANCH="main"
REPO=""
DIR="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2;;
    --branch) BRANCH="$2"; shift 2;;
    --dir) DIR="$2"; shift 2;;
    *) shift;;
  esac
done

clone_repo() {
  if [[ -z "$REPO" ]]; then echo "--repo required (owner/repo)"; exit 1; fi
  TARGET_DIR="${DIR:-./$(basename "$REPO")}" 
  echo "Cloning git@github.com:$REPO.git -> $TARGET_DIR"
  git clone "git@github.com:$REPO.git" "$TARGET_DIR"
  ls -la "$TARGET_DIR"
}

push_branch() {
  echo "Pushing branch ${BRANCH} to origin"
  git push origin "$BRANCH"
}

pull_branch() {
  echo "Pulling branch ${BRANCH}"
  git pull --rebase origin "$BRANCH"
}

sync_repo() {
  echo "Fetching all and pushing $BRANCH"
  git fetch --all --prune
  git push origin "$BRANCH"
}

status_repo() {
  git status --short --branch
}

case "$CMD" in
  clone) clone_repo ;; 
  push)
    push_branch ;; 
  pull)
    pull_branch ;; 
  sync)
    sync_repo ;; 
  status)
    status_repo ;; 
  *)
    echo "Usage: $0 <clone|push|pull|sync|status> [--repo owner/repo] [--branch BRANCH] [--dir PATH]"
    exit 1
    ;;
esac
