#!/usr/bin/env python3
import re
import sys


def fail(message: str) -> int:
    print(message, file=sys.stderr)
    return 1


def main() -> int:
    if len(sys.argv) != 2:
        return fail("usage: release_version.py <tag>")

    tag = sys.argv[1].strip()
    match = re.fullmatch(r"(?:v|dev-)(\d+)\.(\d+)\.(\d+)", tag)
    if not match:
        return fail(f"unsupported tag format: {tag}")

    major, minor, patch = map(int, match.groups())
    version_name = f"{major}.{minor}.{patch}"
    version_code = major * 1_000_000 + minor * 1_000 + patch

    print(f"WOOJUSAGWA_VERSION_NAME={version_name}")
    print(f"WOOJUSAGWA_VERSION_CODE={version_code}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
