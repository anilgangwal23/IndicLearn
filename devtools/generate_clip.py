"""Generate one speech clip with the downloaded Indic Parler-TTS model.

Usage (from devtools/):
    .venv\\Scripts\\python.exe generate_clip.py --text "नमस्ते" --out out.wav
    .venv\\Scripts\\python.exe generate_clip.py --text "Hello" --speaker "Jenny" --out out.wav
"""

import argparse
import time
from pathlib import Path

import soundfile as sf

from tts_engine import TTSEngine

DEFAULT_DESCRIPTION = (
    "A female speaker speaks clearly at a moderate pace with a neutral tone. "
    "The recording is very high quality with no background noise."
)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--text", required=True)
    parser.add_argument("--description", default=DEFAULT_DESCRIPTION)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    engine = TTSEngine()
    start = time.perf_counter()
    audio = engine.synthesize(args.text, args.description)
    elapsed = time.perf_counter() - start

    out = Path(args.out)
    sf.write(out, audio, engine.sampling_rate)
    print(f"Wrote {out} ({len(audio) / engine.sampling_rate:.2f}s audio in {elapsed:.2f}s)")


if __name__ == "__main__":
    main()
