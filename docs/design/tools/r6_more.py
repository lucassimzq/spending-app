from r6 import *
from r6_core import behind, big_sheet, money, list_row  # noqa: E402  (re-generates core boards on import, harmless)

LAB = f'font-size: 13px; font-weight: 600; color: {SEC};'

# ---------- 6 · Month ----------
DAILY = [918.5, 38.2, 26.8, 64.3, 186.4, 88.9, 21.4, 47.1, 19.8, 156.3, 33.6, 71.9, 158.4, 24.7, 52.3, 96.8, 94.8, 46.1]
H = 112
bars = ''
for day in range(1, 31):
    if day <= 18:
        v = DAILY[day - 1]
        h = min(H, round(v / 200 * H))
        color = BAR if day == 18 else BAR_SOFT
        bars += (f'<span style="position: relative; width: 6px; height: {h}px; border-radius: 3px; background: {color}; transform-origin: bottom center; '
                 f'animation: growUp 0.5s {EASE} {0.3 + day * 0.03:.2f}s both;">'
                 + ('<span style="position: absolute; left: 0; right: 0; top: 30px; height: 3px; background: #FFFFFF;"></span>' if v > 200 else '')
                 + '</span>')
    else:
        bars += f'<span style="width: 6px; height: 4px; border-radius: 2px; background: {SEP};"></span>'
avg_y = H - 69.24 / 200 * H
chart = (f'<div style="height: 20px; display: flex; align-items: center; justify-content: space-between;"><span style="font-size: 15px; font-weight: 700;">Daily spending</span>'
         f'<span style="font-size: 13px; color: {SEC};">RM 69 a day, without rent</span></div>'
         f'<div role="img" aria-label="Daily spending for September. Biggest day: 1 September, rent. Today: RM 46.10." style="position: relative; margin-top: 12px; height: {H}px;">'
         f'<span aria-hidden="true" style="position: absolute; left: 0; right: 0; top: {avg_y:.0f}px; border-top: 1.5px dashed rgba(60,60,67,0.3);"></span>'
         f'<span style="position: absolute; left: 12px; top: 0; font-size: 11px; font-weight: 600; color: {SEC};">Rent day</span>'
         f'<div style="position: absolute; inset: 0; display: flex; align-items: flex-end; justify-content: space-between;">{bars}</div></div>'
         f'<div style="position: relative; margin-top: 6px; height: 14px; font-size: 11px; color: {SEC};">'
         + ''.join(f'<span style="position: absolute; left: {i * (322 - 6) / 29 + 3:.1f}px; transform: translateX(-50%); white-space: nowrap;{" font-weight: 700; color: " + ACC_DEEP + ";" if t == "18" else ""}">{t}</span>'
                   for i, t in [(0, '1'), (7, '8'), (14, '15'), (17, '18'), (21, '22'), (29, '30')])
         + '</div>')
hero = (f'<div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px;">'
        f'<div style="display: flex; flex-direction: column; gap: 4px;"><span style="{LAB}">Spent</span><span style="display: flex; align-items: flex-start; gap: 4px;"><span style="margin-top: 4px; font-size: 14px; font-weight: 700;">RM</span>{money("2,146.30", 28, INK, 0.2, True, label="RM 2,146.30")}</span></div>'
        f'<div style="display: flex; flex-direction: column; gap: 4px;"><span style="{LAB}">Came in</span><span style="display: flex; align-items: flex-start; gap: 4px; color: {GREEN};"><span style="margin-top: 4px; font-size: 14px; font-weight: 700;">RM</span>{money("5,200.00", 28, GREEN, 0.3, True, label="RM 5,200.00")}</span></div></div>'
        f'<div style="margin-top: 14px; height: 8px; border-radius: 4px; background: rgba(120,100,80,0.16); overflow: hidden;"><span style="display: block; width: 41%; height: 8px; border-radius: 4px; background: {ACC}; transform-origin: left center; animation: spring 1.1s cubic-bezier(.3,.7,.3,1) 0.5s both;"></span></div>'
        f'<div style="margin-top: 8px; display: flex; justify-content: space-between; font-size: 13px;"><span style="font-weight: 600;">41% of income spent</span><span style="color: {SEC};">RM 3,053.70 left</span></div>')


