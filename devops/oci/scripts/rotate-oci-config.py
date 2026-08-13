#!/usr/bin/env python3
"""Patch key_file/fingerprint for one profile in ~/.oci/config during API key rotation.

Never prints the file's contents (other profiles, existing key_file/fingerprint
values, or any other field) to stdout/stderr — only confirms which two values
were set to the new values it was given. Backs up the original file before
writing so the patch is reversible if a value is wrong.

Usage:
    rotate-oci-config.py --profile <NAME> --key-file <path> --fingerprint <fp> [--config ~/.oci/config]
"""

import argparse
import configparser
import os
import shutil
import sys
import time


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profile", required=True, help="Profile section name, e.g. DEFAULT or MY_TENANCY")
    parser.add_argument("--key-file", required=True, help="New private key path to set as key_file")
    parser.add_argument("--fingerprint", required=True, help="New fingerprint returned by 'oci iam user api-key upload'")
    parser.add_argument("--config", default=os.path.expanduser("~/.oci/config"), help="Path to the OCI config file")
    args = parser.parse_args()

    if not os.path.isfile(args.config):
        print(f"error: config file not found: {args.config}", file=sys.stderr)
        return 1

    cfg = configparser.ConfigParser()
    cfg.read(args.config)

    section = "DEFAULT" if args.profile == "DEFAULT" else args.profile
    if section != "DEFAULT" and not cfg.has_section(section):
        print(f"error: profile [{section}] not found in {args.config}", file=sys.stderr)
        return 1

    target = cfg.defaults() if section == "DEFAULT" else cfg[section]
    target["key_file"] = args.key_file
    target["fingerprint"] = args.fingerprint

    backup_path = f"{args.config}.bak-{int(time.time())}"
    shutil.copy2(args.config, backup_path)

    original_mode = os.stat(args.config).st_mode
    tmp_path = f"{args.config}.tmp-{os.getpid()}"
    with open(tmp_path, "w") as f:
        cfg.write(f)
    os.chmod(tmp_path, original_mode)
    os.replace(tmp_path, args.config)

    print(f"Updated [{section}] in {args.config}:")
    print(f"  key_file    = {args.key_file}")
    print(f"  fingerprint = {args.fingerprint}")
    print(f"Backup of prior config saved to {backup_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
