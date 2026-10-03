from r5 import *


def money(text, size, color, delay, animated, anims=None, label=None):
    n = sum(ch.isdigit() for ch in text)
    if not animated:
        anims = [None] * n
    return rolling(text, size, 800, color, delay, anims=anims, label=label, extra=f'font-family: {ROUND};')


def today_content(animated=True):
    d = (lambda x: x) if animated else (lambda x: None)
    summary = (
        f'<div style="height: 20px; display: flex; align-items: center; justify-content: space-between;"><span style="font-size: 15px; font-weight: 600; color: {SEC};">September</span>{chev()}</div>'
        f'<div style="margin-top: 10px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px;">'
        f'<div style="display: flex; flex-direction: column; gap: 4px;"><span style="font-size: 13px; font-weight: 600; color: {SEC};">Spent</span>'
        f'<span style="display: flex; align-items: flex-start; gap: 4px;"><span style="margin-top: 4px; font-size: 14px; font-weight: 700;">RM</span>{money("2,146.30", 28, INK, 0.2, animated, label="RM 2,146.30")}</span></div>'
        f'<div style="display: flex; flex-direction: column; gap: 4px;"><span style="font-size: 13px; font-weight: 600; color: {SEC};">Came in</span>'
        f'<span style="display: flex; align-items: flex-start; gap: 4px; color: {GREEN};"><span style="margin-top: 4px; font-size: 14px; font-weight: 700;">RM</span>{money("5,200.00", 28, GREEN, 0.3, animated, label="RM 5,200.00")}</span></div></div>'
    )
    anim_card = f' animation: rise 0.5s {EASE} 0.05s both;' if animated else ''
    return f'''
{toolbar_group([('calendar', 'Pick a day', None), ('ellipsis', 'More', None)])}
{large_title('Today', 'Friday, 18 September')}
<a href="TLMonth.dc.html" aria-label="September summary" style="position: absolute; top: 180px; left: 16px; right: 16px; height: 112px; box-sizing: border-box; padding: 16px 18px; border-radius: 26px; background: {CARD}; display: block;{anim_card}">{summary}</a>
<div style="position: absolute; top: 312px; left: 20px; right: 20px; height: 22px; display: flex; align-items: center; justify-content: space-between; font-size: 15px;">
<span style="font-weight: 600; color: {SEC};">Spent today</span><span style="font-weight: 700; font-variant-numeric: tabular-nums;">RM 46.10</span>
</div>
{rail(356, 123, d(0.3))}{rail(479, 140, d(0.62), dashed=True)}
{now_marker(344, animate=animated)}
{dot(409, d(0.45))}{tl_card(378, 'Food', 'Burger', 'Food · 7:42 PM', '5.00', delay=d(0.4))}
{dot(479, d(0.55))}{tl_card(448, 'Transport', 'Grab ride home', 'Transport · 6:20 PM', '18.70', delay=d(0.5))}
{dot(549, d(0.7))}{tl_card(518, 'Food', 'Nasi lemak + teh ais', 'Food · 1:15 PM', '9.50', delay=d(0.65))}
{dot(619, d(0.85))}{tl_card(588, 'Food', 'ZUS Coffee', 'Food · 8:42 AM', '12.90', delay=d(0.8))}
<div style="position: absolute; top: 672px; left: 20px; right: 20px; height: 22px; display: flex; align-items: center; justify-content: space-between; font-size: 15px;">
<span style="font-weight: 600; color: {SEC};">Yesterday</span><span style="font-weight: 700; font-variant-numeric: tabular-nums;">RM 94.80</span>
</div>
{rail(716, 128)}{dot(735)}{tl_card(704, 'Money in', 'Freelance · Hana Studio', 'Money in · 5:05 PM', '+400.00')}
'''


# ---------- 1 · Today ----------
html = page('Timeline · Today', today_content(True) + tabbar('Today'))
print('TLToday', write('TLToday.dc.html', html))