def cat_row(cat, name, sub, amount, pct, href=None, last=False):
    sep = '' if last else f' box-shadow: inset 0 -0.5px 0 {SEP};'
    tagname, attrs = ('a', f' href="{href}"') if href else ('div', '')
    return (f'<{tagname}{attrs} style="height: 58px; display: flex; align-items: center; gap: 12px;">{itile(cat, 34)}'
            f'<span style="flex-grow: 1; min-width: 0; height: 58px; display: flex; align-items: center; gap: 10px;{sep}">'
            f'<span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 5px;"><span style="display: flex; justify-content: space-between; gap: 8px;"><span style="font-size: 15px; font-weight: 600;">{name}</span>'
            f'<span style="font-size: 15px; font-weight: 600; font-variant-numeric: tabular-nums;">{amount}</span></span>'
            f'<span style="height: 4px; border-radius: 2px; background: rgba(120,100,80,0.14); overflow: hidden;"><span style="display: block; width: {pct}%; height: 4px; border-radius: 2px; background: {ACC}; transform-origin: left center; animation: grow 0.8s {EASE} 0.9s both;"></span></span>'
            f'<span style="font-size: 12px; color: {SEC};">{sub}</span></span>'
            f'{chev() if href else ""}</span></{tagname}>')

month = f'''
{toolbar_group([('calendar', 'Pick a month', None), ('share', 'Share', None)])}
{large_title('September', '1–18 Sep · 12 days left')}
<section style="position: absolute; top: 180px; left: 16px; right: 16px; height: 128px; box-sizing: border-box; padding: 16px 18px; border-radius: 26px; background: {CARD}; animation: rise 0.5s {EASE} 0.05s both;">{hero}</section>
<section style="position: absolute; top: 320px; left: 16px; right: 16px; height: 196px; box-sizing: border-box; padding: 16px 18px; border-radius: 26px; background: {CARD}; animation: rise 0.5s {EASE} 0.12s both;">{chart}</section>
<div style="position: absolute; top: 528px; left: 16px; right: 16px; height: 64px; box-sizing: border-box; padding: 0 16px; border-radius: 20px; background: {ACC_TINT}; display: flex; align-items: center; gap: 12px; animation: rise 0.5s {EASE} 0.2s both;">
<span style="flex-shrink: 0; color: {ACC_DEEP}; display: flex;">{icon("sparkle", 20, 2)}</span><span style="font-size: 14px; line-height: 19px; font-weight: 600;">Spending slower than the month: 41% of income gone, 60% of September gone.</span>
</div>
<section style="position: absolute; top: 604px; left: 16px; right: 16px; box-sizing: border-box; padding: 4px 16px 0 16px; border-radius: 26px; background: {CARD}; animation: rise 0.5s {EASE} 0.28s both;">
<div style="height: 44px; display: flex; align-items: center; justify-content: space-between;"><span style="font-size: 15px; font-weight: 700;">Where it went</span>
<button type="button" style="height: 44px; padding: 0; border: 0; background: transparent; display: flex; align-items: center; gap: 2px; font-size: 15px; color: {ACC_DEEP};">See all 6</button></div>
{cat_row('Rent', 'Rent', '1 entry', '900.00', 100)}
{cat_row('Food', 'Food', '40 entries · RM 61 less than August', '486.40', 54, href='TGCategory.dc.html')}
{cat_row('Groceries', 'Groceries', '8 entries', '238.90', 26.5, last=True)}
</section>
{tabbar('Month')}
'''
print('TGMonth', write('TGMonth.dc.html', page('Timeline · Month', month)))

# ---------- 7 · Category: Food ----------
def entry_row(name, sub, amount, last=False):
    sep = '' if last else f' box-shadow: inset 0 -0.5px 0 {SEP};'
    return (f'<a href="TGEdit.dc.html" style="height: 56px; display: flex; align-items: center; gap: 12px;">{itile("Food", 34)}'
            f'<span style="flex-grow: 1; min-width: 0; height: 56px; display: flex; align-items: center; gap: 10px;{sep}">'
            f'<span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 16px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{name}</span><span style="font-size: 13px; color: {SEC};">{sub}</span></span>'
            f'{amount_html(amount)}{chev()}</span></a>')


