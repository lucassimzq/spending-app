# Shared parts for Round 5: direction S (Timeline) rebuilt with iOS 27 Liquid Glass.
import pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).parent))
from r4 import ICONS, CAT_ICON, SR, icon as _icon, rolling, OUT

ICONS.update({
    'timeline': '<path d="M12 3v6"></path><circle cx="12" cy="12" r="3"></circle><path d="M12 15v6"></path>',
    'chart': '<path d="M3 3v16a2 2 0 0 0 2 2h16"></path><path d="M18 17V9"></path><path d="M13 17V5"></path><path d="M8 17v-3"></path>',
    'ellipsis': '<circle cx="12" cy="12" r="1"></circle><circle cx="19" cy="12" r="1"></circle><circle cx="5" cy="12" r="1"></circle>',
    'chevleft': '<path d="m15 18-6-6 6-6"></path>',
    'keyboard': '<path d="M10 8h.01"></path><path d="M12 12h.01"></path><path d="M14 8h.01"></path><path d="M16 12h.01"></path><path d="M18 8h.01"></path><path d="M6 8h.01"></path><path d="M7 16h10"></path><path d="M8 12h.01"></path><rect width="20" height="16" x="2" y="4" rx="2"></rect>',
    'camera': '<path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"></path><circle cx="12" cy="13" r="3"></circle>',
    'swap': '<path d="M8 3 4 7l4 4"></path><path d="M4 7h16"></path><path d="m16 21 4-4-4-4"></path><path d="M20 17H4"></path>',
    'history': '<path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"></path><path d="M3 3v5h5"></path><path d="M12 7v5l4 2"></path>',
    'xcircle': '<circle cx="12" cy="12" r="10"></circle><path d="m15 9-6 6"></path><path d="m9 9 6 6"></path>',
    'trenddown': '<path d="M16 17h6v-6"></path><path d="m22 17-8.5-8.5-5 5L2 7"></path>',
    'share': '<path d="M12 2v13"></path><path d="m16 6-4-4-4 4"></path><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"></path>',
})
icon = _icon

# ---- iOS 27 light palette (systemGroupedBackground, labels) + one accent ----
BG, CARD, INK, SEC, SEP = '#F2F2F7', '#FFFFFF', '#1C1C1E', '#636366', '#E5E5EA'
TILE = '#EFEFF4'
ACC, ACC_TINT, GREEN, GREEN_TINT, RED, RAIL, DOT, CHEV = '#005EEB', '#E8F0FF', '#1F7A35', '#E3F6E8', '#D70015', '#D1D1D6', '#AEAEB2', '#C7C7CC'
TEXT = "-apple-system, BlinkMacSystemFont, 'SF Pro Text', Inter, 'Helvetica Neue', sans-serif"
ROUND = "ui-rounded, 'SF Pro Rounded', Outfit, -apple-system, sans-serif"
FONT_HREF = 'https://fonts.googleapis.com/css2?family=Inter:wght@400..800&amp;family=Outfit:wght@400..800&amp;display=swap'
EASE = 'cubic-bezier(.2,.8,.2,1)'
WASH = f"radial-gradient(140% 52% at 50% -8%, rgba(0,94,235,0.17) 0%, rgba(0,94,235,0) 62%), {BG}"

# Liquid Glass, iOS 27 flavour: a darker hairline edge plus a bright specular rim.
GLASS = ("background: linear-gradient(155deg, rgba(255,255,255,0.78) 0%, rgba(255,255,255,0.42) 42%, rgba(255,255,255,0.3) 62%, rgba(255,255,255,0.56) 100%); "
         "-webkit-backdrop-filter: blur(16px) saturate(180%); backdrop-filter: blur(16px) saturate(180%); "
         "box-shadow: inset 0 0 0 0.5px rgba(0,0,0,0.2), inset 1.5px 1.5px 1px -0.5px rgba(255,255,255,1), inset -1px -1px 1px -0.5px rgba(255,255,255,0.75), "
         "0 8px 24px rgba(0,0,0,0.10), 0 1px 3px rgba(0,0,0,0.08);")
