# Auto-rickshaw passenger

## Decisions and status

- Approved: ten target sentences below, beginner adult passenger, polite everyday
  requests about destinations, fares, directions, stops, and cash payment.
- Active track: Hindi source (Devanagari) to English target.
- Deferred by the user: Hindi to Kannada, including Kannada script and romanization.
  Approved Kannada drafts are retained below; native-speaker review remains pending.
- Registration: add the scenario, starting at Level 1, to the existing scenario picker; preserve
  all everyday-practice levels. No language selector, new navigation, persistence,
  game type, or speech scoring is included.
- Implemented: all 12 levels, 38 target word forms plus two scaffold forms,
  12 short phrases, all ten complete sentences, and mixed review.
  The existing picker advances sequentially within the scenario.
- User supplied four initial SVGs and eight additional scenario scenes. All 12
  are used. Small approved artwork edits remove English signs; no downloaded
  artwork or language-specific SVG copies are needed.
- Source sentence s10 intentionally retains the approved male Hindi form.

## Approved sentences

| ID | Intent | Hindi source | English target | Deferred Kannada | Romanization |
| --- | --- | --- | --- | --- | --- |
| s01 | Ask for a destination | क्या आप रेलवे स्टेशन चलेंगे? | Will you take me to the railway station? | ರೈಲು ನಿಲ್ದಾಣಕ್ಕೆ ಬರುತ್ತೀರಾ? | Railu nildaanakke barutteeraa? |
| s02 | State a destination | मुझे बाज़ार जाना है। | I need to go to the market. | ನನಗೆ ಮಾರುಕಟ್ಟೆಗೆ ಹೋಗಬೇಕು. | Nanage maarukattege hogabeku. |
| s03 | Ask the fare | किराया कितना होगा? | How much will the fare be? | ಬಾಡಿಗೆ ಎಷ್ಟು ಆಗುತ್ತದೆ? | Baadige eshtu aaguttade? |
| s04 | Object to the price | यह बहुत महँगा है। | That is too expensive. | ಅದು ತುಂಬಾ ದುಬಾರಿ. | Adu tumbaa dubaari. |
| s05 | Negotiate politely | थोड़ा कम कीजिए। | Please lower the fare a little. | ಸ್ವಲ್ಪ ಕಡಿಮೆ ಮಾಡಿ. | Swalpa kadime maadi. |
| s06 | Give a left turn | यहाँ बाएँ मुड़िए। | Turn left here, please. | ಇಲ್ಲಿ ಎಡಕ್ಕೆ ತಿರುಗಿ. | Illi edakke tirugi. |
| s07 | Give a right turn | अगले मोड़ पर दाएँ मुड़िए। | Turn right at the next junction, please. | ಮುಂದಿನ ತಿರುವಿನಲ್ಲಿ ಬಲಕ್ಕೆ ತಿರುಗಿ. | Mundina tiruvinalli balakke tirugi. |
| s08 | Request a safe speed | कृपया धीरे चलाइए। | Please drive slowly. | ದಯವಿಟ್ಟು ನಿಧಾನವಾಗಿ ಓಡಿಸಿ. | Dayavittu nidhaanavaagi odisi. |
| s09 | Request a stop | कृपया यहीं रोकिए। | Please stop here. | ದಯವಿಟ್ಟು ಇಲ್ಲೇ ನಿಲ್ಲಿಸಿ. | Dayavittu ille nillisi. |
| s10 | Ask about cash payment | क्या मैं नकद दे सकता हूँ? | Can I pay in cash? | ನಗದು ಕೊಡಬಹುದೇ? | Nagadu kodabahude? |

English already uses Latin script, so a separate romanization is unnecessary.
Sentence capitalization is preserved above. Vocabulary matching uses NFC,
case-folding and surrounding punctuation removal; actual surface forms are
recorded below. Related grammatical forms are not merged.

## English vocabulary inventory

38 target forms plus two explicitly identified scenario scaffold forms.
First levels below refer to supported image/meaning previews, not recall games.
Grammar forms are tracked for coverage but never taught in isolation. The multiword
concepts "railway station" and "auto rickshaw" introduce their component forms
together. "To" appears twice in s02 and requires two separate selectable tiles
when that full sentence is eventually authored.

