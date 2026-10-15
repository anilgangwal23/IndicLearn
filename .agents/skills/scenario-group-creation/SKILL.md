---
name: scenario-group-creation
description: 'Create IndicLearn scenario-based lesson groups. Use when asked to create a level group, teach a real-world scenario, generate a scenario curriculum, or turn ten target sentences into vocabulary, pronunciation, short-phrase, and full-sentence levels. Collect scenario input, extract unique words, request related SVG assets, and generate progressively harder lessons using existing game formats.'
---

# Scenario Group Creation

Create one coherent learning group for a practical scenario, such as taking an
auto rickshaw. Work from the user's desired conversation backwards to the words
and phrases needed to complete it. The group is a curriculum, not merely a list
of interchangeable games.

This is a repository-local Agent Skill. Follow it using the host agent's
available file, question, and test tools; no particular editor, model, MCP
server, or delegated agent is required.

## Scope And Outputs

- Exactly ten distinct target sentences unless the user explicitly changes the count.
- A deduplicated vocabulary inventory with sentence coverage and actual word forms.
- An SVG collection checklist with explicit missing/ready status.
- A prerequisite-ordered curriculum: words, pronunciation, short phrases,
  sentence construction, then practice covering all ten complete sentences.
- Valid game-data files and level definitions after the approval and asset gates.

Do not assume ten sentences means ten levels. Choose the level count to fit the
vocabulary load. Do not implement group navigation, progress persistence, new
game types, or pronunciation scoring as a side effect of generating content.

## 1. Collect The Scenario

Use the user's existing answers. Ask only for missing information:

- Scenario and learner role: for example, a passenger hiring an auto rickshaw.
- Source and target languages, including regional variety and native-script needs.
- Learner proficiency and audience; default to beginner-friendly adult language
  only when that assumption is explicitly disclosed.
- Practical goals and constraints: destinations, politeness, price, directions,
  safety, accessibility, and relevant local conventions.

For an otherwise unspecified language pair, propose English to Hindi based on
the existing repository, but confirm before authoring the final translations.
Do not start a second interview if these details were already provided.

Inspect applicable repository instructions and nearby existing content. Consult
[IndicLearn formats](./references/indic-learn-formats.md) and verify the current
loaders before generating assets; source code wins if this reference has drifted.

## 2. Draft Ten Target Sentences

Assign stable IDs `s01` through `s10`. For each sentence provide:

| ID | Communicative Intent | Source Sentence | Native Translation | Romanization |
| --- | --- | --- | --- | --- |

Use natural, useful sentences that the learner would actually say. Keep the
speaker role consistent. Cover distinct needs rather than filling ten slots
with destination substitutions. Reuse productive structures where useful.

For an auto-rickshaw scenario, consider asking to go to a movie theater or
railway station, asking the fare, requesting a stop, and confirming a destination.
Do not silently turn this example into the user's chosen scenario.

Check grammar, idiomatic phrasing, register, gender agreement, and regional
terminology. State unresolved linguistic uncertainty and request review instead
of claiming expert verification. Keep punctuation and romanization consistent.

Present the draft and ask for approval or corrections before creating playable
content. Reuse explicit approval if already supplied.

## 3. Extract Vocabulary And Dependencies

Tokenize the approved target-language sentences using the language's word
boundaries. Preserve the original native text; use Unicode NFC normalization
for matching and ignore surrounding punctuation. Do not split a script into
individual characters or deduplicate using English glosses alone.

Maintain a vocabulary table:

| Word ID | Native Form | Romanization | Meaning In Context | Lemma/Family | Sentence IDs | First Level |
| --- | --- | --- | --- | --- | --- | --- |

- Include function words, particles, pronouns, postpositions, auxiliaries, and
  inflected forms, not just drawable nouns.
- Deduplicate matching forms, but retain distinct grammatical forms and meanings.
  Connect related forms through the family field instead of losing them by stemming.
- Keep useful multiword expressions as phrases while retaining their component words.
- Record every occurrence when constructing sentences: a repeated word may need
  multiple selectable tiles even though it has one vocabulary entry.
- Track which words and grammatical patterns each phrase and sentence requires.

Check both directions: every sentence token is represented, and every taught word
serves at least one target sentence or an explicitly identified minimal scaffold.

## 4. Request SVGs And Save A Resumable Plan

Inspect existing assets before requesting new artwork. Present a collection list:

| Concept/Word IDs | Visual Brief | Suggested Filename | Existing Asset | Status |
| --- | --- | --- | --- | --- |

Ask the user to gather the missing related SVGs and place them in
`assets/svg_assets/`, or provide the actual paths. Specify what each image must
depict; a sentence's destination must not be represented by an unrelated icon.
Reuse one SVG for the same concept where appropriate, not for distinguishable
answer choices. Do not request pictures for abstract grammar words; teach those
through text pairing and contextual phrases.

