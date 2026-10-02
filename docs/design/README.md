# Spending tracker: design directions

Live canvas (all mocks; most screens can be clicked through in Play mode):
https://claude.ai/artifact/5Z3BHZQokKGWBKkCog9HL4

The canvas has two pages: **Round 1 · Calm** (directions A–E) and **Round 2 · Fun** (directions F–J).

`mocks/` holds a snapshot of the canvas source. The canvas is the live version.

Working name in the mocks: **Kira** (Malay *kira*, "to count"). It's a placeholder.

## What we're optimising for

1. **Capture in under 3 seconds, from anywhere.** No form first. You say it, snap it, or it arrives on its own.
2. **The AI fills the fields and you only correct them.** Every record shows what was understood, and fixing a field takes one tap.
3. **Two numbers first: money in and money out.** Categories are the side quest, one tap away.
4. **Minimal.** One primary action per screen, no dashboards on the home screen.
5. **Malaysian by default.** RM, English/BM/Manglish ("tapau nasi ayam 8"), DuitNow / e-wallet screenshots, and wallet top-ups that don't count as spending.

## Round 1 · Calm (A–E)

| | Direction | Idea | Trade-off |
|---|---|---|---|
| A | **Mono** | Home is two big numbers (in, out) plus one hold-to-talk button. An Undo toast replaces confirm screens. | Calmest and fastest to read. History and categories are deliberately secondary. |
| B | **Chat** | Logging and asking are the same action. Talk, type or drop a screenshot, and every reply is an editable card. "How much on food?" works too. | The most flexible and the most visibly "AI". Long threads get busy, so the month summary stays pinned. |
| C | **Orbit** | A native iOS 26 (Liquid Glass) app. One ring shows how much of the income has gone out, split by category. It's built to be used from the Lock Screen, Action Button and Siri. | The most polished on the platform. A ring is less exact than plain numbers. |
| D | **Inbox** | Almost no typing. Apple Pay taps, screenshots and e-receipts land in an Inbox and you swipe to add them. The month view is a printed receipt. | The least effort per transaction, but it depends on one-time setup (a Shortcut, Photos access). |
| E | **Calendar** | Time is the home screen. A heatmap shows which days cost the most, you can tap any day to see or backfill it, and a flow chart shows where the income went. | The most informative over weeks. It's a little slower for "how am I doing today". |

These aren't mutually exclusive. The capture surfaces and AI pipeline below apply to every direction.

## Round 2 · Fun (F–J)

Round 1 had three gaps: no obvious way to adjust a record by hand, the several-records-from-one-recording feature wasn't visible, and nothing surprised. Round 2 keeps the layouts minimal but adds colour, motion and one signature surprise per direction. Every direction now shows:

- one spoken sentence ("lunch 12, grab 8.50, and Ali paid me back 20") becoming three separate records, including money in;
- a full manual edit screen: amount, spent or received, category, date and time, note, split, repeat and delete. The same screen is used to add a record by hand.

| | Direction | Signature surprise | One recording → several records | Manual edit | Trade-off |
|---|---|---|---|---|---|
| F | **Jar** | The month is a jar and every expense is a pebble (colour = category, size = amount). Tilt to stir, shake to undo, and "Sort" pours the pebbles into category tubes. | Each item drops in as its own pebble; money in lands as a coin. | Tap a pebble and it pops out: drag a ruler for the amount, tap a colour for the category. | Playful at a glance; exact numbers live in labels. |
| G | **Mochi** | A squishy mochi buddy is the talk button. It listens, then splits into one little mochi per record. | The split itself. Drag two together to merge; pinch one to split a bill. | Big − / + nudges, spent or got, category mochis, split with friends. | Charming and memorable; some people find a character too cute for money. |
| H | **Sentence** | Home is one editable sentence ("RM 5,200 came in and RM 2,146 went out…"). A marker sweeps over each word the AI understood. | A run-on sentence is visibly cut into separate records. | Tap any highlighted word to change only that part: keypad for amounts, colour chips for categories. | The clearest about what the AI understood; less visual. |
| I | **Flap** | A split-flap departures board that flips with every log. Pace reads ON TIME or DELAYED. | "NOW BOARDING · 3": rows flip in one by one, and anything guessed shows a status like TIME?. | Roll each digit like a reel; categories are colour "gates". | The most satisfying motion; darker and denser. |
| J | **Quilt** | Each day is a patch woven from category colours and sized by spend. At month end the quilt becomes a poster to share. | New threads weave into today's patch; money in becomes a stitched border. | Calculator keypad (type 36 ÷ 3 to split a bill), category spools. | The most beautiful and shareable; exact numbers take a tap. |