def compare_row(name, pct, amount, color, delay):
    return (f'<div style="height: 18px; display: flex; align-items: center; gap: 10px; font-size: 13px;"><span style="width: 74px; color: {SEC};">{name}</span>'
            f'<span style="flex-grow: 1; height: 8px; border-radius: 4px; background: rgba(120,100,80,0.12); overflow: hidden;"><span style="display: block; width: {pct}%; height: 8px; border-radius: 4px; background: {color}; transform-origin: left center; animation: grow 0.8s {EASE} {delay}s both;"></span></span>'
            f'<span style="width: 52px; text-align: right; font-weight: 600; font-variant-numeric: tabular-nums;">{amount}</span></div>')

food_summary = (f'<span style="{LAB}">Spent on food</span>'
                f'<div style="margin-top: 4px; display: flex; align-items: flex-start; gap: 4px;"><span style="margin-top: 5px; font-size: 15px; font-weight: 700;">RM</span>{money("486.40", 32, INK, 0.2, True, label="RM 486.40")}</div>'
                f'<div style="margin-top: 14px; display: flex; flex-direction: column; gap: 8px;">{compare_row("September", 88.9, "486.40", ACC, 0.4)}{compare_row("August", 100, "547.40", "#C7C7CC", 0.5)}</div>'
                f'<div style="margin-top: 10px; display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 600;"><span style="color: {ACC_DEEP}; display: flex;">{icon("trenddown", 16, 2.2)}</span>RM 61 less than August by this date</div>')
category = f'''
{gcircle('chevleft', 'Back to Month', 'TGMonth.dc.html', extra='position: absolute; top: 54px; left: 16px;')}
{toolbar_group([('ellipsis', 'More', None)])}
{large_title('Food', 'September · 40 entries')}
<section style="position: absolute; top: 180px; left: 16px; right: 16px; height: 170px; box-sizing: border-box; padding: 16px 18px; border-radius: 26px; background: {CARD}; animation: rise 0.5s {EASE} 0.05s both;">{food_summary}</section>
<div style="position: absolute; top: 366px; left: 20px; right: 20px; display: flex; justify-content: space-between; font-size: 13px;"><span style="font-weight: 600; color: {SEC};">Today</span><span style="font-weight: 700;">RM 27.40</span></div>
<section style="position: absolute; top: 388px; left: 16px; right: 16px; box-sizing: border-box; padding: 0 14px; border-radius: 22px; background: {CARD}; animation: rise 0.5s {EASE} 0.15s both;">
{entry_row('Burger', '7:42 PM', '5.00')}{entry_row('Nasi lemak + teh ais', '1:15 PM', '9.50')}{entry_row('ZUS Coffee', '8:42 AM', '12.90', last=True)}
</section>
<div style="position: absolute; top: 572px; left: 20px; right: 20px; display: flex; justify-content: space-between; font-size: 13px;"><span style="font-weight: 600; color: {SEC};">Wednesday, 16 Sep</span><span style="font-weight: 700;">RM 38.60</span></div>
<section style="position: absolute; top: 594px; left: 16px; right: 16px; box-sizing: border-box; padding: 0 14px; border-radius: 22px; background: {CARD}; animation: rise 0.5s {EASE} 0.22s both;">
{entry_row('Mamak dinner', '9:10 PM', '16.20')}{entry_row('Chicken rice', '1:05 PM', '17.60')}{entry_row('Kopi', '8:15 AM', '4.80', last=True)}
</section>
{tabbar('Month')}
'''
print('TGCategory', write('TGCategory.dc.html', page('Timeline · Food', category)))

# ---------- 8 · Search ----------
def result_row(name, sub, amount, last=False):
    sep = '' if last else f' box-shadow: inset 0 -0.5px 0 {SEP};'
    return (f'<a href="TGEdit.dc.html" style="height: 58px; display: flex; align-items: center; gap: 12px;">{itile("Transport", 34)}'
            f'<span style="flex-grow: 1; min-width: 0; height: 58px; display: flex; align-items: center; gap: 10px;{sep}">'
            f'<span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 16px;"><b style="font-weight: 700;">Grab</b>{name}</span><span style="font-size: 13px; color: {SEC};">{sub}</span></span>'
            f'{amount_html(amount)}{chev()}</span></a>')

