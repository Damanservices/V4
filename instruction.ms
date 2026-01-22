# SSH & Git Remote Management 🛠️

**Purpose:** Manage SSH key pairs for Owner and Contributor accounts (extract existing keys or create new ones), set permissions, optionally upload public keys to GitHub, and provide npm scripts to automate push/pull/clone/sync actions.

---

## Quick Setup ✅

1. Install recommended CLI tools (optional but helpful):
   - Git
   - gh (GitHub CLI) — optional for uploading SSH keys programmatically

2. Add the files from this repo to your workspace. Then run:

```bash
# Ensure Owner key exists (creates if not, prints public key to stdout and saves to ./keys)
npm run ssh:ensure-owner -- --yes

# Ensure Contributor key exists
npm run ssh:ensure-contributor -- --yes
```

3. To upload a key to GitHub (requires `gh` and auth):

```bash
npm run ssh:upload-owner -- --title "owner-laptop"
```

4. Use Git helper scripts:

```bash
# Clone using SSH (pass repo like owner/repo)
npm run git:clone -- --repo owner/repo

# Push current branch
npm run git:push -- --branch main

# Pull latest
npm run git:pull -- --branch main

# Sync (fetch & push)
npm run git:sync -- --branch main

# Status
npm run git:status
```

---

## Files created by this tool 🔧

- `scripts/ssh-manage.sh` — generate/extract keys, set permissions, optionally upload to GitHub using `gh`.
- `scripts/git-ops.sh` — helper to clone, push, pull, sync, and status using SSH remotes.
- `package.json` — exposes npm scripts for automation.
- `.gitignore` — ignores generated `keys/` directory.

---

## Security & Notes ⚠️

- Generated keys are stored locally in `~/.ssh` and public copies are saved to `./keys/` (this repo ignores that folder by default).
- Never commit private keys to any repository.
- Uploading a public key to GitHub does NOT grant it arbitrary repo access unless the associated GitHub account has permissions to the repo; manage access in GitHub org/team settings.
- If you prefer server-side remote management (e.g., adding to `/home/user/.ssh/authorized_keys` on a server), copy the public key there manually or via secure copy.

---

## Environment variables (optional)

- `GITHUB_TOKEN` — used by `gh` when authenticating non-interactively.
- `GITHUB_USER` — target GitHub username when using API or `gh`.

---

## Troubleshooting 💡

- If `gh` is not installed, uploading will print the public key and instructions to add it via GitHub UI.
- If your ssh-agent isn't running, the script will start it and add the key (requires passphrase-less or use the OS keychain).

---

If you want, I can also add automated workflows (GitHub Actions) or a more advanced Node.js helper to manage keys via the GitHub API.