# ---------- 2 · Add sheet ----------
regulars = ''.join(
    gchip(f'<span style="color: {ACC}; display: flex;">{icon("plus", 16, 2.6)}</span>{n}<span style="font-weight: 800;">{a}</span>', delay=0.45 + i * 0.07)
    for i, (n, a) in enumerate([('Teh tarik', '2.80'), ('Grab', '15.00'), ('Lunch', '12.00')]))
add_sheet = f'''
<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(0,0,0,0.22); animation: fadeIn 0.3s ease-out both;"></div>
<section aria-label="Add" style="position: absolute; left: 8px; right: 8px; bottom: 8px; height: 420px; border-radius: 40px; {SHEET_GLASS} animation: sheetUp 0.6s {EASE} 0.05s both;">
{grabber(8)}
<div style="position: absolute; top: 18px; left: 16px; right: 16px; height: 44px; display: flex; align-items: center; justify-content: space-between;">
<span style="width: 44px;"></span><h1 style="margin: 0; font-size: 17px; font-weight: 700;">Add</h1>{gcircle("x", "Close", "TLToday.dc.html")}
</div>
<a href="TLListen.dc.html" aria-label="Hold to talk" style="position: absolute; top: 76px; left: 50%; width: 104px; height: 104px; margin-left: -52px; border-radius: 52px; {GLASS_TINT} display: flex; align-items: center; justify-content: center; animation: breathe 2.4s ease-in-out infinite;">
<span aria-hidden="true" style="position: absolute; inset: 0; border-radius: 52px; border: 2px solid rgba(0,94,235,0.45); animation: ripple 2.4s ease-out infinite;"></span>{icon("mic", 40, 2.2)}</a>
<span style="position: absolute; top: 192px; left: 0; right: 0; text-align: center; font-size: 17px; font-weight: 700;">Hold to talk</span>
<span style="position: absolute; top: 216px; left: 0; right: 0; text-align: center; font-size: 14px; color: {SEC};">Say a few at once: “lunch 12, grab 8.50”</span>
<div style="position: absolute; top: 252px; left: 16px; right: 16px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px;">
<a href="TLEdit.dc.html" style="height: 50px; border-radius: 25px; {GLASS} display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15px; font-weight: 600;">{icon("keyboard", 20, 2)}Type it</a>
<a href="TLScan.dc.html" style="height: 50px; border-radius: 25px; {GLASS} display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15px; font-weight: 600;">{icon("scan", 20, 2)}Screenshot</a>
</div>
<span style="position: absolute; top: 322px; left: 20px; font-size: 13px; font-weight: 600; color: {SEC};">Log again</span>
<div style="position: absolute; top: 342px; left: 0; right: 0; height: 52px; padding: 0 16px; display: flex; gap: 8px; overflow-x: auto; scrollbar-width: none;">{regulars}</div>
</section>
'''
html = page('Timeline · Add', '<div aria-hidden="true" inert>' + today_content(False) + tabbar('Today') + '</div>' + add_sheet)
print('TLAdd', write('TLAdd.dc.html', html))

# ---------- 3 · Listening ----------
words = ['lunch', '12,', 'grab', '8.50,', 'and', 'Ali', 'paid', 'me', 'back', '20']
said = ' '.join(f'<span style="{("color: " + ACC + ";") if w in ("12,", "8.50,", "20") else ""} animation: fadeIn 0.25s ease-out {0.3 + i * 0.13:.2f}s both;">{w}</span>' for i, w in enumerate(words))
bars = ''.join(f'<span style="width: 3px; height: 16px; border-radius: 2px; background: {ACC}; animation: wave {0.7 + (i % 3) * 0.15:.2f}s ease-in-out {i * 0.09:.2f}s infinite;"></span>' for i in range(5))
heard = (gchip(f'{icon("food", 16, 2)}Lunch<span style="font-weight: 800;">12.00</span>', delay=1.0)
         + gchip(f'{icon("car", 16, 2)}Grab<span style="font-weight: 800;">8.50</span>', delay=1.35)
         + gchip(f'<span style="color: {GREEN}; display: flex;">{icon("in", 16, 2.2)}</span>Ali paid you back<span style="font-weight: 800; color: {GREEN};">+20.00</span>', delay=1.9))