search = f'''
{large_title('Search', 'Type it or ask it')}
<div style="position: absolute; top: 180px; left: 16px; right: 16px; box-sizing: border-box; padding: 14px 16px; border-radius: 22px; background: {ACC_TINT}; display: flex; gap: 12px; animation: rise 0.5s {EASE} 0.1s both;">
<span style="flex-shrink: 0; margin-top: 1px; color: {ACC_DEEP}; display: flex;">{icon("sparkle", 20, 2)}</span>
<span style="display: flex; flex-direction: column; gap: 4px;"><span style="font-size: 15px; line-height: 21px; font-weight: 600;">9 Grab rides this month, RM 146.60 in total. That’s about RM 16 a ride.</span><span style="font-size: 12px; color: {SEC};">Worked out from your 9 entries below</span></span>
</div>
<div role="group" aria-label="Filters" style="position: absolute; top: 282px; left: 0; right: 0; height: 52px; padding: 0 16px; display: flex; gap: 8px; overflow-x: auto; scrollbar-width: none;">
{gchip('All', tint=True, extra='padding: 0 18px;')}{gchip('This month', extra='padding: 0 18px;')}{gchip('Transport', extra='padding: 0 18px;')}{gchip('Over RM 10', extra='padding: 0 18px;')}
</div>
<div style="position: absolute; top: 346px; left: 20px; right: 20px; display: flex; justify-content: space-between; font-size: 13px;"><span style="font-weight: 600; color: {SEC};">9 results</span><span style="font-weight: 700;">RM 146.60</span></div>
<section style="position: absolute; top: 368px; left: 16px; right: 16px; box-sizing: border-box; padding: 0 14px; border-radius: 22px; background: {CARD}; animation: rise 0.5s {EASE} 0.2s both;">
{result_row(' ride home', 'Today · 6:20 PM', '18.70')}
{result_row('', 'Wed 16 Sep · 8:40 AM', '12.00')}
{result_row('', 'Tue 15 Sep · 10:12 PM', '34.20')}
{result_row('', 'Mon 14 Sep · 6:05 PM', '8.20')}
{result_row('', 'Sat 12 Sep · 11:30 AM', '12.00')}
{result_row('', 'Fri 11 Sep · 7:55 PM', '14.00', last=True)}
</section>
<div style="position: absolute; left: 16px; right: 16px; bottom: 28px; height: 56px; display: flex; gap: 10px;">
<a href="TGToday.dc.html" aria-label="Back to Today" style="flex-shrink: 0; width: 56px; height: 56px; border-radius: 28px; {GLASS} display: flex; align-items: center; justify-content: center;">{icon("timeline", 22, 2.1)}</a>
<label style="flex-grow: 1; min-width: 0; height: 56px; box-sizing: border-box; padding: 0 6px 0 16px; border-radius: 28px; {GLASS} display: flex; align-items: center; gap: 8px;">
<span style="color: {SEC}; display: flex;">{icon("search", 19, 2.2)}</span>
<input type="search" value="grab" aria-label="Search entries" style="flex-grow: 1; min-width: 0; height: 44px; padding: 0; border: 0; outline: none; background: transparent; font-size: 17px;">
<button type="button" aria-label="Clear search" style="flex-shrink: 0; width: 44px; height: 44px; padding: 0; border: 0; background: transparent; color: {SEC}; display: flex; align-items: center; justify-content: center;">{icon("xcircle", 19, 2)}</button>
</label>
</div>
'''
print('TGSearch', write('TGSearch.dc.html', page('Timeline · Search', search)))

# ---------- 9 · From a screenshot ----------
shot_rows = [('7-Eleven', '−6.80', '4:10 PM'), ('Parking', '−3.00', '2:31 PM'), ('Reload from bank', '+50.00', '9:02 AM'), ('Bus fare', '−2.50', '17 Sep')]
shot = ''.join(
    f'<div style="position: relative; height: 34px; padding: 0 8px; display: flex; align-items: center; justify-content: space-between; font-size: 9px; color: {"#8E8E93" if i == 3 else INK}; border-top: 0.5px solid {SEP};">'
    f'<span style="display: flex; flex-direction: column;"><b style="font-weight: 600;">{n}</b><span style="font-size: 7px; color: #8E8E93;">{t}</span></span><b style="font-weight: 600;">{a}</b>'
    + (f'<span aria-hidden="true" style="position: absolute; inset: 3px 3px; border-radius: 6px; box-shadow: 0 0 0 1.5px {BAR}; background: rgba(255,140,40,0.1); animation: pop 0.35s {EASE} {0.9 + i * 0.25:.2f}s both;"></span>' if i < 3 else '')
    + '</div>' for i, (n, a, t) in enumerate(shot_rows))