| Word ID | Native / surface form | Romanization | Meaning in context (Hindi) | Lemma / family | Sentence IDs | First level |
| --- | --- | --- | --- | --- | --- | --- |
| w01 | Will / will | same as native | क्या ... करेंगे / होगा | will, future question | s01, s03 | 10 |
| w02 | you | same as native | आप | you | s01 | 10 |
| w03 | take | same as native | ले जाना | take | s01 | 10 |
| w04 | me | same as native | मुझे | I / me | s01 | 10 |
| w05 | to | same as native | को / की ओर; infinitive marker | to | s01, s02 | 2 |
| w06 | the | same as native | निश्चित वस्तु का सूचक | the | s01, s02, s03, s05, s07 | 2 |
| w07 | railway | same as native | रेलवे | railway | s01 | 1 |
| w08 | station | same as native | स्टेशन | station | s01 | 1 |
| w09 | I | same as native | मैं | I / me | s02, s10 | 10 |
| w10 | need | same as native | ज़रूरत है | need | s02 | 10 |
| w11 | go | same as native | जाना | go | s02 | 2 |
| w12 | market | same as native | बाज़ार | market | s02 | 1 |
| w13 | How | same as native | कैसे; कितना पूछने में | how | s03 | 3 |
| w14 | much | same as native | कितना | much | s03 | 3 |
| w15 | fare | same as native | किराया | fare | s03, s05 | 3 |
| w16 | be | same as native | होना | be / is | s03 | 11 |
| w17 | That | same as native | वह / यह कीमत | that | s04 | 9 |
| w18 | is | same as native | है | be / is | s04 | 3 |
| w19 | too | same as native | ज़रूरत से ज़्यादा | too | s04 | 4 |
| w20 | expensive | same as native | महँगा | expensive | s04 | 4 |
| w21 | Please / please | same as native | कृपया | please | s05, s06, s07, s08, s09 | 9 |
| w22 | lower | same as native | कम कीजिए | lower (verb) | s05 | 4 |
| w23 | a | same as native | एक; "a little" में थोड़ा | a | s05 | 4 |
| w24 | little | same as native | थोड़ा | little | s05 | 4 |
| w25 | Turn | same as native | मुड़िए | turn | s06, s07 | 5 |
| w26 | left | same as native | बाएँ | left | s06 | 5 |
| w27 | here | same as native | यहाँ | here | s06, s09 | 6 |
| w28 | right | same as native | दाएँ | right | s07 | 5 |
| w29 | at | same as native | पर | at | s07 | 5 |
| w30 | next | same as native | अगला | next | s07 | 5 |
| w31 | junction | same as native | मोड़ / रास्तों का मिलन | junction | s07 | 5 |
| w32 | drive | same as native | वाहन चलाना | drive | s08 | 6 |
| w33 | slowly | same as native | धीरे | slowly | s08 | 6 |
| w34 | stop | same as native | रोकिए | stop | s09 | 6 |
| w35 | Can | same as native | क्या ... सकता हूँ | can, permission | s10 | 11 |
| w36 | pay | same as native | भुगतान करना | pay | s10 | 7 |
| w37 | in | same as native | में; नकद भुगतान के लिए | in | s10 | 7 |
| w38 | cash | same as native | नकद | cash | s10 | 1 |
| w39 | auto | same as native | ऑटो | auto rickshaw scaffold | scenario vehicle, no target sentence | 1 |
| w40 | rickshaw | same as native | रिक्शा | auto rickshaw scaffold | scenario vehicle, no target sentence | 1 |

The Kannada inventory and activities must be extracted separately on resumption;
English token boundaries and dependencies must not be reused for Kannada.

## SVG collection

| Concept / word IDs | Visual brief | Filename | Existing asset | Status |
| --- | --- | --- | --- | --- |
| Railway station / w07, w08 | Railway station / rail destination | station.svg | [station](../../../assets/svg_assets/station.svg) | Ready, user supplied |
| Market / w12 | Market or supermarket storefront | market-supermarket.svg | [market](../../../assets/svg_assets/market-supermarket.svg) | Ready, user supplied |
| Cash / w38 | Physical money, not a card or phone payment | money.svg | [cash](../../../assets/svg_assets/money.svg) | Ready, user supplied |
| Auto rickshaw / w39, w40 | Three-wheeled auto rickshaw | auto-rickshaw.svg | [auto](../../../assets/svg_assets/auto-rickshaw.svg) | Ready, user supplied |

