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
- User supplied and confirmed the four SVGs. No artwork was downloaded or created.
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
All first-introduction levels below are generated. The multiword
concepts "railway station" and "auto rickshaw" introduce their component forms
together. "To" appears twice in s02 and requires two separate selectable tiles
when that full sentence is eventually authored.

| Word ID | Native / surface form | Romanization | Meaning in context (Hindi) | Lemma / family | Sentence IDs | First level |
| --- | --- | --- | --- | --- | --- | --- |
| w01 | Will / will | same as native | क्या ... करेंगे / होगा | will, future question | s01, s03 | 3 |
| w02 | you | same as native | आप | you | s01 | 3 |
| w03 | take | same as native | ले जाना | take | s01 | 2 |
| w04 | me | same as native | मुझे | I / me | s01 | 2 |
| w05 | to | same as native | को / की ओर; infinitive marker | to | s01, s02 | 2 |
| w06 | the | same as native | निश्चित वस्तु का सूचक | the | s01, s02, s03, s05, s07 | 3 |
| w07 | railway | same as native | रेलवे | railway | s01 | 1 |
| w08 | station | same as native | स्टेशन | station | s01 | 1 |
| w09 | I | same as native | मैं | I / me | s02, s10 | 2 |
| w10 | need | same as native | ज़रूरत है | need | s02 | 2 |
| w11 | go | same as native | जाना | go | s02 | 2 |
| w12 | market | same as native | बाज़ार | market | s02 | 1 |
| w13 | How | same as native | कैसे; कितना पूछने में | how | s03 | 4 |
| w14 | much | same as native | कितना | much | s03 | 4 |
| w15 | fare | same as native | किराया | fare | s03, s05 | 3 |
| w16 | be | same as native | होना | be / is | s03 | 3 |
| w17 | That | same as native | वह / यह कीमत | that | s04 | 4 |
| w18 | is | same as native | है | be / is | s04 | 4 |
| w19 | too | same as native | ज़रूरत से ज़्यादा | too | s04 | 4 |
| w20 | expensive | same as native | महँगा | expensive | s04 | 4 |
| w21 | Please / please | same as native | कृपया | please | s05, s06, s07, s08, s09 | 3 |
| w22 | lower | same as native | कम कीजिए | lower (verb) | s05 | 5 |
| w23 | a | same as native | एक; "a little" में थोड़ा | a | s05 | 5 |
| w24 | little | same as native | थोड़ा | little | s05 | 5 |
| w25 | Turn | same as native | मुड़िए | turn | s06, s07 | 5 |
| w26 | left | same as native | बाएँ | left | s06 | 5 |
| w27 | here | same as native | यहाँ | here | s06, s09 | 5 |
| w28 | right | same as native | दाएँ | right | s07 | 6 |
| w29 | at | same as native | पर | at | s07 | 6 |
| w30 | next | same as native | अगला | next | s07 | 6 |
| w31 | junction | same as native | मोड़ / रास्तों का मिलन | junction | s07 | 6 |
| w32 | drive | same as native | वाहन चलाना | drive | s08 | 6 |
| w33 | slowly | same as native | धीरे | slowly | s08 | 6 |
| w34 | stop | same as native | रोकिए | stop | s09 | 7 |
| w35 | Can | same as native | क्या ... सकता हूँ | can, permission | s10 | 7 |
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

No image is required for grammatical vocabulary. No missing SVG blocks Level 1.
Other directions, actions, and abstract concepts use text pairing/context unless
the user later supplies specifically matching artwork.

## Prerequisite-ordered curriculum

All levels below are generated. Each new batch starts with Hindi-English
matching before listening or construction; there are no untaught distractors.
Levels 2-7 use listening chunks made exclusively from introduced words.
Level 8 explicitly teaches their contextual meanings before construction.

