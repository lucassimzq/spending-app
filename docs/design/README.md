# Spending tracker: design directions

Live canvas (all mocks; most screens can be clicked through in Play mode):
https://claude.ai/artifact/5Z3BHZQokKGWBKkCog9HL4

The canvas has six pages: **Round 1 · Calm** (directions A–E), **Round 2 · Fun** (directions F–J), **Round 3 · Type & motion** (directions K–O, plus a research board), **Round 4 · Clear & structured** (directions P–T, plus a legend board), **Round 5 · Timeline for iOS 27** (direction S built out into 11 screens, plus a notes board) and **Round 6 · Tangerine & personality** (the same 11 screens with a new font and colour). It opens on Round 6.

`mocks/` holds a snapshot of the canvas source. The canvas is the live version.

**The app.** The iPhone app built from Round 6 is in [`ios/`](../../ios/README.md).

**Start here.** The chosen design is **Round 6**: direction S (Timeline) with iOS 27 Liquid Glass controls, a light tangerine accent (`#FFA552`), Fraunces for titles and money, Figtree for interface text, and neutral backgrounds.

- [`screenshots/`](screenshots/README.md) has PNGs of every board. Round 6 is at iPhone resolution (1170 × 2532).
- `mocks/` has the HTML source of every board, with exact sizes, colours and copy.
- [`tools/`](tools/README.md) has the scripts that generate the Round 5–6 boards and render the screenshots.
- Still open: keep Fraunces or switch to one of the two alternatives on the Round 6 notes board, and design onboarding, the full category list, settings and dark mode.

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

## Round 3 · Type & motion (K–O)