| Go to the market / w05, w06, w11, w12 | Travel toward a market | go_to_market.svg | [scene](../../../assets/svg_assets/rickshaw_scenario/go_to_market.svg) | Ready; English sign replaced by produce |
| Turn left / w25, w26 | Rickshaw taking a left turn | turn_left.svg | [scene](../../../assets/svg_assets/rickshaw_scenario/turn_left.svg) | Ready |
| Turn right / w25, w28 | Rickshaw taking a right turn | turn_right.svg | [scene](../../../assets/svg_assets/rickshaw_scenario/turn_right.svg) | Ready |
| At the next junction / w29-w31 | Intersecting roads | junction.svg | [scene](../../../assets/svg_assets/rickshaw_scenario/junction.svg) | Ready |
| Drive slowly / w32, w33 | Rickshaw and speedometer | drive_slowly.svg | [scene](../../../assets/svg_assets/rickshaw_scenario/drive_slowly.svg) | Ready; English sign removed |
| Stop here / w27, w34 | Rickshaw stopping beside a raised-hand sign | stop_here.svg | [scene](../../../assets/svg_assets/rickshaw_scenario/stop_here.svg) | Ready; English replaced by a hand |
| Pay in cash / w36-w38 | Passenger handing cash to driver | pay_in_cash.svg | [scene](../../../assets/svg_assets/rickshaw_scenario/pay_in_cash.svg) | Ready |
| Fare and negotiation / w15, w20, w22-w24 | Quoted fare and high/reduced prices | the_fair.svg | [scene](../../../assets/svg_assets/rickshaw_scenario/the_fair.svg) | Ready; supplied filename preserved |

Artwork is reusable across language tracks. Hindi meanings and English labels
are supplied by lesson data, outside the SVG. Currency remains part of the scene.
No image is requested for isolated grammar words; forms such as "the", "a",
"to", "at", and "in" are introduced inside meaningful phrases.

## Prerequisite-ordered curriculum

All levels below are generated. Every new batch first presents all its image,
English, Hindi meaning, and optional pronunciation previews, without scoring.
Recognition begins only after the whole batch has been shown, so all choices
are known. Matching, phrase construction, and listening then reuse taught units.
Full sentences likewise have supported previews before assessment. The existing
quiz format opts into this behavior with `introduce: true`; other lessons keep
their previous behavior. English audio uses device TTS, not recordings.

| Level | Objective | New words / patterns | Reviewed words | Games | Target IDs |
| --- | --- | --- | --- | --- | --- |
| 1 | Visual basics | railway station; market; cash; auto rickshaw | Same four concepts after previews | image introduction, recognition, matching, listening | s01, s02, s10 prerequisites |
| 2 | Destination phrases | go to the market; to the railway station | Market and station | image introduction, recognition, matching, construction, listening | s01, s02 prerequisites |
| 3 | Asking about fares | the fare; how much is the fare? | Cash and destinations | image introduction, recognition, matching, construction, listening | s03 prerequisites |
| 4 | Negotiation | too expensive; lower the fare a little | The fare | image introduction, recognition, matching, construction, listening | s04, s05 prerequisites |
| 5 | Directions | turn left; turn right; at the next junction | Travel | image introduction, recognition, matching, construction, listening | s06, s07 prerequisites |
| 6 | Safe driving and stopping | drive slowly; stop here | Left and right turns | image introduction, recognition, matching, construction, listening | s08, s09 prerequisites |
| 7 | Cash payment | pay in cash | Cash and fare | image introduction, recognition, matching, construction, listening | s10 prerequisites |
| 8 | Mixed phrase review | No new words | All twelve phrases from Levels 2-7 | matching and construction | all |
| 9 | Short complete requests | Full s04, s06, s08, s09; polite please and That is within sentences | Price, turns, speed, stop | sentence previews, recognition, matching, construction, listening | s04, s06, s08, s09 |
| 10 | Complete destination requests | Full s01, s02, s07; will you, take me, I need within sentences | Destinations and directions | sentence previews, recognition, matching, construction, listening | s01, s02, s07 |
| 11 | Complete fare/payment requests | Full s03, s05, s10; will be and can I within sentences | Fare, negotiation and cash | sentence previews, recognition, matching, construction, listening | s03, s05, s10 |
| 12 | Mixed full scenario review | No new words or patterns | All prior content | alternating construction and listening across all ten complete sentences | s01-s10 |

## Full-sentence coverage matrix

| Sentence | Planned first full construction + listening | Mixed review | Runtime status |
| --- | --- | --- | --- |
| s01 | Level 10 | Level 12 | Construction + listening ready |
| s02 | Level 10 | Level 12 | Construction + listening ready |
| s03 | Level 11 | Level 12 | Construction + listening ready |
| s04 | Level 9 | Level 12 | Construction + listening ready |
| s05 | Level 11 | Level 12 | Construction + listening ready |
| s06 | Level 9 | Level 12 | Construction + listening ready |
| s07 | Level 10 | Level 12 | Construction + listening ready |
| s08 | Level 9 | Level 12 | Construction + listening ready |
| s09 | Level 9 | Level 12 | Construction + listening ready |
| s10 | Level 11 | Level 12 | Construction + listening ready |

