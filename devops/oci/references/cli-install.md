# OCI CLI — Installation

Vendored from the [oracle/oci-cli](https://github.com/oracle/oci-cli) README and the
[Oracle Cloud Infrastructure CLI install docs](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
(dual UPL 1.0 / Apache 2.0 license — see `../LICENSE`).

## Quick Install

```bash
# macOS (Homebrew)
brew install oci-cli

# Linux (quick-install script, recommended)
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

# Oracle Linux 7 (yum)
sudo yum install python36-oci-cli

# Fedora (dnf)
sudo dnf install oci-cli

# Windows (PowerShell)
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.ps1'))"
```

## Offline Install

1. Go to the [oci-cli releases page](https://github.com/oracle/oci-cli/releases) and download the zip matching your OS.
2. Unzip it.
3. Run the bundled installer with the offline flag:
   ```bash
   bash install.sh --offline-install       # Linux/macOS
   install.ps1 -OfflineInstall             # Windows
   ```

## Verify

```bash
oci --version
oci setup config --help
```

Follow the devops skill's **Installation Cleanup Policy** (`../../SKILL.md`) after a successful install: remove any
downloaded installer script/zip/extracted directory used to install manually. Never remove `~/.oci/`, its keys, or the
installed `oci` binary itself.

## Also Required: `jq`

The bastion helper scripts (`../scripts/download-oci`, `ssh-oci`, `upload-oci`) parse `oci` CLI JSON output with `jq`.
Install it alongside the CLI if missing (`apt install jq` / `brew install jq` / `dnf install jq`).
