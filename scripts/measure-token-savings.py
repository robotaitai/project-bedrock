#!/usr/bin/env python3
"""
Scaffold entrypoint for measuring token savings from compacted project memory.

Real measurement logic is intentionally deferred to a later stage.
"""

import argparse


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Scaffold-only token savings measurement entrypoint."
    )
    parser.add_argument("project", nargs="?", default=".")
    args = parser.parse_args()

    print(f"Token savings scaffold for: {args.project}")
    print("TODO: compare raw context candidates vs compacted memory loads.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
