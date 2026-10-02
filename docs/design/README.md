# Spending tracker: design directions

Live canvas (all mocks; most screens can be clicked through in Play mode):
https://claude.ai/artifact/5Z3BHZQokKGWBKkCog9HL4

`mocks/` holds a snapshot of the canvas source. The canvas is the live version.

Working name in the mocks: **Kira** (Malay *kira*, "to count"). It's a placeholder.

## What we're optimising for

1. **Capture in under 3 seconds, from anywhere.** No form first. You say it, snap it, or it arrives on its own.
2. **The AI fills the fields and you only correct them.** Every record shows what was understood, and fixing a field takes one tap.
3. **Two numbers first: money in and money out.** Categories are the side quest, one tap away.
4. **Minimal.** One primary action per screen, no dashboards on the home screen.
5. **Malaysian by default.** RM, English/BM/Manglish ("tapau nasi ayam 8"), DuitNow / e-wallet screenshots, and wallet top-ups that don't count as spending.

## The five directions

| | Direction | Idea | Trade-off |
|---|---|---|---|
| A | **Mono** | Home is two big numbers (in, out) plus one hold-to-talk button. An Undo toast replaces confirm screens. | Calmest and fastest to read. History and categories are deliberately secondary. |
| B | **Chat** | Logging and asking are the same action. Talk, type or drop a screenshot, and every reply is an editable card. "How much on food?" works too. | The most flexible and the most visibly "AI". Long threads get busy, so the month summary stays pinned. |
| C | **Orbit** | A native iOS 26 (Liquid Glass) app. One ring shows how much of the income has gone out, split by category. It's built to be used from the Lock Screen, Action Button and Siri. | The most polished on the platform. A ring is less exact than plain numbers. |
| D | **Inbox** | Almost no typing. Apple Pay taps, screenshots and e-receipts land in an Inbox and you swipe to add them. The month view is a printed receipt. | The least effort per transaction, but it depends on one-time setup (a Shortcut, Photos access). |
| E | **Calendar** | Time is the home screen. A heatmap shows which days cost the most, you can tap any day to see or backfill it, and a flow chart shows where the income went. | The most informative over weeks. It's a little slower for "how am I doing today". |

These aren't mutually exclusive. The capture surfaces and AI pipeline below apply to every direction.

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

1. Pick a direction (or a blend: e.g. A's home, D's Inbox rule, C's system surfaces).
2. Prototype the parser on real utterances and screenshots (Manglish, DuitNow, e-wallet receipts) before polishing UI.
3. Build the SwiftUI skeleton: SwiftData store, `LogTransactionIntent`, widget and control, then home + capture.