Motion in the mocks is CSS and turns off under Reduce Motion. In the app it maps to SwiftUI springs plus light haptics (a tap per pebble, flip or stitch). Each direction has its own category palette, checked for colour-blind safety.

## Capture methods

All of them call one App Intent (`LogTransactionIntent`), so behaviour is identical everywhere.

| Method | How it works on iOS | Phase |
|---|---|---|
| Hold to talk (in app) | On-device speech → parser → saved with Undo | Day 1 |
| Type like a text | "burger 5" → same parser; frequent items become one-tap repeats | Day 1 |
| Siri | App Shortcut phrase ("log in Kira") → Siri asks "what did you spend?" → snippet with Undo | Day 1 |
| Action Button | Assign the App Shortcut; press, speak, release (iPhone 15 Pro and newer) | Day 1 |
| Lock Screen / Control Center | Control widget ("Log spend") plus a Lock Screen widget showing today's total | Day 1 |
| Share sheet | Share extension takes screenshots, photos or PDFs → OCR → parser | Day 1 |
| Apple Pay taps | Shortcuts *Transaction* automation passes merchant + amount to the intent; one-tap install of a provided Shortcut | Guided setup |
| Back Tap | Accessibility → Back Tap → our Shortcut: take screenshot → read → log | Guided setup |
| Photos detection | Opt-in: scan new screenshots on-device and surface payment ones in the Inbox | v1.1 |
| E-receipts / statements | Forward e-receipts to a private address; drop in a bank statement PDF to catch up and dedupe | Later |

## How the AI works

The canvas board **How the AI works** shows this as a diagram.

1. **Read.** Voice → text with Apple's on-device Speech framework (`SpeechAnalyzer`). Check its Malay / code-mixed accuracy early; WhisperKit (Whisper on-device) is the fallback. Screenshots → text with Vision text recognition (`RecognizeDocumentsRequest` on iOS 26).
2. **Understand.** Text → one or more structured records using Apple's **Foundation Models** framework (on-device LLM, guided generation into a typed struct). It's free, private and works offline. It needs an Apple Intelligence-capable iPhone.
3. **Categorise**, in three tiers, cheapest first:
   - **Your memory:** exact and fuzzy merchant matches from your past edits ("ZUS" → Coffee).
   - **A tiny on-device classifier:** a Create ML / Core ML text model or embedding nearest-neighbour search. It's seeded with common Malaysian merchants and words (mamak, tapau, minyak, tol, gaji, sewa) and fine-tuned on your corrections.
   - **The LLM:** picks from *your* category list (as a constrained enum) only when the first two are unsure.
4. **Check.** Duplicates (same amount within a time window across sources), e-wallet top-ups and transfers between your own accounts (not spending), and currency conversion.
5. **Decide.** What you **said or typed** is saved immediately with Undo. What the app **found** (Apple Pay, screenshots, email) goes to the Inbox for a one-tap confirm. A low-confidence *field* is highlighted on its own.
6. **Cloud fallback** is opt-in, for hard cases or older iPhones: a small, fast vision-capable model such as Claude Haiku 4.5. Account numbers and names are stripped before anything leaves the phone.

**On small classifier models:** a separately trained model isn't needed to start. Personal memory plus the LLM's constrained pick covers most cases. Add the tiny classifier once there's real correction data to train on, because that's what makes it fast and personal.

### The record every input becomes

| Field | Example | Notes |
|---|---|---|
| type | expense | expense / income / transfer |
| amount, currency | 5.00, MYR | "5 ringgit", "RM5", "lima ringgit"; foreign amounts are converted |
| item | Burger | what was bought |
| merchant | ZUS Coffee | normalised name |
| category | Food | from the user's own list |
| when | 2026-09-18 19:42 | resolves "yesterday", "Saturday lunch" |
| paid with | Visa •• 4821 | optional |
| source | voice | voice / typed / screenshot / apple_pay / email / pdf |
| confidence | 0.96 | per field, drives the highlight-or-ask behaviour |

## Sample data used in the mocks

1–18 September 2026: in RM 5,200.00 (salary 4,800 + freelance 400), out RM 2,146.30. That splits into rent 900.00, food 486.40, groceries 238.90, transport 212.60, shopping 159.00 and bills 149.40, which is 41% of income spent and net +3,053.70. Where categories are coloured, each keeps the same hue in every direction, and the palette passes colour-blind checks.

## Next steps

1. Pick a direction or a blend across both rounds (e.g. F's jar with H's tap-a-word editing, or I's board with D's Inbox rule).
2. Prototype the parser on real utterances and screenshots (Manglish, DuitNow, e-wallet receipts) before polishing UI.
3. Build the SwiftUI skeleton: SwiftData store, `LogTransactionIntent`, widget and control, then home + capture.
