# OCI Bastion SSH/SCP Workflow

This skill assumes every managed OCI compute instance is **private** (no public IP) and reachable only through an
[OCI Bastion](https://docs.oracle.com/en-us/iaas/Content/Bastion/Concepts/bastionoverview.htm) session that
port-forwards to its port 22. There is no direct `ssh <ip>` path — every connection tunnels through a bastion.

## Architecture

```
local machine --ssh (BASTION_KEY)--> OCI Bastion session (ephemeral, TTL) --tunnel--> private instance:22 --ssh (INSTANCE_KEY)-->
```

Two distinct SSH keypairs per instance:

- **Bastion key** — authorizes the ephemeral bastion session itself (its public key is passed to
  `oci bastion session create-port-forwarding --ssh-public-key-file`).
- **Instance key** — the actual OS-level key in the instance's `~/.ssh/authorized_keys`, used for the real SSH/SCP
  auth once the tunnel is up.

Both are local files, e.g. `~/.ssh/<name>-bastion` (+ `.pub`) and `~/.ssh/<name>-instance` (+ `.pub`). Generate with:

```bash
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/<name>-bastion
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/<name>-instance
```

The bastion public key only needs to be presented at session-creation time (no upload step). The instance public key
must be added to the target instance's `~/<TARGET_USER>/.ssh/authorized_keys` (via cloud-init at instance creation,
or manually once you have any other access path).

## Three Layers of Scripts

1. **Base helpers** (`scripts/download-oci`, `scripts/ssh-oci`, `scripts/upload-oci` in this skill) — generic,
   parameterized entirely by environment variables. Installed once to `~/download-oci`, `~/ssh-oci`, `~/upload-oci`.
   Never edited per-instance.
2. **Per-instance wrapper scripts** — one `ssh-<name>`, `download-<name>`, `upload-<name>` triplet per server, also
   in `~`. Each just sets the config variables below and `source`s the matching base helper. This is where
   OCIDs/IPs/key paths/profile live.
3. **Global symlinks** — each per-instance wrapper symlinked onto `$PATH` so it can be invoked from anywhere as a
   bare command (`ssh-nexus`, `download-nexus`, `upload-nexus`, ...).

## Installing the Base Helpers

Idempotent — only create files that don't already exist; never silently overwrite a base helper the user may have
customized:

```bash
for f in download-oci ssh-oci upload-oci; do
  if [ ! -f "$HOME/$f" ]; then
    cp "<skill_dir>/scripts/$f" "$HOME/$f"
    chmod +x "$HOME/$f"
  fi
done
```

## Per-Instance Wrapper: Required Variables

| Variable | Meaning | Where to find it |
|---|---|---|
| `BASTION_ID` | OCID of the OCI Bastion resource | `oci bastion bastion list -c <compartment-id>` |
| `TARGET_ID` | OCID of the target compute instance | `oci compute instance list -c <compartment-id>` |
| `TARGET_IP` | Private IP of the instance | `oci compute instance list-vnics --instance-id <TARGET_ID>` |
| `TARGET_USER` | OS login user (`ubuntu`, `opc`, ...) | Known from the image/cloud-init used |
| `BASTION_KEY` | Path to the bastion-session keypair (no `.pub`) | e.g. `$HOME/.ssh/<name>-bastion` |
| `INSTANCE_KEY` | Path to the instance OS keypair (no `.pub`) | e.g. `$HOME/.ssh/<name>-instance` |
| `MAX_RETRIES` | Retry attempts for the SSH/SCP step | Convention: `5` |
| `BACKOFF` | Initial retry backoff in seconds (doubles each retry) | Convention: `2` |
| `OCI_CLI_PROFILE` (optional) | `~/.oci/config` profile to use for the `oci` calls | Only needed for a non-`DEFAULT` tenancy — see `cli-config.md` |

## Per-Instance Wrapper Samples (redacted)

Real OCIDs, IPs, and tenancy identifiers must **never** appear verbatim in committed docs or shared output — the
values below are placeholders only. When generating a real wrapper for a user, fill these in from `oci` CLI lookups
or values the user supplies directly; do not invent OCIDs.

`~/download-<server-name>`:

