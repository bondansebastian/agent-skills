---
name: devops-oci
description: Use when the user wants to manage Oracle Cloud Infrastructure (OCI) — querying compartments/compute instances/networking via the `oci` CLI, or connecting to a private OCI compute instance (no public IP) over SSH/SCP through an OCI Bastion tunnel. Triggers on "OCI", "Oracle Cloud", "oci cli", "oci bastion", or requests to ssh/upload/download to/from a private OCI instance.
version: 1.2.0
license: UPL-1.0 OR Apache-2.0
---

# OCI (Oracle Cloud Infrastructure)

Natural-language interface to the [OCI CLI](https://github.com/oracle/oci-cli) (`oci`), plus an opinionated
bastion-tunnel workflow for reaching OCI compute instances. Docs vendored from `oracle/oci-cli` and Oracle's public
CLI docs (dual UPL 1.0 / Apache 2.0 license — see `LICENSE`) so install/config guidance works standalone.

**Opinionated assumption:** every OCI compute instance this skill manages is **private** — no public IP — and is
only reachable via an OCI Bastion port-forwarding session. There is no "just ssh the IP" path here.

**Why:** this is a deliberate security posture, not a technical limitation. A private instance with no public IP has
no direct internet-facing SSH port to scan, brute-force, or leave accidentally open — the only entry point is a
bastion, which itself grants exclusively short-lived (TTL-bound, default 10800s here), single-purpose,
IAM-authorized, audited sessions, using a keypair that is separate from the instance's own OS key. Compromise of the
bastion key alone doesn't grant OS access, and every session is logged and expires on its own. This is materially
safer than a permanently open SSH port on a public IP, even one locked down by security-list/NSG rules.

**Always confirm before applying this convention.** Before creating any bastion resource, generating keypairs, or
writing the wrapper scripts described below, ask the user explicitly whether they want to follow this private
+ bastion convention or use their own existing setup (a public IP with security-list restrictions, a different
tunnel/VPN tool, an existing bastion already configured differently, etc.). If they already have working access to
an instance through some other means, don't impose this convention on top of it — adapt to what they have instead.
Only proceed with the workflow below once the user has confirmed it's what they want.

## Setup Check

**Run this first:**

```bash
oci --version
```

- If `oci` is missing, install it per `references/cli-install.md` (pick the right method for the OS). `jq` is also
  required by the bastion helper scripts — install it too if missing.
- After a successful install, follow the devops skill's **Installation Cleanup Policy** (`../SKILL.md`): remove
  leftover installer scripts/archives/extracted dirs. Never remove `~/.oci/`, its keys, or the `oci` binary.
- If `~/.oci/config` doesn't exist or has no usable profile, walk the user through **Authentication** below.

## Authentication (API Key Setup)

1. `mkdir -p ~/.oci && ssh-keygen -t rsa -b 2048 -N "" -m PEM -f ~/.oci/<tenancy>_api_key.pem` — generate an API
   signing keypair (separate from any SSH bastion/instance key).
2. `chmod 600 ~/.oci/<tenancy>_api_key.pem`
3. Have the user upload the `.pub` key's contents in the OCI Console: **User Settings → API Keys → Add API Key**
   for that tenancy, and copy back the fingerprint the console shows.
4. Add a `[<TENANCY_NAME>]` block to `~/.oci/config` with `user`, `fingerprint`, `key_file`, `tenancy`, `region`
   (or run the guided `oci setup config` for a single/default profile).
5. Verify: `oci iam region list --profile <TENANCY_NAME>` (or `OCI_CLI_PROFILE=<TENANCY_NAME>`).

This workspace supports **multiple tenancies/profiles** side by side in one `~/.oci/config` — each with its own
keypair and `[PROFILE_NAME]` block. Full walkthrough, config file format, and a redacted example `~/.oci/` layout:
**`references/cli-config.md`**.

## Operating Rules

- Prefer `--output json` (via `--all` / default) for scripting; use table-friendly commands only when the user is
  reading directly.
- Use **OCIDs**, never made-up or guessed identifiers, for `--compartment-id`, `--instance-id`, `--bastion-id`, etc.
  Look them up with a `list` call first if not already known.
- Select non-default tenancies with `--profile <name>` per command, or `export OCI_CLI_PROFILE="<name>"` for a
  whole session/script — never hardcode a tenancy's profile name as if it were universal.
- Follows the devops skill's **Credential Handling Policy** (`../SKILL.md`): never ask the user to paste an API
  token/key into the conversation, and never read or print the contents of a `.pem` private key, `~/.oci/config`,
  or a bastion/instance private key. Point the user to **Authentication** above and the OCI Console instead.

## Private-Instance Access (Bastion SSH/SCP)

Full architecture, keypair model, and per-instance script templates: **`references/bastion-workflow.md`**. Summary:

0. **Confirm the convention first:** ask whether the user wants this private-instance-plus-bastion setup (the
   security rationale above) or already has/prefers their own access method. Do not skip straight to step 1 on an
   implicit "go ahead" — this decides how every instance in the tenancy gets reached going forward.
1. **One-time setup:** ensure the three base helper scripts exist in `$HOME` — `download-oci`, `ssh-oci`,
   `upload-oci` — copying them from this skill's `scripts/` directory if missing (never overwrite existing ones).
   Creating files in the user's home directory is a write to their filesystem — confirm before copying.
2. **Per server:** gather `BASTION_ID`, `TARGET_ID`, `TARGET_IP`, `TARGET_USER`, generate a bastion keypair and an
   instance keypair under `~/.ssh/`, then create `~/download-<name>`, `~/ssh-<name>`, `~/upload-<name>` — each just
   sets those variables (plus `OCI_CLI_PROFILE` if the tenancy isn't `DEFAULT`) and `source`s the matching base
   helper. Confirm with the user before writing these files and before generating new SSH keypairs.
3. **Make it global:** symlink each per-instance script onto a directory on `$PATH` (prefer `~/.local/bin`, no
   `sudo`) so `ssh-<name>` / `download-<name>` / `upload-<name>` work from anywhere.
4. **Use it:** `ssh-<name>`, `download-<name> <remote> <local>`, `upload-<name> <local> <remote>`. Each call tears
   down any stale bastion session for that target, opens a fresh one, and retries through bastion key-propagation
   races automatically — running these as normal connection commands does not require write confirmation (it's
   equivalent to a plain `ssh`), but generating keys, writing wrapper scripts, and creating symlinks are one-time
   filesystem writes that do.

## Quick Reference

| Task | Command |
|---|---|
| Verify CLI / list regions | `oci --version` / `oci iam region list` |
| List compartments | `oci iam compartment list --all` |
| List / get compute instances | `oci compute instance list -c <compartment-id>` / `oci compute instance get --instance-id <id>` |
| Get instance's private IP | `oci compute instance list-vnics --instance-id <id>` |
| List bastions | `oci bastion bastion list -c <compartment-id>` |
| List / get / delete bastion sessions | `oci bastion session list --bastion-id <id> --all` / `get --session-id <id>` / `delete --session-id <id> --force` |
| Create bastion port-forwarding session | `oci bastion session create-port-forwarding --bastion-id <id> --target-resource-id <id> --target-port 22 --ssh-public-key-file <key>.pub --session-ttl 10800` |
| List VCNs / subnets | `oci network vcn list -c <compartment-id>` / `oci network subnet list -c <compartment-id> --vcn-id <id>` |
| Start / stop / reboot an instance | `oci compute instance action --instance-id <id> --action START\|STOP\|SOFTRESET` |

Global flags on every command: `--profile <name>` (or `OCI_CLI_PROFILE` env var), `--region <region>`, `--output json\|table`, `--debug`.

Full quick-start references: `references/cli-install.md`, `references/cli-config.md`, `references/bastion-workflow.md`.

## Safety

This platform follows the devops skill's **Write Confirmation Policy** (see top-level `../SKILL.md`): read
operations run directly, every write operation requires explicit user confirmation first, stated with the exact
command, what it does, and its impact.

**Read (no confirmation):** `iam region list`, `iam compartment list`, `compute instance list/get`,
`compute instance list-vnics`, `bastion bastion list/get`, `bastion session list/get`, `network vcn/subnet list`,
`oci setup config --help`, connecting via the `ssh-<name>`/`download-<name>`/`upload-<name>` wrapper scripts
(equivalent to a normal `ssh`/`scp` call — the bastion session churn they perform is incidental plumbing, not a
user-directed infrastructure change).

**Write (always confirm first):** `compute instance action` (`START`/`STOP`/`SOFTRESET`/`RESET`/`TERMINATE` — via
`oci compute instance terminate`), `bastion session delete` run manually (outside the wrapper scripts' own
auto-cleanup), `bastion bastion create/delete`, `iam` mutations (`user create`, `policy create`, API key
add/delete), any `create`/`update`/`delete`/`launch`/`terminate`/`action` subcommand, generating a new SSH/API
keypair, writing/overwriting a wrapper script or base helper in `$HOME`, and creating a system-wide symlink
(`/usr/local/bin`, requires `sudo`).

For every write, state the impact specific to the action, e.g.:
- `compute instance action ... TERMINATE` — destroys the instance and its boot volume (unless preserved), **not
  reversible**.
- `compute instance action ... STOP`/`SOFTRESET` — causes downtime for that instance until it's back up.
- `bastion session delete` — ends an active tunnel; any in-flight `ssh`/`scp` through it will drop.
- Generating a new keypair under `~/.ssh/` or `~/.oci/` — creates new key material; if it overwrites an existing
  file with the same name, the old key stops working for anything still relying on it.
- Writing `~/<prefix>-<name>` wrapper scripts or symlinks — adds new global commands / files to the user's `$PATH`
  and home directory.

Additional rules:
- Fetch current state (`list`/`get`) before mutating — don't assume an instance's state, OCID, or IP.
- If a command's read/write status is unclear, treat it as a write and confirm.

## Deep Dive

**Load `references/cli-install.md`** for install-method details and the offline-install path.

**Load `references/cli-config.md`** when setting up a new tenancy profile, troubleshooting auth, or explaining the
`~/.oci/config` file to the user.

**Load `references/bastion-workflow.md`** before creating any new per-instance `ssh-<name>`/`download-<name>`/
`upload-<name>` script triplet, or when the user asks how the bastion tunnel works.

Do NOT load any reference for simple `list`/`get` calls on resources the user already has OCIDs for — the Quick
Reference above is sufficient.