listen = f'''
<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(242,242,247,0.5); -webkit-backdrop-filter: blur(26px) saturate(160%); backdrop-filter: blur(26px) saturate(160%); animation: fadeIn 0.35s ease-out both;"></div>
<div aria-hidden="true" style="position: absolute; inset: 0; pointer-events: none; box-shadow: inset 0 0 26px 6px rgba(0,94,235,0.5), inset 0 0 80px 16px rgba(64,156,255,0.32), inset 0 0 150px 30px rgba(90,200,250,0.18); animation: glow 2.4s ease-in-out infinite;"></div>
<div style="position: absolute; top: 54px; left: 16px; right: 16px; height: 44px; display: flex; align-items: center; justify-content: space-between;">
<span style="height: 44px; padding: 0 16px; border-radius: 22px; {GLASS} display: flex; align-items: center; gap: 10px; font-size: 15px; font-weight: 700;"><span aria-hidden="true" style="height: 16px; display: flex; align-items: center; gap: 3px;">{bars}</span>Listening</span>
<a href="TLToday.dc.html" style="height: 44px; padding: 0 18px; border-radius: 22px; {GLASS} display: flex; align-items: center; font-size: 15px; font-weight: 600;">Cancel</a>
</div>
<p style="position: absolute; top: 140px; left: 24px; right: 24px; margin: 0; font-size: 30px; line-height: 38px; font-weight: 700; letter-spacing: -0.01em;">{said}</p>
<span style="position: absolute; top: 284px; left: 24px; font-size: 13px; font-weight: 600; color: {SEC};">Heard so far</span>
<div style="position: absolute; top: 306px; left: 24px; right: 16px; display: flex; flex-wrap: wrap; gap: 8px;">{heard}</div>
<p style="position: absolute; top: 424px; left: 24px; right: 24px; margin: 0; font-size: 14px; line-height: 20px; color: {SEC};">Keep talking to add more. Let go when you’re done.</p>
<a href="TLReview.dc.html" aria-label="Release to finish" style="position: absolute; top: 600px; left: 50%; width: 104px; height: 104px; margin-left: -52px; border-radius: 52px; {GLASS_TINT} display: flex; align-items: center; justify-content: center; transform: scale(1.06);">
<span aria-hidden="true" style="position: absolute; inset: 0; border-radius: 52px; background: rgba(0,94,235,0.25); animation: ripple 1.6s ease-out infinite;"></span>
<span aria-hidden="true" style="position: absolute; inset: 0; border-radius: 52px; background: rgba(0,94,235,0.2); animation: ripple 1.6s ease-out 0.8s infinite;"></span>{icon("mic", 40, 2.2)}</a>
<span style="position: absolute; top: 724px; left: 0; right: 0; text-align: center; font-size: 15px; font-weight: 600; color: {SEC};">Release to finish</span>
'''
html = page('Timeline · Listening', '<div aria-hidden="true" inert>' + today_content(False) + tabbar('Today') + '</div>' + listen)
print('TLListen', write('TLListen.dc.html', html))


# ---------- large-sheet helpers ----------
def behind():
    # The presenting screen shrinks back and dims, the way iOS stacks a full-height sheet.
    return (f'<div aria-hidden="true" inert style="position: absolute; inset: 0; border-radius: 38px; overflow: hidden; background: {WASH}; transform: translateY(10px) scale(0.92); transform-origin: top center;">'
            f'{today_content(False)}{tabbar("Today")}<div style="position: absolute; inset: 0; background: rgba(0,0,0,0.28);"></div></div>')


def big_sheet(inner, label_text):
    return (f'<section aria-label="{label_text}" style="position: absolute; top: 54px; left: 0; right: 0; bottom: 0; border-radius: 38px 38px 0 0; background: {BG}; '
            f'box-shadow: 0 -1px 0 rgba(255,255,255,0.6), 0 -8px 30px rgba(0,0,0,0.25); animation: sheetUp 0.6s {EASE} 0.05s both;">{grabber(6)}{inner}</section>')