## Generated assets and runtime contracts

All paths are relative to the repository root and use already bundled directories.

| Activity | Path | Content / coverage |
| --- | --- | --- |
| Level 1 | `assets/levels/hi_en_auto_rickshaw_l01.json` | Six steps, image previews before matching, registered under `hi-en-auto-rickshaw` |
| a01 | `assets/match_the_pairs_json/hi_en_auto_rickshaw_a01.json` | Four Hindi-English concept reviews after a02 |
| a02 | `assets/Quizes/hi_en_auto_rickshaw_a02.json` | Four visual introductions, then recognition using known choices |
| a03 | `assets/make_the_sentence/hi_en_auto_rickshaw_a03.json` | Listen and reconstruct railway station |
| a04 | `assets/make_the_sentence/hi_en_auto_rickshaw_a04.json` | Listen and select market |
| a05 | `assets/make_the_sentence/hi_en_auto_rickshaw_a05.json` | Listen and select cash |
| a06 | `assets/make_the_sentence/hi_en_auto_rickshaw_a06.json` | Listen and reconstruct auto rickshaw |
| Levels 2-12 | `assets/levels/hi_en_auto_rickshaw_l02.json` through `hi_en_auto_rickshaw_l12.json` | Prerequisite-ordered progression and mixed review |
| Visual phrase batches | `assets/Quizes/hi_en_auto_rickshaw_l02.json` through `hi_en_auto_rickshaw_l07.json` | Twelve contextual phrases; all previews precede recognition |
| Phrase reviews | `assets/match_the_pairs_json/hi_en_auto_rickshaw_l02.json` through `hi_en_auto_rickshaw_l07.json` | Known phrases and visual concepts only; no isolated grammar drills |
| Phrase batches | `assets/match_the_pairs_json/hi_en_auto_rickshaw_l08a.json`, `hi_en_auto_rickshaw_l08b.json` | Twelve contextual chunks, six pairs each |
| Full-sentence previews | `assets/Quizes/hi_en_auto_rickshaw_l09.json` through `hi_en_auto_rickshaw_l11.json` | All ten approved sentences modeled before recognition and construction |
| Sentence reviews | `assets/match_the_pairs_json/hi_en_auto_rickshaw_l09.json` through `hi_en_auto_rickshaw_l11.json` | Complete known sentences, no grammatical placeholders |
| Phrases p01-p12 | `assets/make_the_sentence/hi_en_auto_rickshaw_p01.json` through `hi_en_auto_rickshaw_p12.json` | Construction and listening in Levels 2-7, construction review in Level 8 |
| Sentences s01-s10 | `assets/make_the_sentence/hi_en_auto_rickshaw_s01.json` through `hi_en_auto_rickshaw_s10.json` | Both construction and listening in Levels 9-11, mixed review in Level 12 |

Quiz JSON uses optional `introduce`, `prompt_language` and `target_language`; omitted fields
retain the existing English-to-Hindi behavior. No runtime language selector exists.
The listening game plays the exact `translation` string, not `source`.

`assets/audio/mapping.json` retains existing keys and adds exact namespaced quiz
choice IDs plus all vocabulary, phrase, and full-sentence listening keys. Each new entry has native
English text, `language: en-IN`, and an empty recording filename. Playback uses
device TTS, not recordings. Entries without a language retain Hindi (`hi-IN`),
including fallback text. Mapping initialization is awaited before playback.

Validation is deliberately lightweight: the shared catalog smoke check, a shared
sentence-model check for repeated tiles, static analysis, and a one-off content
integrity check. No scenario-specific or per-level test suite is maintained.
Sentence construction now displays the source prompt, not the target answer,
and uses the bundled mascot path. Both sentence games accept either identical
unused tile when a word repeats (s02 contains two occurrences of "to").
Real-device English voice availability and pronunciation quality require a manual
listening check; structural validation does not establish acoustic correctness.

Current content check: all 12 levels / 92 steps, 26 unscored teaching previews,
12 referenced SVGs, known distractors and matching pairs, exact tile reconstruction,
English audio mappings, bundled references, and construction/listening coverage
for all ten sentences pass one-off validation. No scenario-specific tests added.
The shared quiz introduction regression check also passes; final runtime analysis
and device pronunciation/rendering checks are reported separately.