thumb = (f'<div aria-label="Your screenshot" role="img" style="position: absolute; top: 72px; left: 16px; width: 124px; height: 212px; box-sizing: border-box; border-radius: 20px; overflow: hidden; background: #FFFFFF; '
         f'box-shadow: 0 0 0 0.5px rgba(0,0,0,0.12), 0 8px 22px rgba(0,0,0,0.12);">'
         f'<div style="padding: 14px 8px 6px; font-size: 11px; font-weight: 800;">Transactions<span style="display: block; font-size: 7px; font-weight: 500; color: #8E8E93;">Wallet history</span></div>'
         f'{shot}<span aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; height: 28px; background: linear-gradient(180deg, rgba(255,140,40,0) 0%, rgba(255,140,40,0.28) 100%); border-bottom: 2px solid {BAR}; opacity: 0; animation: scan 1.6s ease-in-out 0.2s 2 both;"></span></div>')


def found_row(cat, name, sub, amount, money_in=False, muted=False, last=False):
    sep = '' if last else f' box-shadow: inset 0 -0.5px 0 {SEP};'
    amt = f'<span style="font-size: 16px; font-weight: 600; color: {SEC}; text-decoration: line-through; font-variant-numeric: tabular-nums;">{amount}</span>' if muted else amount_html(amount, money_in)
    return (f'<a href="TGEdit.dc.html" style="height: 58px; display: flex; align-items: center; gap: 12px;">{itile(cat, 34)}'
            f'<span style="flex-grow: 1; min-width: 0; height: 58px; display: flex; align-items: center; gap: 10px;{sep}">'
            f'<span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 16px; font-weight: 600;">{name}</span><span style="font-size: 13px; color: {SEC};">{sub}</span></span>'
            f'{amt}{chev()}</span></a>')

scan_inner = f'''
{sheet_toolbar('From a screenshot', 'TGToday.dc.html', 'TGToday.dc.html')}
{thumb}
<div style="position: absolute; top: 80px; left: 156px; right: 16px; display: flex; flex-direction: column; gap: 6px;">
<span style="font-size: 26px; line-height: 30px; font-weight: 640; font-family: {ROUND};">Found 3</span>
<span style="font-size: 14px; line-height: 19px; color: {SEC};">Read from your wallet screenshot. The older row was already logged.</span>
<span style="margin-top: 6px; box-sizing: border-box; padding: 10px 12px; border-radius: 14px; background: {ACC_TINT}; display: flex; gap: 8px; font-size: 13px; line-height: 18px; font-weight: 600;"><span style="flex-shrink: 0; color: {ACC_DEEP}; display: flex;">{icon("sparkle", 16, 2)}</span>A reload just moves your money, so it isn’t counted as spending.</span>
</div>
<section style="position: absolute; top: 304px; left: 16px; right: 16px; box-sizing: border-box; padding: 0 14px; border-radius: 22px; background: {CARD}; animation: rise 0.5s {EASE} 1.5s both;">
{found_row('Groceries', '7-Eleven', 'Groceries · 4:10 PM', '6.80')}
{found_row('Transport', 'Parking', 'Transport · 2:31 PM', '3.00')}
{found_row('Top-up', 'Reload from bank', 'Wallet top-up · 9:02 AM', '50.00', muted=True)}
<div style="height: 52px; display: flex; align-items: center; justify-content: space-between; gap: 12px;"><span style="font-size: 16px;">Count the reload as spending</span>{toggle(False, 'Count the reload as spending')}</div>
</section>
<p style="position: absolute; top: 554px; left: 20px; right: 20px; margin: 0; font-size: 13px; line-height: 18px; color: {SEC};">Check the category and time, then tap ✓ to save. Tap a row to change it.</p>
'''
print('TGScan', write('TGScan.dc.html', page('Timeline · From a screenshot', behind() + big_sheet(scan_inner, 'From a screenshot'), root_bg='#000000')))
