"""Render pronunciation clips for every spoken string the app plays.

Collects spoken text from:
- assets/Quizes/*.json: choice "id" (played by quiz.dart) and each choice's native text in every language
- assets/follow_the_sound/*.json: "translation" (played by fts.dart), Hindi
- assets/audio/mapping.json: entries with "native" text and "language"

Writes clips to assets/audio/words/<lang>/<hash>.mp3 and sets "file" in mapping.json.
Existing clips are skipped, so the script can be re-run after adding content.

Usage (from devtools/):
    .venv\\Scripts\\python.exe build_clips.py --dry-run
    .venv\\Scripts\\python.exe build_clips.py
    .venv\\Scripts\\python.exe build_clips.py --limit 3
"""

import argparse
import hashlib
import json
import os
import sys
from pathlib import Path

import soundfile as sf

from tts_engine import TTSEngine

DEVTOOLS = Path(__file__).resolve().parent
ASSETS = DEVTOOLS.parent / "assets"
MAPPING = ASSETS / "audio" / "mapping.json"
WORDS_DIR = ASSETS / "audio" / "words"

LOCALE_BY_LANG = {
    "hi": "hi-IN",
    "en": "en-IN",
    "pa": "pa-IN",
    "mr": "mr-IN",
    "kn": "kn-IN",
    "te": "te-IN",
}

DESCRIPTION = (
    "A clear, natural speaker speaks at a moderate pace with a neutral tone. "
    "The recording is very high quality with no background noise."
)


def lang_code(tag: str) -> str:
    return tag.split("-")[0].lower()


def collect_spoken_items() -> dict[str, tuple[str, str]]:
    """Return {key: (lang, text)}. The key is what the app passes to playPronunciation."""
    items: dict[str, tuple[str, str]] = {}

    def add(key: str, lang: str, text: str) -> None:
        if key and text and key not in items:
            items[key] = (lang, text)

    for path in sorted((ASSETS / "Quizes").glob("*.json")):
        for question in json.loads(path.read_text(encoding="utf-8")):
            for choice in question.get("choices", []):
                key = choice["id"]
                for lang, value in choice.get("text", {}).items():
                    native = value.get("native", "")
                    if native == key:
                        add(key, lang, native)
                    else:
                        add(native, lang, native)

    for path in sorted((ASSETS / "follow_the_sound").glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        for lang, text in data["translation"].items():
            add(text, lang, text)

    mapping = json.loads(MAPPING.read_text(encoding="utf-8"))
    for key, entry in mapping.items():
        add(key, lang_code(entry.get("language", "hi-IN")), entry.get("native", ""))

    return items


def clip_relative_path(lang: str, text: str) -> str:
    digest = hashlib.sha1(f"{lang}|{text}".encode("utf-8")).hexdigest()[:16]
    return f"words/{lang}/{digest}.mp3"


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="List work without rendering.")
    parser.add_argument("--limit", type=int, default=None, help="Render at most N new clips.")
    args = parser.parse_args()

    items = collect_spoken_items()
    mapping = json.loads(MAPPING.read_text(encoding="utf-8"))

    pending = []
    for key, (lang, text) in sorted(items.items()):
        rel = clip_relative_path(lang, text)
        if not (ASSETS / "audio" / rel).exists():
            pending.append((key, lang, text, rel))

    print(f"{len(items)} spoken strings, {len(pending)} clips to render")
    for lang in sorted({lang for lang, _ in items.values()}):
        total = sum(1 for l, _ in items.values() if l == lang)
        todo = sum(1 for _, l, _, _ in pending if l == lang)
        print(f"  {lang}: {total} strings, {todo} to render")

    if args.dry_run:
        return

    engine = None
    rendered = 0
    for key, lang, text, rel in pending:
        if args.limit is not None and rendered >= args.limit:
            break
        if engine is None:
            engine = TTSEngine()
        out = ASSETS / "audio" / rel
        out.parent.mkdir(parents=True, exist_ok=True)
        audio = engine.synthesize(text, DESCRIPTION)
        temp = out.with_name(out.stem + ".tmp.mp3")
        sf.write(temp, audio, engine.sampling_rate, format="MP3")
        os.replace(temp, out)
        rendered += 1
        print(f"[{rendered}/{len(pending)}] {lang} {text!r} -> {rel}")

    changed = False
    for key, (lang, text) in items.items():
        rel = clip_relative_path(lang, text)
        if not (ASSETS / "audio" / rel).exists():
            continue
        entry = mapping.get(key, {"native": text, "language": LOCALE_BY_LANG.get(lang, lang)})
        if entry.get("file") != rel:
            entry["file"] = rel
            mapping[key] = entry
            changed = True

    if changed:
        MAPPING.write_text(
            json.dumps(mapping, ensure_ascii=False, indent=4) + "\n", encoding="utf-8"
        )
    print(f"Done. Rendered {rendered} clips. mapping.json updated: {changed}")


if __name__ == "__main__":
    main()
