#!/usr/bin/env python3
"""Inject public Render API URLs into the prebuilt Flutter static site."""
import json
import os
from pathlib import Path
out = Path(__file__).resolve().parents[1] / 'deploy/render-web'
if not (out / 'index.html').exists():
    raise SystemExit('deploy/render-web est absent : lancer scripts/prepare-render-web.sh')
wallet = os.environ.get('WALLET_PUBLIC_URL', '').rstrip('/')
service = os.environ.get('SERVICE_PUBLIC_URL', '').rstrip('/')
for name, value in [('WALLET_PUBLIC_URL', wallet), ('SERVICE_PUBLIC_URL', service)]:
    if not value.startswith('https://'):
        raise SystemExit(f'{name} doit être une URL HTTPS Render : {value!r}')
(out / 'config.json').write_text(json.dumps({'walletUrl': wallet, 'serviceUrl': service}))
print('Configuration Flutter générée pour les deux API Render.')
