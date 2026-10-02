#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/wallet_mobile"
flutter build web --release --no-wasm-dry-run
mkdir -p "$ROOT/deploy/render-web"
cp -a build/web/. "$ROOT/deploy/render-web/"
echo 'Frontend compilé dans deploy/render-web ; ajouter ce dossier au dépôt Git.'
