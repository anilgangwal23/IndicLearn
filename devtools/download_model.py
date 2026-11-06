"""Download the gated ai4bharat/indic-parler-tts model into devtools/models/.

Requires HF_TOKEN in devtools/.env and the Indic Parler-TTS conditions accepted
on the model page. Run with devtools/.venv:
    .venv/bin/python download_model.py  # macOS
    .venv\\Scripts\\python.exe download_model.py
"""

from pathlib import Path

from dotenv import load_dotenv
from huggingface_hub import snapshot_download

REPO_ID = "ai4bharat/indic-parler-tts"
DEVTOOLS = Path(__file__).resolve().parent
LOCAL_DIR = DEVTOOLS / "models" / "indic-parler-tts"


def main() -> None:
    load_dotenv(DEVTOOLS / ".env")
    import os

    token = os.environ.get("HF_TOKEN", "").strip()
    if not token:
        raise SystemExit("HF_TOKEN is empty. Set it in devtools/.env first.")

    path = snapshot_download(
        repo_id=REPO_ID,
        local_dir=LOCAL_DIR,
        token=token,
    )
    print(f"Model downloaded to {path}")


if __name__ == "__main__":
    main()