# ---------- 4 · Review ----------
b = lambda t: f'<b style="font-weight: 700; color: {ACC};">{t}</b>'


def saved_row(top, time, name, amount):
    return (f'<div style="position: absolute; top: {top}px; left: 52px; right: 16px; height: 26px; display: flex; align-items: center; gap: 10px; font-size: 14px; color: {SEC};">'
            f'<span style="width: 58px; font-size: 12px;">{time}</span><span style="flex-grow: 1;">{name}</span><span style="font-variant-numeric: tabular-nums;">{amount}</span></div>')

totals = (
    f'<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px;">'
    f'<div style="display: flex; flex-direction: column; gap: 3px;"><span style="font-size: 13px; font-weight: 600; color: {SEC};">Spent after saving</span>'
    f'<span style="display: flex; align-items: flex-start; gap: 4px;"><span style="margin-top: 3px; font-size: 13px; font-weight: 700;">RM</span>{rolling("2,166.80", 22, 800, INK, anims=[None, None, "r46 0.9s cubic-bezier(.2,1.3,.4,1) 1.2s both", None, "r38 1.1s cubic-bezier(.2,1.3,.4,1) 1.2s both", None], label="RM 2,166.80", extra=f"font-family: {ROUND};")}</span>'
    f'<span style="font-size: 12px; font-weight: 600; color: {SEC};">+20.50</span></div>'
    f'<div style="display: flex; flex-direction: column; gap: 3px;"><span style="font-size: 13px; font-weight: 600; color: {SEC};">Came in after saving</span>'
    f'<span style="display: flex; align-items: flex-start; gap: 4px; color: {GREEN};"><span style="margin-top: 3px; font-size: 13px; font-weight: 700;">RM</span>{rolling("5,220.00", 22, 800, GREEN, anims=[None, None, "r02 0.9s cubic-bezier(.2,1.3,.4,1) 1.3s both", None, None, None], label="RM 5,220.00", extra=f"font-family: {ROUND};")}</span>'
    f'<span style="font-size: 12px; font-weight: 600; color: {GREEN};">+20.00</span></div></div>'
)
review_inner = f'''
{sheet_toolbar('3 new entries', 'TLToday.dc.html', 'TLToday.dc.html')}
<div style="position: absolute; top: 72px; left: 16px; right: 16px; box-sizing: border-box; padding: 12px 14px; border-radius: 18px; background: {CARD}; display: flex; align-items: flex-start; gap: 10px;">
<span style="flex-shrink: 0; width: 28px; height: 28px; border-radius: 14px; background: {ACC_TINT}; color: {ACC}; display: flex; align-items: center; justify-content: center;">{icon("mic", 15, 2.2)}</span>
<p style="margin: 0; font-size: 15px; line-height: 21px;">“lunch {b("12")}, grab {b("8.50")}, and Ali paid me back {b("20")}”</p>
</div>
{rail(170, 289, 0.25)}
{now_marker(158)}
{dot(221, 0.4, ACC)}{tl_card(190, 'Transport', 'Grab', 'Transport · just now', '8.50', delay=0.4, new=True, extra_tags=tag('New'))}
{dot(289, 0.55, ACC)}{tl_card(258, 'Money in', 'Ali paid you back', 'Money in · just now', '+20.00', delay=0.55, new=True, extra_tags=tag('New'))}
{dot(343, 0.6, DOT, 8)}{saved_row(330, '7:42 PM', 'Burger', '5.00')}
{dot(373, 0.65, DOT, 8)}{saved_row(360, '6:20 PM', 'Grab ride home', '18.70')}
{dot(403, 0.7, DOT, 8)}{saved_row(390, '1:15 PM', 'Nasi lemak + teh ais', '9.50')}
{dot(459, 0.85, ACC)}{tl_card(428, 'Food', 'Lunch', 'Food', '12.00', delay=0.85, new=True, extra_tags=tag('1:00 PM · guessed'))}
<div style="position: absolute; top: 498px; left: 52px; right: 16px; box-sizing: border-box; padding: 12px 14px; border-radius: 18px; background: {CARD}; animation: rise 0.45s {EASE} 1.1s both;">
<p style="margin: 0; display: flex; gap: 8px; font-size: 14px; line-height: 19px; font-weight: 600;"><span style="flex-shrink: 0; color: {ACC}; display: flex;">{icon("copy", 17, 2)}</span>You logged Nasi lemak at 1:15 PM. Is this a second lunch?</p>
<div style="margin-top: 10px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px;">
<button type="button" style="height: 44px; border: 0; border-radius: 22px; {GLASS_TINT} font-size: 15px; font-weight: 600;">Yes, keep it</button>
<button type="button" style="height: 44px; border: 0; border-radius: 22px; {GLASS} font-size: 15px; font-weight: 600;">No, remove</button>
</div>
</div>
<div style="position: absolute; top: 630px; left: 16px; right: 16px; box-sizing: border-box; padding: 12px 16px; border-radius: 18px; background: {CARD};">{totals}</div>
<span style="position: absolute; top: 732px; left: 20px; font-size: 13px; color: {SEC};">Tap an entry to fix it before saving.</span>
'''
html = page('Timeline · Review', behind() + big_sheet(review_inner, 'Review new entries'), root_bg='#000000')
print('TLReview', write('TLReview.dc.html', html))

