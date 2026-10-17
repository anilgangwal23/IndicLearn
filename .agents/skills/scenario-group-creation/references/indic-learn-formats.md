# IndicLearn Content Contracts

These are authoring examples, not new runtime schemas. Verify the current
implementation before generating content.

## Owning Code

- `lib/levels/level_model.dart`: step parsing.
- `lib/levels/level_factory.dart`: supported game dispatch.
- `lib/level_loader/level_loader.dart`: picker catalog and caller-supplied unlock flags.
- `lib/games/quiz_ui/quiz_loader.dart` and `quiz_models.dart`: quiz parsing.
- `lib/games/match_the_pair/pairing_loader.dart`: matching parsing.
- `lib/games/make_the_sentence/mts_model.dart` and `mts_loader.dart`: sentence parsing.
- `lib/games/follow_the_sound/fts.dart`: listening UI; reuses the sentence model.
- `lib/audio/pronunciation_service.dart` and `assets/audio/mapping.json`: playback.
- `pubspec.yaml`: bundled asset directories.

## Levels

Each level is an object containing a nonempty `steps` array:

```json
{
  "steps": [
    {
      "type": "make_the_sentence",
      "data": "assets/make_the_sentence/en_hi_auto_s01.json",
      "handler": "MTSPage"
    }
  ]
}
```

| Type | Handler | Data Directory |
| --- | --- | --- |
| `quiz` | `GamePage` | `assets/Quizes/` |
| `match_the_pair` | `WordMatchPage` | `assets/match_the_pairs_json/` |
| `make_the_sentence` | `MTSPage` | `assets/make_the_sentence/` |
| `follow_the_sound` | `FollowTheSound` | A bundled directory containing sentence objects |

The listening game can reuse sentence-building JSON. Check the manifest before
using `assets/follow_the_sound/`; its presence on disk does not mean it is bundled.
The picker uses `LevelDefinition(title, assetPath, unlocked)` values; there is
no established scenario-group runtime manifest. Keep planning metadata separate.

## Image Quizzes

Use a JSON array of questions, following
`assets/Quizes/whatisthis_fruit_001.json`. Each question uses:

- `id`: stable unique identifier.
- `type`: `image_choice`.
- `image`: existing bundled SVG path.
- `prompt`: language-code map with `native` and optional `romanized` fields.
- `choices`: answer objects with `id`, `image`, `text`, and `correct`.
- `text`: the same language-code map structure as `prompt`.
- `prompt_language` and `target_language`: optional language codes, defaulting
  to `en` and `hi` respectively.
- `introduce`: optional boolean, default `false`. When true, the quiz shows an
  unscored image/target-label/meaning preview with pronunciation. All opted-in
  previews appear before any quiz questions. Meaning comes from the correct
  choice's source-language text, or the question's source-language prompt.

For image-first lessons, set `introduce: true` on each new teaching item, use a
plain source-language meaning as its prompt, and supply audio mappings for the
choice IDs. Every distractor must be introduced in the batch or an earlier level.
Keep language labels in JSON rather than baking them into artwork.

Provide one correct choice and plausible, visually distinguishable distractors.
Do not use nonexistent images or assume a text-only quiz renderer exists.

## Matching

The canonical object root contains `word_pair_list`:

```json
{
  "word_pair_list": [
    {"left_word": "House", "right_definition": "Ghar"}
  ]
}
```

Use native-script text and romanization according to the approved display
convention. Validate actual pronunciation lookup keys; a combined display label
is not necessarily a supported audio key. Images are not required for matching.

## Sentence Construction And Listening

Both handlers consume a single object with `source`, `translation`, `words`,
and `index`. For the checked-in example in
`assets/follow_the_sound/en_hi_lvl1.json`, the native translation means
"My house" and the correct ordered positions are `[0, 2]` in four word tiles.
Inspect that file for the existing romanized/native tile-label convention.

`index` is an ordered list of zero-based positions in `words`, not vocabulary
IDs or the positions of every distractor. Allocate separate tiles for repeated
occurrences of a word so the selection interaction can reconstruct repetitions.
Do not invent a new token-label format without checking its rendering and audio.

The two handlers differ in presentation, not JSON schema. Confirm the listening
game's current prompt and audio behavior instead of promising unsupported
speech input or pronunciation scoring.

## Audio And Bundling

Inspect the pronunciation service and mapping file before adding entries. Match
the exact key passed by each game, preserve other groups' entries, and ensure
native text matches the intended language and pronunciation. An empty recording
field is not an audio asset; verify the service's current TTS fallback.

Use existing bundled directories where practical. Flutter asset declarations
must cover generated JSON, every referenced SVG, and any real audio recordings.
Do not assume declaring a parent bundles arbitrarily nested new subdirectories.