from r5 import *


def li(icon_name, color, text):
    return (f'<li style="display: flex; gap: 10px; font-size: 14px; line-height: 20px;"><span style="flex-shrink: 0; margin-top: 1px; width: 20px; height: 20px; border-radius: 10px; '
            f'background: {color}; color: #FFFFFF; display: flex; align-items: center; justify-content: center;">{icon(icon_name, 12, 3)}</span><span>{text}</span></li>')


def group(title, items):
    return (f'<div style="display: flex; flex-direction: column; gap: 8px;"><span style="font-size: 12px; font-weight: 700; letter-spacing: 0.06em; color: {SEC};">{title}</span>'
            f'<ul style="margin: 0; padding: 0; list-style: none; display: flex; flex-direction: column; gap: 8px;">{"".join(items)}</ul></div>')


CARD_ST = f'box-sizing: border-box; padding: 24px; border-radius: 28px; background: {CARD}; display: flex; flex-direction: column; gap: 16px;'

calmer = (f'<div style="{CARD_ST}"><div><h2 style="margin: 0; font-size: 22px; font-weight: 800;">A calmer Today</h2>'
          f'<span style="font-size: 14px; color: {SEC};">Three things on screen instead of ten.</span></div>'
          + group('KEPT', [li('check', GREEN, 'September’s <b>Spent</b> and <b>Came in</b>, in one card'), li('check', GREEN, 'Today’s entries on the timeline'), li('check', GREEN, 'One <b>Add</b> button in the tab bar')])
          + group('MOVED ONE TAP AWAY, TO MONTH', [li('arrowout', ACC, 'The 41% progress bar and RM left'), li('arrowout', ACC, 'AI tips, like “food is RM 61 under August”'), li('arrowout', ACC, 'Categories')])
          + group('REMOVED', [li('minus', SEC, 'The Day / Month switch (Month is a tab now)'), li('minus', SEC, '“5 hours, nothing spent” labels (the dashed line says it quietly)'), li('minus', SEC, 'Three capture buttons (Add opens talk, type and screenshot)')])
          + '</div>')


def mini_tabbar():
    items = ''
    for name, ic, on in [('Today', 'timeline', True), ('Month', 'chart', False), ('Search', 'search', False)]:
        bg = ' background: rgba(120,120,128,0.16);' if on else ''
        items += (f'<span style="flex: 1; height: 48px; border-radius: 24px;{bg} color: {ACC if on else INK}; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px; font-size: 10px; font-weight: 600;">{icon(ic, 20, 2.1)}{name}</span>')
    add = (f'<span style="flex-shrink: 0; width: 70px; height: 48px; border-radius: 24px; {GLASS_TINT} display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px; font-size: 10px; font-weight: 700;">{icon("plus", 20, 2.6)}Add</span>')
    return f'<div aria-hidden="true" style="height: 60px; box-sizing: border-box; padding: 6px; border-radius: 30px; {GLASS} display: flex; align-items: center; gap: 4px;">{items}{add}</div>'


def sample(inner, caption):
    return (f'<div style="display: flex; flex-direction: column; gap: 8px;"><div style="padding: 14px; border-radius: 20px; background: {WASH}; display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">{inner}</div>'
            f'<span style="font-size: 13px; line-height: 18px; color: {SEC};">{caption}</span></div>')

PLUS_SPAN = '<span style="color: ' + ACC + '; display: flex;">' + icon('plus', 16, 2.6) + '</span>'
CHIP_A = gchip(PLUS_SPAN + 'Teh tarik<b style="font-weight: 800;">2.80</b>')
CHIP_B = gchip(icon('food', 16, 2) + 'Food', tint=True)

parts = (f'<div style="{CARD_ST}"><div><h2 style="margin: 0; font-size: 22px; font-weight: 800;">iOS 27 parts</h2>'
         f'<span style="font-size: 14px; color: {SEC};">Glass for controls, solid cards for your data.</span></div>'
         + sample(f'<div style="flex-grow: 1;">{mini_tabbar()}</div>', 'Tab bar with one prominent tab, new in iOS 27. Ours is Add.')
         + sample(f'<span aria-hidden="true" style="height: 44px; border-radius: 22px; {GLASS} display: flex;"><span style="width: 46px; display: flex; align-items: center; justify-content: center;">{icon("calendar", 20, 2.2)}</span><span style="width: 46px; display: flex; align-items: center; justify-content: center;">{icon("ellipsis", 20, 2.2)}</span></span>'
                  f'<span aria-hidden="true" style="width: 44px; height: 44px; border-radius: 22px; {GLASS} display: flex; align-items: center; justify-content: center;">{icon("x", 20, 2.2)}</span>'
                  f'<span aria-hidden="true" style="width: 44px; height: 44px; border-radius: 22px; {GLASS_TINT} display: flex; align-items: center; justify-content: center;">{icon("check", 20, 2.4)}</span>'
                  f'<span style="margin-left: auto;">{toggle(True, "Example switch")}</span>',
                  'Grouped toolbar buttons, × and ✓ on sheets, and the capsule switch.')
         + sample(f'<div style="flex-grow: 1;">{segmented(["Spent", "Received"], label="Example")}</div>' + CHIP_A + CHIP_B,
                  'Glass segmented control and chips for quick choices.')
         + f'<span style="margin-top: auto; font-size: 13px; line-height: 18px; color: {SEC};">iOS 27 glass has a darker edge and a brighter highlight. Apple keeps glass for controls, so cards stay solid and easy to read.</span>'
         + '</div>')