# ---------- 5 · Edit entry ----------
PX = 326 / 14
x = lambda hr: (hr - 8) * PX
markers = ''.join(
    f'<span aria-hidden="true" style="position: absolute; top: 35px; left: {x(hh) - 0.5:.1f}px; width: 1px; height: 9px; background: {DOT};"></span>'
    f'<span aria-hidden="true" style="position: absolute; top: 44px; left: {x(hh) - 4:.1f}px; width: 8px; height: 8px; border-radius: 4px; background: {DOT};"></span>'
    for hh in (8.7, 13.25, 18.333, 19.7))
hours = ''.join(
    f'<span style="position: absolute; top: 58px; left: {x(hh):.1f}px; transform: translateX({"0" if hh == 8 else "-50%"}); font-size: 11px; font-weight: 500; color: {SEC};">{t}</span>'
    for hh, t in [(8, '8 AM'), (12, '12 PM'), (16, '4 PM'), (20, '8 PM')])
ruler = (f'<div style="position: relative; margin-top: 12px; height: 74px;">'
         f'<span aria-hidden="true" style="position: absolute; top: 33px; left: 0; right: 0; height: 2px; border-radius: 1px; background: {RAIL};"></span>{markers}{hours}'
         f'<span style="position: absolute; top: 0; left: {x(13) - 30:.1f}px; width: 60px; animation: knob 1.1s {EASE} 0.5s both;">'
         f'<span style="display: block; text-align: center; font-size: 11px; font-weight: 700; color: {ACC};">1:00 PM</span>'
         f'<button type="button" aria-label="Drag to change the time" style="position: absolute; top: 12px; left: 8px; width: 44px; height: 44px; padding: 0; border: 0; background: transparent; display: flex; align-items: center; justify-content: center;">'
         f'<span style="width: 28px; height: 22px; border-radius: 11px; {GLASS} background: #FFFFFF; box-shadow: inset 0 0 0 0.5px rgba(0,0,0,0.2), 0 2px 8px rgba(0,0,0,0.18), 0 0 0 3px {ACC};"></span></button></span></div>')


def cat_chip(name, selected=False):
    return gchip(f'{icon(CAT_ICON[name], 16, 2)}{name}', tint=selected, extra='padding: 0 16px 0 14px;')