GLASS_TINT = (f"background: linear-gradient(155deg, rgba(255,255,255,0.34) 0%, rgba(255,255,255,0.06) 42%, rgba(255,255,255,0) 62%, rgba(255,255,255,0.14) 100%), {ACC}; "
              "box-shadow: inset 0 0 0 0.5px rgba(0,0,0,0.28), inset 1.5px 1.5px 1px -0.5px rgba(255,255,255,0.75), inset -1px -1px 1px -0.5px rgba(255,255,255,0.3), "
              "0 8px 20px rgba(0,94,235,0.32), 0 1px 3px rgba(0,0,0,0.12); color: #FFFFFF;")
SHEET_GLASS = ("background: linear-gradient(180deg, rgba(255,255,255,0.86) 0%, rgba(248,248,251,0.8) 100%); "
               "-webkit-backdrop-filter: blur(30px) saturate(180%); backdrop-filter: blur(30px) saturate(180%); "
               "box-shadow: inset 0 0 0 0.5px rgba(0,0,0,0.14), inset 0 1.5px 0 rgba(255,255,255,0.95), 0 12px 40px rgba(0,0,0,0.2);")

KEYFRAMES = '''@keyframes roll{from{transform:translateY(0)}}
@keyframes r46{from{transform:translateY(-14em)}}
@keyframes r38{from{transform:translateY(-13em)}}
@keyframes r02{from{transform:translateY(-10em)}}
@keyframes rise{0%{opacity:0;transform:translateY(16px)}100%{opacity:1;transform:translateY(0)}}
@keyframes pop{0%{opacity:0;transform:scale(0.8)}60%{opacity:1;transform:scale(1.03)}100%{opacity:1;transform:scale(1)}}
@keyframes slideIn{0%{opacity:0;transform:translateX(-12px)}100%{opacity:1;transform:translateX(0)}}
@keyframes railDown{0%{transform:scaleY(0)}100%{transform:scaleY(1)}}
@keyframes grow{0%{transform:scaleX(0)}100%{transform:scaleX(1)}}
@keyframes growUp{0%{transform:scaleY(0)}100%{transform:scaleY(1)}}
@keyframes spring{0%{transform:scaleX(0)}55%{transform:scaleX(1.05)}75%{transform:scaleX(0.98)}100%{transform:scaleX(1)}}
@keyframes fadeIn{0%{opacity:0}100%{opacity:1}}
@keyframes sheetUp{0%{transform:translateY(105%)}70%{transform:translateY(-4px)}100%{transform:translateY(0)}}
@keyframes dropIn{0%{opacity:0;transform:translateY(-24px) scale(0.96)}100%{opacity:1;transform:translateY(0) scale(1)}}
@keyframes ping{0%{transform:scale(1);opacity:0.55}100%{transform:scale(2.6);opacity:0}}
@keyframes ripple{0%{transform:scale(0.9);opacity:0.5}100%{transform:scale(1.9);opacity:0}}
@keyframes breathe{0%,100%{transform:scale(1)}50%{transform:scale(1.04)}}
@keyframes glow{0%,100%{opacity:0.65}50%{opacity:1}}
@keyframes wave{0%,100%{transform:scaleY(0.35)}50%{transform:scaleY(1)}}
@keyframes blink{0%,49%{opacity:1}50%,100%{opacity:0}}
@keyframes knob{from{transform:translateX(157px)}}
@keyframes scan{0%{transform:translateY(0);opacity:1}88%{opacity:1}100%{transform:translateY(184px);opacity:0}}
@keyframes draw{from{stroke-dashoffset:100}to{stroke-dashoffset:0}}
@media (prefers-reduced-motion: reduce){*{animation:none !important}}'''