def accent_row(name, hex_, note, chosen=False, dark_text=False):
    fg = INK if dark_text else '#FFFFFF'
    btn = (f'<span aria-hidden="true" style="height: 44px; padding: 0 18px; border-radius: 22px; background: linear-gradient(155deg, rgba(255,255,255,0.34) 0%, rgba(255,255,255,0.06) 42%, rgba(255,255,255,0) 62%, rgba(255,255,255,0.14) 100%), {hex_}; '
           f'box-shadow: inset 0 0 0 0.5px rgba(0,0,0,0.28), inset 1.5px 1.5px 1px -0.5px rgba(255,255,255,0.75), 0 6px 16px rgba(0,0,0,0.14); color: {fg}; display: flex; align-items: center; gap: 6px; font-size: 15px; font-weight: 700;">{icon("plus", 18, 2.6)}Add</span>')
    ring = f' box-shadow: inset 0 0 0 2px {ACC};' if chosen else f' box-shadow: inset 0 0 0 1px {SEP};'
    badge = f'<span style="margin-left: auto; height: 24px; padding: 0 10px; border-radius: 12px; background: {ACC}; color: #FFFFFF; display: flex; align-items: center; font-size: 12px; font-weight: 700;">In the mocks</span>' if chosen else ''
    return (f'<div style="padding: 14px; border-radius: 20px;{ring} display: flex; flex-direction: column; gap: 10px;">'
            f'<div style="display: flex; align-items: center; gap: 10px;"><span style="width: 28px; height: 28px; border-radius: 14px; background: {hex_};"></span><b style="font-size: 16px;">{name}</b>{badge}</div>'
            f'<div style="display: flex; align-items: center; gap: 12px;">{btn}<span style="font-size: 13px; line-height: 18px; color: {SEC};">{note}</span></div></div>')

accent = (f'<div style="{CARD_ST}"><div><h2 style="margin: 0; font-size: 22px; font-weight: 800;">Purple is out</h2>'
          f'<span style="font-size: 14px; color: {SEC};">One accent for buttons, “Now” and AI guesses.</span></div>'
          + accent_row('Ocean blue', ACC, 'Feels native to iOS and keeps green free for money in.', chosen=True)
          + accent_row('Tangerine', '#FF9500', 'Warmer and friendlier. Needs dark text on buttons.', dark_text=True)
          + accent_row('Deep teal', '#0E7490', 'Calm and less common, but sits closer to the money-in green.')
          + f'<span style="margin-top: auto; font-size: 13px; line-height: 18px; color: {SEC};">Prefer orange or teal? Tell me and I’ll swap it on every screen.</span>'
          + '</div>')

body = f'''
<div style="position: absolute; inset: 0; box-sizing: border-box; padding: 52px 56px; display: flex; flex-direction: column;">
<span style="display: flex; align-items: center; gap: 8px; font-size: 12px; font-weight: 700; letter-spacing: 0.12em; color: {SEC};"><span style="width: 8px; height: 8px; border-radius: 4px; background: {ACC}; animation: blink 1.2s steps(1) infinite;"></span>ROUND 5 · S, REFINED</span>
<h1 style="margin: 10px 0 0 0; font-size: 48px; line-height: 54px; font-weight: 800; letter-spacing: -0.02em;">Timeline, rebuilt for iOS 27</h1>
<p style="margin: 10px 0 0 0; max-width: 1040px; font-size: 17px; line-height: 24px; color: {SEC};">You picked S. Purple is gone, every button is Apple’s Liquid Glass, and Today now shows only what you asked for: what you spent, what came in, and today’s entries. Everything else is one tap away, and there are 11 screens to click through.</p>
<div style="margin-top: 26px; flex-grow: 1; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 20px;">{calmer}{parts}{accent}</div>
<div style="margin-top: 20px; min-height: 48px; box-sizing: border-box; padding: 12px 18px; border-radius: 16px; background: {INK}; color: #FFFFFF; display: flex; align-items: center; gap: 14px; font-size: 15px; line-height: 22px;">
<span style="flex-shrink: 0; font-size: 12px; font-weight: 700; letter-spacing: 0.12em; color: #C7C7CC;">11 SCREENS</span>
<span>Today · Add · Listening · Review · Edit · Month · Food · Search · Screenshot · Lock Screen · Widgets and controls</span>
</div>
</div>
'''
print('TLNotes', write('TLNotes.dc.html', page('What changed from S', body, root_bg=WASH, w=1368, h=900)))
