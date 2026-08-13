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

## Selecting a Profile

- Per-command: `oci <command> --profile <TENANCY_NAME>`
- Per-shell/script: `export OCI_CLI_PROFILE="<TENANCY_NAME>"` — this is the pattern used at the top of every
  per-instance wrapper script that targets a non-default tenancy (see `bastion-workflow.md`).
- Omit both to use `[DEFAULT]`.

## Permissions

Config and key files should stay private: `chmod 700 ~/.oci`, `chmod 600 ~/.oci/*.pem`, `chmod 600 ~/.oci/config`.
Never print the contents of a `.pem` private key or the full `config` file to the terminal.
