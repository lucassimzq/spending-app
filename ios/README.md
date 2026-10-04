# Kira

A spending tracker for iPhone, built from the Round 6 design: the Timeline direction with iOS 27 Liquid Glass controls, a light tangerine accent, Fraunces for titles and money, and Figtree for everything else. The design (all six rounds, screenshots and HTML mocks) lives in the `spending-app` repo under `docs/design`.

Kira is a working name (Malay *kira*, "to count").

## What it does

- **Today**: this month's spent and came in, today's entries on a timeline with a Now marker, then yesterday.
- **Add**: tap to talk, type it like a text, or pick a banking or e-wallet screenshot. "Log again" chips re-log your regulars in one tap.
- **One sentence, several entries**: "lunch 12, grab 8.50, and Ali paid me back 20" becomes three entries, with money in kept apart.
- **Review**: new entries appear on the timeline before saving. Guessed times are marked, and a likely duplicate gets a question ("You logged Nasi lemak at 1:15 PM. Is this a second lunch?"). One clear entry skips this and saves straight away, with Undo.
- **Edit**: spent or received, the amount with − and +, category chips, a time ruler that shows the day's other entries, the day, a note, splitting, and delete. The same screen adds an entry by hand.
- **Month**: spent against came in, a daily chart, the pace compared with the calendar, and where it went. Each category opens a page that compares it with last month.
- **Search**: type it or ask it ("grab", "food last month"). An answer on top is worked out from the results ("9 Grab rides this month, RM 146.60 in total. That's about RM 16 a ride."), and chips narrow the results down.
- **From a screenshot**: Vision reads the text, rows you've already logged are skipped, and wallet reloads aren't counted as spending unless you say so.
- **Outside the app**: Siri ("Log in Kira", then say what you spent), App Shortcuts and the Action button ("Log by voice"), Home Screen and Lock Screen widgets with working "Log again" buttons, and Control Center controls for voice and screenshots.

Speech uses on-device recognition when the phone supports it, and Apple's speech service otherwise. Text recognition and the language model always run on the iPhone. Entries stay in the app's own storage, and Kira has no server of its own.

## Build and run

You need Xcode 26 or newer (iOS 26 SDK) and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
xcodegen generate
open Kira.xcodeproj
```

The Xcode project is generated from `project.yml`, so it isn't checked in. Run `xcodegen generate` again after adding or moving files.

Before running on a device, choose your team under Signing & Capabilities. Then replace the placeholder IDs with your own, in all three places:

- the bundle IDs `com.example.kira` and `com.example.kira.widgets` in `project.yml`,
- the App Group `group.com.example.kira` in `project.yml`,
- and the same App Group in `Kira/Shared/Persistence.swift`.

The app and its widgets share entries through that App Group. A build without it (such as an unsigned simulator build) still works, but the widgets won't see the app's entries.

**Sample data.** To look around with the month from the design, use **… → Load a sample month** on Today. You can also turn on the `-KiraSampleData YES` launch argument in the scheme (Edit Scheme → Run → Arguments), which loads it on launch when the app is empty. The sample is placed relative to today, so it only matches the design's exact numbers when today is the 18th. The KiraCore tests check those numbers against a fixed date.

**Tests.** The logic is a Swift package with its own tests:

```sh
swift test --package-path Packages/KiraCore
```

## How it's put together

```
Kira/
  App/           KiraApp, AppModel (state and actions), RootView, the glass tab bar, previews
  Shared/        Code the app and the widgets both use: the SwiftData model, storage, colours, fonts,
                 the "Log again" intent, the app mark
  Components/    Cards, money text, the timeline rail and entry cards, glass buttons, chips, toast
  Features/
    Today/       Today, a single day, and the go-to-a-day calendar
    Add/         The Add sheet: talk, type, screenshot, Log again
    Capture/     Listening (Speech framework), the interpreter (rules first, then Foundation Models), Review
    Edit/        The edit sheet and the time ruler
    Month/       Month, the daily bars, a category's page
    Search/      Search
    Scan/        Vision text recognition and the screenshot import sheet
  Intents/       Siri and Shortcuts: "Log in Kira" and "Log by voice"
  Resources/     Fonts (with their licences) and the asset catalog
KiraWidgets/     Widgets (Today, This month, Left per day) and Control Center controls
Packages/KiraCore/
                 Plain Swift with no UI: the sentence and screenshot parsers, month summaries, search
                 answers, duplicate checks, regulars, money formatting and the sample month. Unit-tested.
project.yml      XcodeGen spec for the app and widget targets
.github/         CI: KiraCore tests, then a full simulator build, on every push
```

**How text becomes entries.** KiraCore's rules run first. They're instant, work offline on every iPhone, and understand ringgit amounts in many shapes ("RM12.90", "eight fifty", "1.5k", "12 ringgit 50"), Manglish ("tapau nasi ayam 8"), money in ("salary", "paid me back"), and times from meal words ("lunch" means about 1 PM). Apple's on-device model (Foundation Models) steps in only when the rules find nothing, or can't place an entry in a category. It chooses from Kira's own category list, so it can't invent one. On iPhones without Apple Intelligence the rules do everything.

**Money** is stored in sen (an `Int`), so totals never pick up rounding errors.

**Fonts.** Fraunces and Figtree ship as variable fonts. Their default instances are Fraunces 9pt Black and Figtree Light, so `KiraFont` sets every axis explicitly: weight, optical size, and Fraunces' Soft and Wonky axes. Both scale with Dynamic Type.

## Status

This first version was written without a Mac. No Swift compiler was available, so **the app hasn't been compiled or run yet**. What was checked:

- Every Swift file passes a syntax check.
- The parser logic was first written and tested as a Python prototype, then ported to Swift with unit tests.
- Calls to the app's own views were checked mechanically for argument labels and their order.

The CI workflow is the first real compile. It runs the KiraCore tests and builds the app and widgets for the simulator on every push. Expect a few fixes on the first run, most likely around the newest iOS 26 APIs: the Liquid Glass modifiers (`glassEffect`, `GlassEffectContainer`) and Foundation Models.

## Differences from the design

- **Tap to talk** instead of hold to talk. Opening the listening screen closes the Add sheet, which would cancel a held press, and tapping is easier for many people. Listening stops when you tap the mic, or by itself after a three-second pause once it has heard an amount.
- **One clear entry saves straight away, with Undo.** Several entries, a guessed time or a possible duplicate open the review sheet, as designed.
- **Light mode only.** Dark mode isn't designed yet, so the app stays light.
- **Not built yet:** the share extension for screenshots, a notification after Siri saves, onboarding, settings, the full categories list, and iCloud sync.

## Licences

Fraunces and Figtree are used under the SIL Open Font License 1.1. The licence files are in `Kira/Resources/Fonts`.