Feedback on Round 2: too much colour, and the fun should come from motion and typography, not characters. Round 3 started with research into recent Apple Design Award winners and the best-rated money apps (summarised on the canvas's research board). What we took from them:

- **One answer per moment** (Flighty): home shows the one number that matters now.
- **Huge numbers, one colour** (Revolut, Monzo, Cash App): every direction is a neutral base plus exactly one accent.
- **Motion that confirms** (Copilot Money): when a number changes it animates, and nothing else on screen moves.
- **Make the mundane tactile** (the (Not Boring) apps): every entry gets one physical moment.
- **Colour that means something** (Tide Guide): the accent marks meaning, such as pace or money in vs out, and nothing else.
- **Words can be the delight** (grug): microcopy with personality. The type is the illustration.

Every direction keeps Round 2's two must-haves: one sentence becoming three records (including money in), and a full edit screen.

| | Direction | Signature (type + motion) | Fonts | Colour | Trade-off |
|---|---|---|---|---|---|
| K | **Weight** | The Out number is set heavier the more of your income is gone, and money in stays light. Spoken words inflate from hairline to bold, a pressed keypad digit thickens, and the selected option is bold while the rest stay thin. | Anybody (variable weight and width) | Warm grey + vermilion | The most original. Weight is a feeling, so the digits stay exact. |
| L | **Lyrics** | Today reads like synced lyrics: earlier entries dim, the latest gets a karaoke sweep, and "…what's next?" waits below. Talking shows live captions that turn into a numbered setlist. Pace is two bars, month vs income. | Funnel Display + Funnel Sans | Deep plum + amber | The most emotional. Dark-only and less dense. |
| M | **Edition** | Your money as a daily paper: an AI-written headline ("Rent and food lead a calm September"), briefs ("Burger, five ringgit.") and a forecast. Headlines rise out of a mask, rules draw themselves, and briefs type and print in. Editing is "Corrections". | Instrument Serif + Geist + Geist Mono | Paper white + ultramarine | The strongest voice. Serif headlines take more room. |
| N | **Roll** | Every amount is an odometer that rolls to the new total. Several entries spring out of the input as cards, "Again?" chips re-log your regulars in one tap, and the placeholder types itself. | Schibsted Grotesk | White + jade | The most familiar and quickest to learn, and the least unusual. |
| O | **Margin** | Clean type plus the AI's pink pen: circles, underlines, ticks and handwritten notes ("41% gone, 12 days left — you're fine"). A spoken sentence gets bracketed and labelled in the margin, and guesses get a circled "?". | Figtree + Shantell Sans (bounce axis) | Paper + marker pink | The friendliest way to show what the AI did. The notes need restraint to stay minimal. |

Motion in the mocks is CSS and turns off under Reduce Motion. In SwiftUI it maps to `contentTransition(.numericText())` for rolling numbers, `TextRenderer` (iOS 18+) for per-word and per-line effects, variable-font axes for weight and bounce, and Core Haptics for the tactile beats. Accent colours used for text pass WCAG AA contrast on their backgrounds.

Research sources: [Apple Design Awards 2026 winners](https://www.apple.com/newsroom/2026/06/apple-reveals-winners-of-the-2026-apple-design-awards/), [2026 finalists (MacStories)](https://www.macstories.net/news/apple-announces-its-2026-apple-design-award-finalists/), [Flighty design guide](https://blakecrosley.com/guides/design/flighty), [(Not Boring) Weather](https://www.tapsmart.com/apps/not-boring-weather-fun-alternative-weather-watchers/), [Copilot Money review](https://freenance.io/products/copilot-money-review-2026-budgeting-app-iphone-best-design/), [Revolut design notes](https://www.webdesignhot.com/api/design-md/revolut.md), [numericText in SwiftUI](https://www.createwithswift.com/animating-numeric-text-in-swiftui-with-the-content-transition-modifier/), [TextRenderer effects](https://www.createwithswift.com/text-effects-using-textrenderer-in-swiftui), [variable fonts in motion (FontLab)](https://blog.fontlab.com/2026/03/10/variable-fonts-in-motion-and-ui/).

## Round 4 · Clear & structured (P–T)

Feedback on Round 3: N (Roll) and O (Margin) were the favourites because the screen is clearly divided into parts. There are cards, pills and lines, buttons look like buttons, and coloured numbers mark what matters. The other directions read as "a bunch of text", so it took a few seconds to find the important number. Round 4 keeps the motion and the fonts but makes structure the rule. Every direction uses the same parts, explained on the canvas's legend board:

- **Containers.** Every section sits in a card, a tile, or rows separated by lines, and every number has a label above it.
- **Buttons.** One filled primary button per screen. Other actions are tinted or outlined pills, and icon actions are circles.
- **Tappable vs read-only.** Rows that open have a ›. Tags (small, square-cornered) describe an entry and aren't tappable. Chips (round, with + or ✓) add, filter or pick in one tap.
- **Colour marks data.** Green is money in and dark ink is money out. The accent colour marks anything the AI guessed, and AI tips sit in a tinted box.

| | Direction | Layout | Home shows | Signature motion | Colour · font | Trade-off |
|---|---|---|---|---|---|---|
| P | **Stack** | Titled cards (like Apple Health's summary) and a floating action bar | This month (spent, came in, left), Today, Log again | Cards rise in, totals roll, new entries arrive in a sheet | iOS grey + indigo · Plus Jakarta Sans | The most familiar and the easiest to build; the least distinctive. |
| Q | **Bento** | A grid of tiles, one answer per tile | A yellow "spent" tile, came in, left to spend, today, top category, days left | Tiles pop in, a highlighter marks the amounts it heard, the days ring fills | Warm grey + yellow · Bricolage Grotesque | The most glanceable; a fixed grid holds fewer list items. |
| R | **Ledger** | A statement table with lines, filter pills and labelled form fields | An In/Out box, filters, and a table grouped by day | Totals tick over, new rows flash yellow, a before/after table | White + cobalt · IBM Plex Sans and Plex Mono | The most precise and scannable; also the most serious. |
| S | **Timeline** | A vertical line with cards at their time, a Now marker and dashed quiet gaps | A month summary card, today on the line, an AI tip | The line draws down, dots pop in, the time knob slides; it asks "Is this a second lunch?" | Off-white + violet · Outfit | The best feel for a day; the month view needs its own design. |
| T | **Sheet** | A dark summary header over a white sheet with tabs | Spent, came in and left on dark; Today and Log again in the sheet | The sheet springs up, the total rolls, live captions fill the dark area | Navy + coral, mint for money in · Manrope | The clearest split between reading and doing; the header takes a third of the screen. |

Every direction keeps the two essentials from Rounds 2 and 3: one sentence becoming three entries (with the AI's guesses marked) and a full edit screen. Motion still turns off under Reduce Motion, and accent colours used for text pass WCAG AA contrast.

## Round 5 · Timeline for iOS 27 (S, refined)

Feedback on Round 4: S (Timeline) is the direction to build on, with four changes. Lose the purple. Make buttons look like Apple's native Liquid Glass. Follow iOS 27. Make Today less overwhelming. It also asked for more screens.

What changed:

- **Accent.** Ocean blue (`#005EEB`) replaces purple, and green stays reserved for money in. The notes board on the canvas shows tangerine and deep teal as alternatives.
- **Liquid Glass, iOS 27 style.** Glass is used only on controls (tab bar, toolbar buttons, sheets, chips, segmented controls). It follows iOS 27's refinements: a darker edge and a brighter highlight. Content stays on solid cards, as Apple recommends. Type is the system's SF Pro, with SF Pro Rounded for numbers; Inter and Outfit are web fallbacks.
- **A calmer Today.** It now shows only September's spent and came in, today's entries on the timeline, and the tab bar. The progress bar, AI tips and categories moved to Month. The Day/Month switch, the quiet-hour labels and the three capture buttons are gone.
- **iOS 27 tab bar.** The tabs are Today, Month and Search, plus Add as the one "prominent" tab, which is new in iOS 27.

| # | Screen | What it shows |
|---|---|---|
| 1 | Today | The spent and came-in card, today's timeline, and yesterday continuing under the glass tab bar. |
| 2 | Add | A glass sheet: hold to talk, type, screenshot, or "Log again" chips. |
| 3 | Listening | Words and detected entries appear as you speak, with a blue edge glow. Let go to finish. |
| 4 | Review | New entries placed on the timeline, a "second lunch?" check, and totals after saving. The sheet uses × and ✓. |
| 5 | Edit entry | Spent or received, the amount with − and +, category chips, a time ruler showing the day's other entries, note, split and delete. |
| 6 | Month | Spent vs came in with the 41% bar, a daily chart, an AI tip, and where it went. |
| 7 | Category: Food | September vs August, then entries by day. |
| 8 | Search | An AI answer ("9 Grab rides, RM 146.60"), filter chips, results, and the search field at the bottom. |
| 9 | From a screenshot | Reads a wallet screenshot, skips a row already logged, and leaves a reload out of spending. |
| 10 | Lock Screen | A Lock Screen control to log by voice, widgets, and a notification after saving. |
| 11 | Widgets and controls | Home Screen widgets with "Log again" buttons, a Control Center control, and the Action button. |

iOS 27 references: [How Liquid Glass is changing in iOS 27 (MacRumors)](https://www.macrumors.com/2026/06/10/how-liquid-glass-is-changing-in-ios-27/), [iOS 27 streamlines Liquid Glass (9to5Mac)](https://9to5mac.com/2026/05/12/ios-27-to-make-key-design-changes-to-streamline-liquid-glass-report/), [iOS 27 notable UIKit additions (prominent tab)](https://swiftjectivec.com/ios-27-notable-uikit-additions), [Build a SwiftUI app with the new design (WWDC25)](https://wwdcnotes.com/documentation/wwdc25-323-build-a-swiftui-app-with-the-new-design/).

## Round 6 · Tangerine & personality (Round 5, re-skinned)

Feedback on Round 5: much cleaner, but the font felt too default, and the strong blue made it look like a stock iPhone app rather than its own product. Round 6 keeps all 11 screens, the calmer Today and the iOS 27 glass, and changes two things:

- **Type with personality.** Titles, money amounts and the words you said use [Fraunces](https://fonts.google.com/specimen/Fraunces), a soft serif with a little wobble (its Soft and Wonky settings). Labels, lists and buttons use [Figtree](https://fonts.google.com/specimen/Figtree), which stays plain and readable at small sizes. The Lock Screen clock stays in Apple's font because it belongs to the system. The notes board also shows Bricolage Grotesque (playful) and Schibsted Grotesk (crisp, the font from N) as alternatives.
- **Light tangerine.** `#FFA552` is the main colour, used for the Add tab, ✓ buttons, chips, the "Now" marker and progress bars, always with dark text on top. Small tangerine text and icons use a deeper `#A84A0C` so they stay readable. AI tips and guesses sit on a `#FFF1E4` tint. Backgrounds stay a neutral soft white (`#F5F4F1`, no orange glow), so tangerine only marks things you can tap or should check. Money in stays green (`#1B6E30`). All text colours pass WCAG AA.

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

1–18 September 2026: in RM 5,200.00 (salary 4,800 + freelance 400), out RM 2,146.30. That splits into rent 900.00, food 486.40, groceries 238.90, transport 212.60, shopping 159.00 and bills 149.40, which is 41% of income spent and net +3,053.70. Where categories are coloured, each direction's palette passes colour-blind checks. Rounds 3 and 4 don't colour categories; Round 4 marks them with icons instead.

## Next steps

1. Review Round 6 (S in light tangerine with Fraunces): confirm the font and colour, then design the gaps (onboarding, the full categories list, settings, dark mode).
2. Prototype the parser on real utterances and screenshots (Manglish, DuitNow, e-wallet receipts) before polishing UI.
3. Build the SwiftUI app. This has started in [`ios/`](../../ios/README.md): every Round 6 screen, the widgets and the Siri intents are written, and the next step is getting the first build to pass on GitHub.
