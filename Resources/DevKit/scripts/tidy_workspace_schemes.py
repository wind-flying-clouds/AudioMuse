#!/usr/bin/env python3
"""Tidy the Xcode workspace scheme list.

Hide every scheme whose name does not start with "MuseAmp", and order the
remaining MuseAmp schemes so that `MuseAmp` and `MuseAmpTV` come first. Other
MuseAmp schemes follow in alphabetical order, then the non-MuseAmp schemes
(marked hidden) trail at the end.

Writes the per-user file at:
    MuseAmp.xcworkspace/xcuserdata/<user>.xcuserdatad/xcschemes/xcschememanagement.plist

The scheme list is discovered via `xcodebuild -list -workspace`. Because
this file lives under `xcuserdata/`, it is not tracked by git; re-run
this script after adding or removing packages/schemes.
"""

from __future__ import annotations

import getpass
import plistlib
import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
WORKSPACE = REPO_ROOT / "MuseAmp.xcworkspace"

PINNED_ORDER = ["MuseAmp", "MuseAmpTV"]


def list_schemes() -> list[str]:
    result = subprocess.run(
        ["xcodebuild", "-list", "-workspace", str(WORKSPACE)],
        check=True,
        capture_output=True,
        text=True,
    )
    lines = result.stdout.splitlines()
    schemes: list[str] = []
    in_schemes = False
    for line in lines:
        stripped = line.strip()
        if stripped == "Schemes:":
            in_schemes = True
            continue
        if not in_schemes:
            continue
        if not stripped:
            break
        if re.match(r"^[A-Za-z].*:$", stripped):
            break
        schemes.append(stripped)
    return schemes


def sort_schemes(schemes: list[str]) -> list[str]:
    pinned = [name for name in PINNED_ORDER if name in schemes]
    muse_amp_rest = sorted(
        name
        for name in schemes
        if name.startswith("MuseAmp") and name not in pinned
    )
    others = sorted(name for name in schemes if not name.startswith("MuseAmp"))
    return pinned + muse_amp_rest + others


def build_plist(ordered: list[str]) -> dict:
    scheme_state: dict[str, dict] = {}
    for index, name in enumerate(ordered):
        key = f"{name}.xcscheme"
        scheme_state[key] = {
            "isShown": name.startswith("MuseAmp"),
            "orderHint": index,
        }
    return {"SchemeUserState": scheme_state}


def main() -> int:
    if not WORKSPACE.exists():
        print(f"error: workspace not found at {WORKSPACE}", file=sys.stderr)
        return 1

    schemes = list_schemes()
    if not schemes:
        print("error: no schemes returned by xcodebuild -list", file=sys.stderr)
        return 1

    ordered = sort_schemes(schemes)
    plist_payload = build_plist(ordered)

    user = getpass.getuser()
    target_dir = WORKSPACE / "xcuserdata" / f"{user}.xcuserdatad" / "xcschemes"
    target_dir.mkdir(parents=True, exist_ok=True)
    target = target_dir / "xcschememanagement.plist"

    with target.open("wb") as handle:
        plistlib.dump(plist_payload, handle)

    hidden = [name for name in ordered if not name.startswith("MuseAmp")]
    shown = [name for name in ordered if name.startswith("MuseAmp")]
    print(f"Wrote {target.relative_to(REPO_ROOT)}")
    print(f"  Shown ({len(shown)}): {', '.join(shown)}")
    if hidden:
        print(f"  Hidden ({len(hidden)}): {', '.join(hidden)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
