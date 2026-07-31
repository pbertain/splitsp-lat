#!/usr/bin/env bash
# Regenerates html/manifest.json by scanning html/images and html/logos.
# Run this after adding/removing files in either directory.
set -euo pipefail

cd "$(dirname "$0")/.."

OUT="html/manifest.json"
TMP="$(mktemp)"

echo '[]' > "$TMP"

for category in images logos; do
    dir="html/$category"
    [ -d "$dir" ] || continue
    while IFS= read -r -d '' f; do
        rel="${f#html/}"
        name="$(basename "$f")"
        jq --arg path "$rel" --arg name "$name" --arg category "$category" \
            '. + [{"path": $path, "name": $name, "category": $category}]' \
            "$TMP" > "$TMP.next"
        mv "$TMP.next" "$TMP"
    done < <(find "$dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.svg' -o -iname '*.webp' \) -print0 | sort -z)
done

jq 'sort_by(.category, .name)' "$TMP" > "$OUT"
rm -f "$TMP"

echo "Wrote $(jq length "$OUT") entries to $OUT"
