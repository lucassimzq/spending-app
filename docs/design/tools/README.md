# Design tools

Scripts that generate the Round 5 and Round 6 boards in [`../mocks/`](../mocks/) and render the PNGs in [`../screenshots/`](../screenshots/README.md).

| File | What it does |
|---|---|
| `r6.py` | **Round 6 (chosen design) look:** colours, Fraunces + Figtree, Liquid Glass styles, tab bar, sheets, timeline parts. |
| `r6_core.py`, `r6_more.py`, `r6_system.py`, `r6_notes.py` | Round 6 screens: Today, Add, Listening, Review, Edit (core); Month, Food, Search, Screenshot (more); Lock Screen and widgets (system); the notes board. |
| `r5*.py` | The same screens in Round 5's look (blue, system font). |
| `r4.py`, `reels.py` | Shared icons, page wrapper and the rolling-number helper. |
| `shoot.mjs` | Renders boards listed in `../mocks/canvas.json` to PNG with Playwright. |

## Regenerate Round 6

```sh
cd docs/design/tools
python3 r6_more.py     # also rebuilds the five core screens
python3 r6_system.py
python3 r6_notes.py
```

To change the colours or fonts, edit the constants at the top of `r6.py` and rerun the three commands. The scripts write straight into `../mocks/`. Rounds 1–4 were made by hand or with one-off scripts, so edit those boards' HTML directly.

## Render screenshots

```sh
cd docs/design/tools
NODE_USE_ENV_PROXY=1 node shoot.mjs ../mocks ../screenshots round6 'round6=3,*=1'
```

- The third argument is `all`, a page id such as `round6`, or a comma list of board files. The fourth is the scale, either one number or per page.
- It needs Node with Playwright and Chromium.
- Node fetches Google Fonts itself and hands them to the browser, so it works behind a TLS-inspecting proxy as long as Node trusts the proxy's certificate (`NODE_EXTRA_CA_CERTS`). `NODE_USE_ENV_PROXY=1` makes Node's `fetch` use `HTTPS_PROXY`.
- Reduce Motion is on, so every animation shows its final state.

The live canvas is separate: after changing boards, publish the changed `../mocks/*.dc.html` files to the canvas artifact.