def list_row(icon_name, text, right, last=False):
    sep = '' if last else f' box-shadow: inset 0 -0.5px 0 {SEP};'
    return (f'<button type="button" style="width: 100%; height: 52px; padding: 0; border: 0; background: transparent; display: flex; align-items: center; gap: 12px; text-align: left;">'
            f'<span style="flex-shrink: 0; width: 30px; height: 30px; border-radius: 8px; background: {TILE}; display: flex; align-items: center; justify-content: center;">{icon(icon_name, 16, 2)}</span>'
            f'<span style="flex-grow: 1; height: 52px; display: flex; align-items: center; justify-content: space-between;{sep}"><span style="font-size: 16px;">{text}</span><span style="display: flex; align-items: center; gap: 6px; padding-right: 2px;">{right}</span></span></button>')

edit_inner = f'''
{sheet_toolbar('Edit entry', 'TLToday.dc.html', 'TLToday.dc.html')}
<div style="position: absolute; top: 72px; left: 16px; right: 16px;">{segmented(['Spent', 'Received'])}</div>
<div style="position: absolute; top: 128px; left: 16px; right: 16px; height: 60px; display: flex; align-items: center; justify-content: space-between;">
{gcircle('minus', 'Minus one ringgit')}
<label style="display: flex; align-items: center; gap: 6px;"><span style="font-size: 18px; font-weight: 700; color: {SEC};">RM</span><input type="text" inputmode="decimal" value="12.00" aria-label="Amount" style="width: 140px; height: 56px; padding: 0; border: 0; outline: none; background: transparent; font-family: {ROUND}; font-size: 48px; font-weight: 800; letter-spacing: -0.02em; font-variant-numeric: tabular-nums;"></label>
{gcircle('plus', 'Plus one ringgit')}
</div>
<label style="position: absolute; top: 204px; left: 16px; right: 16px; height: 52px; box-sizing: border-box; padding: 0 16px; border-radius: 16px; background: {CARD}; display: flex; align-items: center; gap: 12px;">
<span style="font-size: 16px; color: {SEC};">What</span><input type="text" value="Lunch" style="flex-grow: 1; min-width: 0; height: 44px; padding: 0; border: 0; outline: none; background: transparent; font-size: 16px; font-weight: 600;">
</label>
<span style="position: absolute; top: 272px; left: 20px; font-size: 13px; font-weight: 600; color: {SEC};">Category</span>
<div role="group" aria-label="Category" style="position: absolute; top: 290px; left: 0; right: 0; height: 52px; padding: 0 16px; display: flex; gap: 8px; overflow-x: auto; scrollbar-width: none;">{cat_chip('Food', True)}{cat_chip('Groceries')}{cat_chip('Transport')}{cat_chip('Shopping')}{cat_chip('Bills')}{cat_chip('Rent')}</div>
<section style="position: absolute; top: 352px; left: 16px; right: 16px; box-sizing: border-box; padding: 16px; border-radius: 22px; background: {CARD};">
<div style="display: flex; align-items: center; justify-content: space-between;"><span style="font-size: 16px; color: {SEC};">When</span><span style="display: flex; align-items: center; gap: 6px; font-size: 16px; font-weight: 700;">Today · 1:00 PM{tag('Guessed')}</span></div>
{ruler}
<p style="margin: 6px 0 0 0; font-size: 13px; line-height: 18px; color: {SEC};">Dots are your other entries today. Nasi lemak is at 1:15 PM, so check this isn’t the same lunch.</p>
</section>
<div style="position: absolute; top: 546px; left: 16px; right: 16px; box-sizing: border-box; padding: 0 14px; border-radius: 16px; background: {CARD};">
{list_row('note', 'Note', f'<span style="font-size: 16px; color: {SEC};">Add</span>{chev()}')}
{list_row('users', 'Split with someone', chev(), last=True)}
</div>
<button type="button" style="position: absolute; top: 667px; left: 16px; right: 16px; height: 52px; border: 0; border-radius: 16px; background: {CARD}; color: {RED}; font-size: 16px; font-weight: 600;">Delete entry</button>
'''
html = page('Timeline · Edit entry', behind() + big_sheet(edit_inner, 'Edit entry'), root_bg='#000000')
print('TLEdit', write('TLEdit.dc.html', html))
