#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ -d ".venv" ]]; then
  source .venv/bin/activate
elif [[ -d "venv" ]]; then
  source venv/bin/activate
fi

export PYTHONPATH="$ROOT_DIR${PYTHONPATH:+:$PYTHONPATH}"
export FLASK_APP="app.wsgi:app"
export FLASK_ENV="${FLASK_ENV:-development}"
export FLASK_DEBUG="${FLASK_DEBUG:-1}"

HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-5000}"

python3 -m flask run --host "$HOST" --port "$PORT" --debug
