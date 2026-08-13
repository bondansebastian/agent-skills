# OCI CLI — Configuration & Multi-Profile Setup

Vendored/summarized from [Oracle's SDK & CLI configuration docs](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm)
and [CLI install docs](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) (dual UPL 1.0 / Apache 2.0 — see `../LICENSE`).

## Config File

- Location: `~/.oci/config` (Linux/macOS/Git Bash on Windows), `C:\Users\<user>\.oci\config` (Windows PowerShell).
- INI-style, one `[PROFILE_NAME]` block per tenancy/user identity. A `[DEFAULT]` block is used when no `--profile` /
  `OCI_CLI_PROFILE` is given. Undeclared keys in a named profile fall back to `[DEFAULT]`.

```ini
[DEFAULT]
user=ocid1.user.oc1..<unique_ID>
fingerprint=<key_fingerprint>
key_file=~/.oci/oci_api_key.pem
tenancy=ocid1.tenancy.oc1..<unique_ID>
region=us-ashburn-1

[MY_OTHER_TENANCY]
user=ocid1.user.oc1..<different_unique_ID>
fingerprint=<other_key_fingerprint>
key_file=~/.oci/my_other_tenancy_api_key.pem
tenancy=ocid1.tenancy.oc1..<other_unique_ID>
region=ap-batam-1
```

| Field | Required | Notes |
|---|---|---|
| `user` | Yes | OCID of the IAM user calling the API |
| `fingerprint` | Yes | Fingerprint of the uploaded public key |
| `key_file` | Yes | Path to the local **private** key (PEM) |
| `tenancy` | Yes | OCID of the tenancy |
| `region` | Yes | e.g. `us-ashburn-1`, `ap-batam-1` |
| `pass_phrase` | Only if key is encrypted | Passphrase for the private key |
| `security_token_file` | Only for session-token auth | Path to a session token file |

## Guided Setup (single profile)

```bash
oci setup config
```

Prompts for the user OCID, tenancy OCID, and region; offers to generate a new RSA API signing keypair (default
`~/.oci/oci_api_key.pem` + `oci_api_key_public.pem`) and writes `~/.oci/config`. After it finishes, **upload the
generated public key** in the OCI Console: profile icon → **User Settings** → **API Keys** → **Add API Key**, or hand
the `.pem` public key to whoever administers that tenancy.

## Multiple Tenancies / Profiles (this skill's convention)

Each OCI tenancy the user works with gets its own **profile block** in `~/.oci/config` and its own API signing
keypair. Naming convention observed in this workspace: `~/.oci/<tenancy>_api_key.pem` /
`~/.oci/<tenancy>_api_key_public.pem`, with a matching `[<TENANCY_NAME>]` profile block. Example directory listing
(sensitive values redacted — do not print real fingerprints/OCIDs when documenting a user's actual setup):

```
ls -al ~/.oci/
total 44
drwx------  2 user user 4096 <date>  .
drwxr-xr-x 44 user user 4096 <date>  ..
-rw-------  1 user user 1237 <date>  config
-rw-------  1 user user 1715 <date>  <tenancy_a>_api_key.pem
-rw-------  1 user user  451 <date>  <tenancy_a>_api_key_public.pem
-rw-------  1 user user 1715 <date>  oci_api_key.pem              # DEFAULT profile
-rw-------  1 user user  451 <date>  oci_api_key_public.pem
-rw-------  1 user user 1691 <date>  <tenancy_b>_api_key.pem
-rw-r--r--  1 user user  451 <date>  <tenancy_b>_api_key_public.pem
```

To add a new tenancy profile:

1. `mkdir -p ~/.oci && ssh-keygen -t rsa -b 2048 -N "" -m PEM -f ~/.oci/<tenancy>_api_key.pem` (private/public key pair
   for API signing — do **not** reuse an SSH bastion/instance key for this).
2. `chmod 600 ~/.oci/<tenancy>_api_key.pem`
3. Have the user upload `~/.oci/<tenancy>_api_key.pem.pub`'s contents in that tenancy's OCI Console under **User
   Settings → API Keys**. The console shows the resulting fingerprint after upload — the user must copy it back.
4. Append a `[<TENANCY_NAME>]` block to `~/.oci/config` with that tenancy's `user`, `fingerprint`, `key_file`,
   `tenancy`, and `region`.
5. Verify: `oci iam region list --profile <TENANCY_NAME>` (or `OCI_CLI_PROFILE=<TENANCY_NAME> oci iam region list`).

## Rotating an API Key

Full step-by-step for replacing a profile's API signing key end-to-end without ever reading or printing
`~/.oci/config`, a `.pem` private key, or a `.pub`/public key file's contents — consistent with this skill's
Credential Handling Policy (`../../SKILL.md`). Referenced from the summary in `../SKILL.md`'s Authentication section.

Read steps (3, 4, 7) run directly. Write steps (1, 2, 5, 6, 8, 9) require explicit user confirmation first, stated
with the exact command and its impact, per the devops skill's Write Confirmation Policy.

### 1. Generate the new keypair (write — confirm first)

```bash
ssh-keygen -t rsa -b 2048 -N "" -m PEM -f ~/.oci/<name>_api_key_new.pem
chmod 600 ~/.oci/<name>_api_key_new.pem
```

Use a `_new` suffix so the old and new key files coexist on disk until the rotation is verified and the old key is
deleted (step 9). Never overwrite the currently-active key file in place.

### 2. Convert the public key to the format OCI actually requires

`ssh-keygen` writes `~/.oci/<name>_api_key_new.pem.pub` in **OpenSSH** format (`ssh-rsa AAAA...`). OCI's
`iam user api-key upload` needs **PEM/X.509 SubjectPublicKeyInfo** format instead. Uploading the OpenSSH-format
`.pub` file fails with:

```
IdcsConversionError: Invalid public key header or footer.
```

Fix — derive the PEM-format public key directly from the private key with `openssl` (this does not need the
OpenSSH `.pub` file at all):

```bash
openssl rsa -pubout -in ~/.oci/<name>_api_key_new.pem -out ~/.oci/<name>_api_key_new_public.pem
```

This reads the private key file on disk to derive the public key mathematically — it does not display the private
key's contents to the user or the conversation, so it doesn't violate the Credential Handling Policy. Use
`<name>_api_key_new_public.pem` (not the OpenSSH `.pub` sibling) for the upload in step 5.

### 3. Look up the target user's OCID (read-only)

The tenancy/user OCID can't be pulled from `~/.oci/config` — that file is off-limits to read. Ask the user for the
tenancy OCID if it isn't already known, then list users in the tenancy (the tenancy OCID doubles as the root
compartment ID):

```bash
oci iam user list --compartment-id <tenancy-ocid> --profile <name>
```

Match on the `name`/`email` field to find the target user's `id` (OCID).

### 4. Record the current active key's fingerprint (read-only)

```bash
oci iam user api-key list --user-id <ocid> --profile <name>
```

Keep the fingerprint(s) returned here — this is the record of what's being replaced, needed for step 8.

### 5. Upload the new public key (write — confirm first)

```bash
oci iam user api-key upload --user-id <ocid> --key-file ~/.oci/<name>_api_key_new_public.pem --profile <name>
```

The returned fingerprint is **not sensitive** — it's a public key digest, not a secret — and must be shown to the
user, since it's needed for both step 6 (config update) and eventually for auditing which key is active.

### 6. Update `~/.oci/config`'s `key_file` and `fingerprint`

The skill must not read or edit that file directly by dumping its contents. Two options:

**Option (a) — user makes the edit themselves.** Tell the user exactly which two lines to change in the
`[<name>]` (or `[DEFAULT]`) block:

```
key_file=~/.oci/<name>_api_key_new.pem
fingerprint=<fingerprint from step 5>
```

Ask the user to report back just those two changed line *values* (not the surrounding file) so any mismatch — e.g.
a leftover old fingerprint — can be diagnosed without ever seeing the rest of the file.

**Option (b) — non-reading in-place patch.** Run `scripts/rotate-oci-config.py` (in this skill, at
`<skill_dir>/scripts/rotate-oci-config.py`), a small `configparser`-based script that updates only `key_file` and
`fingerprint` for the given profile, backs up the original file first, and never prints file contents (only the
two new values it just set, which are safe to display — a path and a public fingerprint):

```bash
python3 <skill_dir>/scripts/rotate-oci-config.py --profile <name> \
  --key-file ~/.oci/<name>_api_key_new.pem \
  --fingerprint "<fingerprint from step 5>"
```

Either way, this is a write to `~/.oci/config` — confirm before running/asking for it, stating that it changes
which key the CLI authenticates with for that profile.

**Common failure mode:** updating `key_file` but forgetting to update `fingerprint` alongside it (or vice versa)
leaves the profile pointing at a key/fingerprint pair that don't match, which produces:

```
NotAuthenticated: Failed to verify the HTTP(S) Signature
```

### 7. Verify the new key works (read-only)

```bash
oci iam region list --profile <name>
```

Run this **before** touching the old key. A successful response confirms the new key authenticates; if it fails,
fix the config (step 6) rather than proceeding to delete the old key.

### 8. Delete the old key from OCI (write — confirm first, irreversible)

```bash
oci iam user api-key delete --user-id <ocid> --fingerprint <old-fingerprint from step 4> --profile <name> --force
```

State plainly that this is **irreversible** — once deleted, that key can never authenticate again. Ask the user to
confirm nothing else (other machines, CI pipelines, teammates) relies on that specific key before running it. This
step only makes sense after step 7 has already confirmed the new key works.

### 9. Clean up local key material (write — confirm first)

Only after the old key is confirmed deleted from OCI (step 8), remove the old local key files and any leftover
intermediate byproducts — e.g. the rejected OpenSSH-format `.pub` from step 2 if it wasn't already discarded. List
the exact file paths for user confirmation before `rm`, since local deletion is also irreversible:

```
~/.oci/<name>_api_key.pem              # old private key
~/.oci/<name>_api_key_public.pem       # old public key
~/.oci/<name>_api_key.pem.pub          # OpenSSH-format sibling, if present (never uploaded)
```

Optionally rename the `_new` files to drop the suffix once the old ones are gone, to keep the naming convention in
[Multiple Tenancies / Profiles](#multiple-tenancies--profiles-this-skills-convention) intact for future rotations —
this is itself a write (renaming files) and should be confirmed like any other.

## Selecting a Profile

- Per-command: `oci <command> --profile <TENANCY_NAME>`
- Per-shell/script: `export OCI_CLI_PROFILE="<TENANCY_NAME>"` — this is the pattern used at the top of every
  per-instance wrapper script that targets a non-default tenancy (see `bastion-workflow.md`).
- Omit both to use `[DEFAULT]`.

## Permissions

Config and key files should stay private: `chmod 700 ~/.oci`, `chmod 600 ~/.oci/*.pem`, `chmod 600 ~/.oci/config`.
Never print the contents of a `.pem` private key or the full `config` file to the terminal.