```bash
#!/bin/bash

# --- CONFIGURATION ---
BASTION_ID="ocid1.bastion.oc1.<region>.<redacted>"       # OCID of your Bastion
TARGET_ID="ocid1.instance.oc1.<region>.<redacted>"       # OCID of your Private Instance
TARGET_IP="10.0.0.x"                                     # Private IP address of your instance
TARGET_USER="ubuntu"                                     # Default user (e.g. ubuntu or opc)
BASTION_KEY="$HOME/.ssh/<server-name>-bastion"            # Key for the Bastion Tunnel
INSTANCE_KEY="$HOME/.ssh/<server-name>-instance"          # Key for the Instance OS

# --- RETRY SETTINGS ---
MAX_RETRIES=5
BACKOFF=2 # Starts at 2 seconds, then doubles (2, 4, 8...)
# ---------------------

source "$HOME/download-oci" "$@"
```

`~/ssh-<server-name>`:

```bash
#!/bin/bash

# --- CONFIGURATION ---
BASTION_ID="ocid1.bastion.oc1.<region>.<redacted>"
TARGET_ID="ocid1.instance.oc1.<region>.<redacted>"
TARGET_IP="10.0.0.x"
TARGET_USER="ubuntu"
BASTION_KEY="$HOME/.ssh/<server-name>-bastion"
INSTANCE_KEY="$HOME/.ssh/<server-name>-instance"

# --- RETRY SETTINGS ---
MAX_RETRIES=5
BACKOFF=2
# ---------------------

source "$HOME/ssh-oci"
```

`~/upload-<server-name>` (non-default tenancy example, `OCI_CLI_PROFILE` set):

```bash
#!/bin/bash

# --- CONFIGURATION ---
export OCI_CLI_PROFILE="<TENANCY_PROFILE_NAME>"
BASTION_ID="ocid1.bastion.oc1.<region>.<redacted>"
TARGET_ID="ocid1.instance.oc1.<region>.<redacted>"
TARGET_IP="10.0.0.x"
TARGET_USER="ubuntu"
BASTION_KEY="$HOME/.ssh/<server-name>-bastion"
INSTANCE_KEY="$HOME/.ssh/<server-name>-instance"

# --- RETRY SETTINGS ---
MAX_RETRIES=5
BACKOFF=2
# ---------------------

source "$HOME/upload-oci" "$@"
```

`OCI_CLI_PROFILE` is only needed when the instance's bastion/tenancy isn't the `[DEFAULT]` profile in
`~/.oci/config` — omit the `export` line entirely for a default-tenancy instance.

## Symlinking Wrapper Scripts Globally

After creating (and `chmod +x`-ing) the three per-instance scripts in `$HOME`, symlink each onto a directory already
on `$PATH` so they're callable from anywhere as `ssh-<name>` / `download-<name>` / `upload-<name>`:

```bash
# Prefer a user-writable bin dir already on PATH (no sudo)
mkdir -p "$HOME/.local/bin"
for prefix in download ssh upload; do
  ln -sf "$HOME/${prefix}-<server-name>" "$HOME/.local/bin/${prefix}-<server-name>"
done
```

If `~/.local/bin` isn't on `$PATH` yet, add it (`export PATH="$HOME/.local/bin:$PATH"` in the shell rc file) instead
of falling back to a system directory. Only use `/usr/local/bin` (requires `sudo ln -sf ...`) if the user explicitly
prefers a system-wide location — that's a write to shared system state and should be confirmed first per the devops
skill's Write Confirmation Policy.

## Usage

```bash
ssh-<server-name>
download-<server-name> /var/log/app.log ./app.log
upload-<server-name> ./deploy.tar.gz /home/ubuntu/deploy.tar.gz
download-<server-name> --help   # usage banner, no bastion session created
```

Each invocation deletes any pre-existing ACTIVE bastion session for that target, opens a fresh one (10800s/3h TTL),
waits for it to go ACTIVE, then runs the real `ssh`/`scp` through it with retry/backoff for bastion key-propagation
races.

## Cleanup

Bastion sessions expire on their own after the TTL (default 10800s = 3h) and each new connection tears down prior
ACTIVE sessions for that same target automatically. Manually listing/deleting sessions
(`oci bastion session list --bastion-id ... `, `oci bastion session delete --session-id ... --force`) is available
for cleanup but `delete` is a write — confirm before running it outside the wrapper scripts' own auto-cleanup.
