#!/usr/bin/env bash
# Copy the three Hop Out sites into /hop-out. Source repos stay the place to edit.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git clone --depth 1 https://github.com/ignaciocastellanoestrella-tech/hop-out-medals.git "$tmp/medals"
git clone --depth 1 https://github.com/ignaciocastellanoestrella-tech/hop-out-privacy.git "$tmp/privacy"
git clone --depth 1 https://github.com/ignaciocastellanoestrella-tech/hop-out-terms.git "$tmp/terms"

rm -rf hop-out/medals hop-out/privacy hop-out/terms
mkdir -p hop-out/medals hop-out/privacy hop-out/terms
cp -R "$tmp/medals/docs/." hop-out/medals/
cp -R "$tmp/privacy/docs/." hop-out/privacy/
cp -R "$tmp/terms/docs/." hop-out/terms/
cp hop-out/medals/medal-rules.html hop-out/medals/index.html

python3 - <<'PY'
from pathlib import Path
repls = [
    ("https://ignaciocastellanoestrella-tech.github.io/hop-out-privacy/", "https://castellanosoftware.com/hop-out/privacy/"),
    ("https://ignaciocastellanoestrella-tech.github.io/hop-out-terms/", "https://castellanosoftware.com/hop-out/terms/"),
    ("https://ignaciocastellanoestrella-tech.github.io/hop-out-medals/", "https://castellanosoftware.com/hop-out/medals/"),
]
for path in Path("hop-out").rglob("*"):
    if path.suffix.lower() not in {".html", ".css"}:
        continue
    text = path.read_text(encoding="utf-8")
    updated = text
    for old, new in repls:
        updated = updated.replace(old, new)
    if updated != text:
        path.write_text(updated, encoding="utf-8")
PY