| Level | Objective | New words / patterns | Reviewed words | Games | Target IDs |
| --- | --- | --- | --- | --- | --- |
| 1 (implemented) | Destinations and payment vocabulary, then listening | w07, w08, w12, w38, w39, w40; railway station, auto rickshaw | Same four concepts after matching | matching, four image questions, four listening activities | preparation for s01, s02, s10; no full sentence |
| 2 | Passenger and travel words | w03, w04, w05, w09, w10, w11 | Level 1 destinations | matching, listening | s01, s02, s10 prerequisites |
| 3 | Polite questions and fares | w01, w02, w06, w15, w16, w21 | Levels 1-2 | matching, listening | s01, s03, s05-s09 prerequisites |
| 4 | Price descriptions | w13, w14, w17, w18, w19, w20 | fare, will, be | matching, listening | s03, s04 prerequisites |
| 5 | Negotiation and left turns | w22, w23, w24, w25, w26, w27 | please, the, fare | matching, listening | s05, s06, s09 prerequisites |
| 6 | Right turns and safe speed | w28, w29, w30, w31, w32, w33 | turn, the, please | matching, listening | s07, s08 prerequisites |
| 7 | Stopping and payment | w34, w35, w36, w37 | I, cash, here, please | matching, listening | s09, s10 prerequisites |
| 8 | Two-to-four-word chunks | need to go; take me to; how much; the fare; too expensive; a little; turn left; turn right; next junction; drive slowly; stop here; pay in cash | All words already introduced | matching contextual chunks, short-phrase construction, listening | all |
| 9 | Short sentence patterns | polite imperative; That is ...; sentence-initial capitalization; final please | turn left here; drive slowly; stop here; too expensive | pattern pairing before full construction and listening | s04, s06, s08, s09 |
| 10 | Destination sentences | Will you take me to ...?; I need to go to ...; at the next junction | Level 8 chunks and Level 9 imperatives | pattern pairing before full construction and listening | s01, s02, s07 |
| 11 | Fare and payment sentences | How much will ... be?; Please lower ... a little; Can I pay in ...? | fare, negotiation and cash chunks | pattern pairing before full construction and listening | s03, s05, s10 |
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
| Level 1 | `assets/levels/hi_en_auto_rickshaw_l01.json` | Six nonempty steps, registered under `hi-en-auto-rickshaw` |
| a01 | `assets/match_the_pairs_json/hi_en_auto_rickshaw_a01.json` | Four Hindi-English concept introductions |
| a02 | `assets/Quizes/hi_en_auto_rickshaw_a02.json` | Four Hindi prompts, English choices; all alternatives introduced by a01 |
| a03 | `assets/make_the_sentence/hi_en_auto_rickshaw_a03.json` | Listen and reconstruct railway station |
| a04 | `assets/make_the_sentence/hi_en_auto_rickshaw_a04.json` | Listen and select market |
| a05 | `assets/make_the_sentence/hi_en_auto_rickshaw_a05.json` | Listen and select cash |
| a06 | `assets/make_the_sentence/hi_en_auto_rickshaw_a06.json` | Listen and reconstruct auto rickshaw |
| Levels 2-12 | `assets/levels/hi_en_auto_rickshaw_l02.json` through `hi_en_auto_rickshaw_l12.json` | Prerequisite-ordered progression and mixed review |
| Vocabulary batches | `assets/match_the_pairs_json/hi_en_auto_rickshaw_l02.json` through `hi_en_auto_rickshaw_l07.json` | Remaining 34 target forms; Level 7 reviews I and cash |
| Phrase batches | `assets/match_the_pairs_json/hi_en_auto_rickshaw_l08a.json`, `hi_en_auto_rickshaw_l08b.json` | Twelve contextual chunks, six pairs each |
| Patterns | `assets/match_the_pairs_json/hi_en_auto_rickshaw_l09.json` through `hi_en_auto_rickshaw_l11.json` | Explicit sentence patterns before reconstruction |
| Phrases p01-p12 | `assets/make_the_sentence/hi_en_auto_rickshaw_p01.json` through `hi_en_auto_rickshaw_p12.json` | Listening in Levels 2-7, construction in Level 8 |
| Sentences s01-s10 | `assets/make_the_sentence/hi_en_auto_rickshaw_s01.json` through `hi_en_auto_rickshaw_s10.json` | Both construction and listening in Levels 9-11, mixed review in Level 12 |

Quiz JSON uses optional `prompt_language` and `target_language`; omitted fields
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

Latest checks: all 12 levels / 71 activity steps passed the one-off content
integrity check, including bundled references, vocabulary prerequisites, exact
tile reconstruction, and construction/listening coverage for all ten sentences.
Both shared smoke checks passed. Targeted Dart analysis reported no errors or
warnings; four existing game-class naming lint notices remain.
