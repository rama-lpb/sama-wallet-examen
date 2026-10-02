#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p .demo
if curl -fsS http://127.0.0.1:8080/ >/dev/null 2>&1; then
  echo 'Un serveur répond déjà sur http://localhost:8080. La démo est peut-être déjà lancée.'
  exit 1
fi
docker compose -f Projet_wallet-main/docker-compose.yml up -d
mvn -q -f Projet_wallet-main/wallet-service/pom.xml package
mvn -q -f Projet_wallet-main/service-app/pom.xml package
(cd wallet_mobile && flutter build web --release)
PIDS=()
cleanup() { for pid in "${PIDS[@]}"; do kill "$pid" 2>/dev/null || true; done; }
trap cleanup EXIT INT TERM
for service in wallet-service service-app; do
  java -jar "Projet_wallet-main/$service/target/$service-0.0.1-SNAPSHOT.jar" > ".demo/$service.log" 2>&1 &
  PIDS+=("$!")
done
for port in 8091 8092; do
  ready=false
  for attempt in {1..60}; do
    if curl -fsS "http://127.0.0.1:$port/v3/api-docs" >/dev/null 2>&1; then ready=true; break; fi
    sleep 1
  done
  if [[ "$ready" != true ]]; then echo "Service $port indisponible : consulter .demo/*.log"; exit 1; fi
done
echo 'Démo : http://localhost:8080'
echo 'OTP : consulter .demo/wallet-service.log'
echo 'Ctrl+C arrête les services Java et le front. Les bases restent disponibles.'
python3 scripts/serve_demo.py