def page(title, body, root_bg=WASH, w=390, h=844, extra_css=''):
    css = (f"body{{margin:0}}\n"
           f"a{{color:{INK};text-decoration:none}}a:hover{{color:{INK}}}\n"
           "button{font:inherit;color:inherit;cursor:pointer}\n"
           "input,textarea{font:inherit;color:inherit}\n"
           f"input::placeholder{{color:{SEC}}}\n"
           + (extra_css + '\n' if extra_css else '') + KEYFRAMES)
    return f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{title}</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<link href="{FONT_HREF}" rel="stylesheet">
<style>
{css}
</style>
</helmet>
<div style="width: {w}px; height: {h}px; position: relative; overflow: hidden; background: {root_bg}; color: {INK}; font-family: {TEXT};">
{body}
</div>
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{{"$preview":{{"width":{w},"height":{h}}}}}'>
class Component extends DCLogic {{
renderVals() {{
return {{}};
}}
}}
</script>
</body>
</html>
'''


def write(name, html):
    (OUT / name).write_text(html)
    return len(html)


# ---------- glass controls ----------
def gcircle(icon_name, label, href=None, size=44, tint=False, extra='', isz=20):
    style = (f"flex-shrink: 0; width: {size}px; height: {size}px; padding: 0; border: 0; border-radius: {size // 2}px; "
             f"{GLASS_TINT if tint else GLASS} display: flex; align-items: center; justify-content: center;{(' ' + extra) if extra else ''}")
    if href:
        return f'<a href="{href}" aria-label="{label}" style="{style}">{icon(icon_name, isz, 2.2)}</a>'
    return f'<button type="button" aria-label="{label}" style="{style}">{icon(icon_name, isz, 2.2)}</button>'


def toolbar_group(buttons, top=54, right=16):
    """buttons: list of (icon, label, href). A grouped glass capsule like iOS 27 toolbars."""
    inner = ''.join(
        (f'<a href="{h}" aria-label="{l}"' if h else f'<button type="button" aria-label="{l}"')
        + f' style="width: 46px; height: 44px; padding: 0; border: 0; background: transparent; display: flex; align-items: center; justify-content: center;">{icon(i, 20, 2.2)}'
        + ('</a>' if h else '</button>') for i, l, h in buttons)
    return f'<div style="position: absolute; top: {top}px; right: {right}px; height: 44px; border-radius: 22px; {GLASS} display: flex;">{inner}</div>'


def large_title(title, subtitle, top=102):
    return (f'<h1 style="position: absolute; top: {top}px; left: 20px; margin: 0; font-size: 34px; line-height: 41px; font-weight: 800; letter-spacing: -0.02em;">{title}</h1>'
            f'<span style="position: absolute; top: {top + 43}px; left: 20px; font-size: 15px; font-weight: 500; color: {SEC};">{subtitle}</span>')


def tabbar(active):
    tabs = [('Today', 'timeline', 'TLToday.dc.html'), ('Month', 'chart', 'TLMonth.dc.html'), ('Search', 'search', 'TLSearch.dc.html')]
    items = ''
    for name, ic, href in tabs:
        on = name == active
        bg = ' background: rgba(120,120,128,0.16);' if on else ''
        cur = ' aria-current="page"' if on else ''
        items += (f'<a href="{href}"{cur} style="flex: 1; height: 52px; border-radius: 26px;{bg} color: {ACC if on else INK}; display: flex; flex-direction: column; '
                  f'align-items: center; justify-content: center; gap: 2px; font-size: 10px; font-weight: 600;">{icon(ic, 22, 2.1)}{name}</a>')
    add = (f'<a href="TLAdd.dc.html" style="flex-shrink: 0; width: 78px; height: 52px; border-radius: 26px; {GLASS_TINT} display: flex; flex-direction: column; '
           f'align-items: center; justify-content: center; gap: 2px; font-size: 10px; font-weight: 700;">{icon("plus", 22, 2.6)}Add</a>')
    return (f'<nav aria-label="Tabs" style="position: absolute; left: 16px; right: 16px; bottom: 28px; height: 64px; box-sizing: border-box; padding: 6px; '
            f'border-radius: 32px; {GLASS} display: flex; align-items: center; gap: 4px;">{items}{add}</nav>')


def sheet_toolbar(title, close_href, done_href=None, top=14):
    done = gcircle('check', 'Save', done_href, tint=True) if done_href else '<span style="width: 44px;"></span>'
    return (f'<div style="position: absolute; top: {top}px; left: 16px; right: 16px; height: 44px; display: flex; align-items: center; justify-content: space-between;">'
            f'{gcircle("x", "Close", close_href)}<h1 style="margin: 0; font-size: 17px; font-weight: 700;">{title}</h1>{done}</div>')


def grabber(top=6):
    return f'<span aria-hidden="true" style="position: absolute; top: {top}px; left: 50%; width: 36px; height: 5px; margin-left: -18px; border-radius: 3px; background: rgba(60,60,67,0.3);"></span>'


def segmented(options, selected=0, label='Type'):
    btns = ''
    for i, o in enumerate(options):
        on = i == selected
        st = (f"{GLASS} background: #FFFFFF; font-weight: 700;" if on else f"background: transparent; border: 0; font-weight: 600; color: {SEC};")
        btns += f'<button type="button" aria-pressed="{"true" if on else "false"}" style="border: 0; border-radius: 18px; {st} font-size: 15px;">{o}</button>'
    return (f'<div role="group" aria-label="{label}" style="height: 44px; box-sizing: border-box; padding: 4px; border-radius: 22px; background: rgba(120,120,128,0.14); '
            f'display: grid; grid-template-columns: repeat({len(options)}, minmax(0, 1fr)); gap: 2px;">{btns}</div>')


def toggle(on=False, label=''):
    track = '#34C759' if on else 'rgba(120,120,128,0.2)'
    left = 23 if on else 2
    return (f'<button type="button" role="switch" aria-checked="{"true" if on else "false"}" aria-label="{label}" style="position: relative; flex-shrink: 0; width: 64px; height: 28px; padding: 0; border: 0; border-radius: 14px; background: {track};">'
            f'<span style="position: absolute; top: 2px; left: {left}px; width: 39px; height: 24px; border-radius: 12px; background: #FFFFFF; box-shadow: 0 2px 6px rgba(0,0,0,0.18), 0 0 0 0.5px rgba(0,0,0,0.06);"></span></button>')


def gchip(content, href=None, tint=False, delay=None, extra=''):
    anim = f' animation: pop 0.45s {EASE} {delay}s both;' if delay is not None else ''
    st = (f"flex-shrink: 0; height: 44px; padding: 0 16px 0 12px; border: 0; border-radius: 22px; {GLASS_TINT if tint else GLASS} "
          f"display: flex; align-items: center; gap: 6px; font-size: 15px; font-weight: 600; white-space: nowrap;{anim}{(' ' + extra) if extra else ''}")
    if href:
        return f'<a href="{href}" style="{st}">{content}</a>'
    return f'<button type="button" style="{st}">{content}</button>'


# ---------- content parts (solid, per Apple: glass is for controls, not content) ----------
def itile(cat, size=38):
    money_in = cat in ('Money in',)
    bg, fg = (GREEN_TINT, GREEN) if money_in else (TILE, INK)
    ic = CAT_ICON.get(cat, 'swap')
    return (f'<span style="flex-shrink: 0; width: {size}px; height: {size}px; border-radius: {round(size * 0.29)}px; background: {bg}; color: {fg}; '
            f'display: flex; align-items: center; justify-content: center;">{icon(ic, round(size * 0.5), 2)}</span>')


def amount_html(amount, money_in=False, size=16):
    return f'<span style="font-size: {size}px; font-weight: 600; color: {GREEN if money_in else INK}; font-variant-numeric: tabular-nums; white-space: nowrap;">{amount}</span>'


def chev():
    return f'<span style="color: {CHEV}; display: flex;">{icon("chev", 15, 2.6)}</span>'


RAIL_X = 31


def rail(top, height, delay=None, dashed=False):
    line = f'border-left: 2px dashed {RAIL};' if dashed else f'background: {RAIL};'
    anim = f' transform-origin: top center; animation: railDown 0.35s linear {delay}s both;' if delay is not None else ''
    return f'<span aria-hidden="true" style="position: absolute; top: {top}px; left: {RAIL_X}px; width: 2px; height: {height}px; box-sizing: border-box; {line}{anim}"></span>'


def dot(cy, delay=None, color=None, size=10):
    fill = f'background: {color};' if color else f'background: {CARD}; border: 2px solid {DOT};'
    anim = f' animation: pop 0.35s {EASE} {delay}s both;' if delay is not None else ''
    return (f'<span aria-hidden="true" style="position: absolute; top: {cy - size / 2:.0f}px; left: {RAIL_X + 1 - size / 2:.0f}px; width: {size}px; height: {size}px; '
            f'box-sizing: border-box; border-radius: {size}px; {fill}{anim}"></span>')


def now_marker(top, label='Now · 7:45 PM', animate=True):
    cy = top + 12
    ping = (f'<span aria-hidden="true" style="position: absolute; top: {cy - 6}px; left: {RAIL_X + 1 - 6}px; width: 12px; height: 12px; border-radius: 6px; background: {ACC}; '
            f'animation: ping 1.8s ease-out infinite;"></span>') if animate else ''
    return (f'<span aria-hidden="true" style="position: absolute; top: {cy - 6}px; left: {RAIL_X + 1 - 6}px; width: 12px; height: 12px; border-radius: 6px; background: {ACC};"></span>{ping}'
            f'<span style="position: absolute; top: {top}px; left: 52px; height: 24px; display: flex; align-items: center; font-size: 13px; font-weight: 700; color: {ACC};">{label}</span>')


def tl_card(top, cat, name, sub, amount, href='TLEdit.dc.html', delay=None, height=62, new=False, extra_tags=''):
    money_in = cat == 'Money in'
    ring = f' box-shadow: inset 0 0 0 1.5px {ACC};' if new else ''
    anim = f' animation: slideIn 0.45s {EASE} {delay}s both;' if delay is not None else ''
    return (f'<a href="{href}" style="position: absolute; top: {top}px; left: 52px; right: 16px; height: {height}px; box-sizing: border-box; padding: 0 12px 0 12px; '
            f'border-radius: 18px; background: {CARD};{ring} display: flex; align-items: center; gap: 12px;{anim}">{itile(cat)}'
            f'<span style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;"><span style="font-size: 16px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{name}</span>'
            f'<span style="display: flex; align-items: center; gap: 6px; font-size: 13px; color: {SEC}; white-space: nowrap;">{sub}{extra_tags}</span></span>'
            f'{amount_html(amount, money_in)}{chev()}</a>')


def tag(text, kind='acc'):
    bg, fg = {'acc': (ACC_TINT, ACC), 'in': (GREEN_TINT, GREEN), 'grey': (TILE, SEC)}[kind]
    return f'<span style="height: 20px; padding: 0 7px; border-radius: 6px; background: {bg}; color: {fg}; display: inline-flex; align-items: center; font-size: 12px; font-weight: 700;">{text}</span>'


def label(text, top, left=20, extra=''):
    return f'<span style="position: absolute; top: {top}px; left: {left}px; font-size: 13px; font-weight: 600; color: {SEC};{(" " + extra) if extra else ""}">{text}</span>'
