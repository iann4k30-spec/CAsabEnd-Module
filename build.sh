#!/bin/bash

NAME="CAsabEnd"
VER=$(cat version 2>/dev/null || echo "v2024.07.27")
OUTPUT="../${NAME}-${VER}.zip"

cd module

rm -f "$OUTPUT"

echo "Building $NAME $VER..."

zip -r9 "$OUTPUT" . \
  -x "*.sha256" \
  -x ".git*" \
  -x "*.swp" \
  2>&1

echo ""
echo "✅ Created: $OUTPUT"
echo "   Size: $(du -h "$OUTPUT" | cut -f1)"