Do not invent asset paths, download unapproved artwork, or create broken image
questions. Mark missing assets as blocked. If the user explicitly chooses a
text-only group, skip image quizzes rather than fabricating pictures.

Save the approved sentence table, vocabulary inventory, SVG checklist, language
decisions, and curriculum draft in `content/scenario_groups/<scenario_slug>/plan.md`.
This Markdown is authoring metadata, not a runtime group manifest. On resume,
read and update it rather than regenerating IDs or repeating approved questions.

Wait for the user's asset confirmation before generating image-dependent
lessons. Text-only assets may be prepared first if the user requests that scope.

## 5. Sequence The Curriculum

Build and present a prerequisite-ordered level table:

| Level | Objective | New Words/Patterns | Reviewed Words | Games | Target Sentence IDs |
| --- | --- | --- | --- | --- | --- |

Use these stages in increasing difficulty:

1. **Word meaning:** introduce concrete words with image-choice quizzes when
   SVGs exist, and use word matching for abstract or grammatical vocabulary.
2. **Pronunciation and listening:** reuse known words with supported playback
   and simple listening activities. This is listening practice, not speech grading.
3. **Short phrases:** build useful two-to-four-word chunks from introduced words.
4. **Sentence patterns:** combine known chunks into short complete sentences;
   introduce unavoidable new grammar or inflections explicitly before requiring it.
5. **Full scenario:** reconstruct and listen to all ten approved target sentences,
   distributing them across manageable levels and ending with mixed review.

Prefer small batches of roughly four-to-six new words, adjusted for age and
sentence complexity. Recycle earlier words and vary game types purposefully.
For each required answer, its words and patterns must have been introduced in
that level before testing or in an earlier level. Avoid untaught distractors
unless their meaning is supplied; never accept a second valid answer as incorrect.

Track first introduction and later practice for every word. Maintain a coverage
matrix mapping all ten sentence IDs to their full-sentence activities. Do not
claim a sentence is covered merely because one of its nouns appeared in a quiz.

## 6. Generate Repository-Compatible Assets

After the sentence approval and applicable asset gates:

- Use collision-free names prefixed by language pair, scenario slug, and stable
  activity ID. Do not replace existing levels or renumber their content.
- Generate quizzes, word matching, sentence-building, and listening assets only
  in the formats supported by the current loaders.
- Use one sentence asset per phrase or sentence; both sentence games currently
  consume a single sentence object, not an array of ten sentences.
- Reuse a compatible sentence asset between construction and listening when
  appropriate. Register newly used asset directories in `pubspec.yaml`.
- Use exact handler names and type values from the format reference.
- Derive correct tile indices from the finalized tile ordering. For repeated
  words, allocate separate tile occurrences; never handwave their indices.
- Check the pronunciation service's exact lookup keys. Add native-script audio
  mappings where needed and preserve existing mappings. Do not claim recordings
  exist; identify whether pronunciation uses recordings or TTS fallback.

Record generated paths and sentence coverage in the saved plan. Before adding
levels to the picker, confirm whether the user wants them appended, what should
be unlocked, and whether a separate group UI is in scope. If registration is
already authorized, preserve existing catalog entries and follow that decision.
Do not invent runtime scenario metadata that the app does not read.

## 7. Validate And Report

Run focused checks, using the repository's parsers and test conventions:

- Exactly ten approved sentence IDs; vocabulary and full-sentence coverage complete.
- All emitted JSON parses, loads through the intended model, and has nonempty steps.
- Every level's handler/type pair is supported and every referenced asset exists.
- Every referenced asset directory is bundled; nested directories need explicit checks.
- Quiz IDs are unique in their scope, images match their concepts, and each
  question has one correct answer and distinct plausible alternatives.
- Matching activities have unambiguous pairs and are small enough for the UI.
- Sentence indices are integers within bounds and reconstruct the exact intended
  native sentence after removing romanization labels and normalizing punctuation.
  Account for repeated words and preserve grammatical surface forms.
- Audio lookup resolves to the intended native text or an existing recording;
  distinguish structural validation from a real-device pronunciation check.
- Curriculum dependencies hold and no final target sentence is missing.

Reuse or extend nearby tests instead of introducing a new test framework.
If Dart/Flutter runtime files changed, follow the host's required analysis,
test, and reload procedure. Do not hot-reload merely for editing this skill.

Finish with the scenario, sentence/word/level counts, generated paths, SVG or
language-review blockers, validation results, and any unverified audio behavior.
If waiting for assets or approval, report the saved plan and precise next input
needed instead of claiming the group is complete.