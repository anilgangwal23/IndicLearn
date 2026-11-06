#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "This setup script is for macOS. Use setup.bat on Windows." >&2
    exit 1
fi

DEVTOOLS="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="$(command -v python3.10 || command -v python3 || true)"

if [[ -z "$PYTHON" ]] || ! "$PYTHON" -c 'import sys; sys.exit(sys.version_info < (3, 10))'; then
    echo "Python 3.10 or newer is required. Install it and rerun setup.sh." >&2
    exit 1
fi

VENV="$DEVTOOLS/.venv"
VENV_PY="$VENV/bin/python"

if [[ ! -x "$VENV_PY" ]]; then
    "$PYTHON" -m venv "$VENV"
fi

"$VENV_PY" -m pip install --upgrade pip
"$VENV_PY" -m pip install torch torchaudio
"$VENV_PY" -m pip install -r "$DEVTOOLS/requirements.txt"
"$VENV_PY" -c 'import torch; print("torch", torch.__version__, "cuda", torch.cuda.is_available(), "mps", torch.backends.mps.is_available())'

echo "Setup complete."
