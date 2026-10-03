# Shared building blocks for the Round 4 boards (structured directions P–T).
import pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).parent))
from reels import number as _reel_number

# Boards are written straight into the repo's mocks folder (the canvas source snapshot).
OUT = pathlib.Path(__file__).resolve().parents[1] / 'mocks'

ICONS = {
    'food': '<path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"></path><path d="M7 2v20"></path><path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7"></path>',
    'car': '<path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"></path><circle cx="7" cy="17" r="2"></circle><path d="M9 17h6"></path><circle cx="17" cy="17" r="2"></circle>',
    'cart': '<circle cx="8" cy="21" r="1"></circle><circle cx="19" cy="21" r="1"></circle><path d="M2.05 2.05h2l2.66 12.42a2 2 0 0 0 2 1.58h9.78a2 2 0 0 0 1.95-1.57l1.65-7.43H5.12"></path>',
    'bag': '<path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"></path><path d="M3 6h18"></path><path d="M16 10a4 4 0 0 1-8 0"></path>',
    'bolt': '<path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"></path>',
    'home': '<path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"></path><path d="M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>',
    'in': '<path d="M17 7 7 17"></path><path d="M17 17H7V7"></path>',
    'mic': '<path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z"></path><path d="M19 10v2a7 7 0 0 1-14 0v-2"></path><path d="M12 19v3"></path>',
    'scan': '<path d="M3 7V5a2 2 0 0 1 2-2h2"></path><path d="M17 3h2a2 2 0 0 1 2 2v2"></path><path d="M21 17v2a2 2 0 0 1-2 2h-2"></path><path d="M7 21H5a2 2 0 0 1-2-2v-2"></path><path d="M7 12h10"></path>',
    'plus': '<path d="M5 12h14"></path><path d="M12 5v14"></path>',
    'minus': '<path d="M5 12h14"></path>',
    'chev': '<path d="m9 18 6-6-6-6"></path>',
    'chevdown': '<path d="m6 9 6 6 6-6"></path>',
    'sparkle': '<path d="M9.937 15.5A2 2 0 0 0 8.5 14.063l-6.135-1.582a.5.5 0 0 1 0-.962L8.5 9.936A2 2 0 0 0 9.937 8.5l1.582-6.135a.5.5 0 0 1 .963 0L14.063 8.5A2 2 0 0 0 15.5 9.937l6.135 1.581a.5.5 0 0 1 0 .964L15.5 14.063a2 2 0 0 0-1.437 1.437l-1.582 6.135a.5.5 0 0 1-.963 0z"></path>',
    'calendar': '<path d="M8 2v4"></path><path d="M16 2v4"></path><rect width="18" height="18" x="3" y="4" rx="2"></rect><path d="M3 10h18"></path>',
    'clock': '<circle cx="12" cy="12" r="10"></circle><path d="M12 6v6l4 2"></path>',
    'pencil': '<path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"></path>',
    'users': '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path>',
    'repeat': '<path d="m17 2 4 4-4 4"></path><path d="M3 11v-1a4 4 0 0 1 4-4h14"></path><path d="m7 22-4-4 4-4"></path><path d="M21 13v1a4 4 0 0 1-4 4H3"></path>',
    'note': '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"></path><path d="M14 2v4a2 2 0 0 0 2 2h4"></path><path d="M16 13H8"></path><path d="M16 17H8"></path>',
    'x': '<path d="M18 6 6 18"></path><path d="m6 6 12 12"></path>',
    'trash': '<path d="M3 6h18"></path><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"></path><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"></path>',
    'check': '<path d="M20 6 9 17l-5-5"></path>',
    'back': '<path d="M10 5a2 2 0 0 0-1.344.519l-6.328 5.74a1 1 0 0 0 0 1.481l6.328 5.741A2 2 0 0 0 10 19h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2z"></path><path d="m12 9 6 6"></path><path d="m18 9-6 6"></path>',
    'copy': '<rect width="14" height="14" x="8" y="8" rx="2" ry="2"></rect><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"></path>',
    'search': '<circle cx="11" cy="11" r="8"></circle><path d="m21 21-4.3-4.3"></path>',
    'wallet': '<path d="M19 7V4a1 1 0 0 0-1-1H5a2 2 0 0 0 0 4h15a1 1 0 0 1 1 1v4h-3a2 2 0 0 0 0 4h3a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1"></path><path d="M3 5v14a2 2 0 0 0 2 2h15a1 1 0 0 0 1-1v-4"></path>',
    'arrowout': '<path d="M7 7h10v10"></path><path d="M7 17 17 7"></path>',
    'down': '<path d="M12 5v14"></path><path d="m19 12-7 7-7-7"></path>',
}
CAT_ICON = {'Food': 'food', 'Transport': 'car', 'Groceries': 'cart', 'Shopping': 'bag', 'Bills': 'bolt', 'Rent': 'home', 'Money in': 'in'}

SR = 'position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0); white-space: nowrap;'


def icon(name, size=20, sw=2):
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="{sw}" '
            f'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{ICONS[name]}</svg>')


KEYFRAMES = '''@keyframes roll{from{transform:translateY(0)}}
@keyframes r46{from{transform:translateY(-14em)}}
@keyframes r38{from{transform:translateY(-13em)}}
@keyframes r02{from{transform:translateY(-10em)}}
@keyframes rise{0%{opacity:0;transform:translateY(18px)}100%{opacity:1;transform:translateY(0)}}
@keyframes pop{0%{opacity:0;transform:scale(0.7)}60%{opacity:1;transform:scale(1.04)}80%{transform:scale(0.99)}100%{opacity:1;transform:scale(1)}}
@keyframes grow{0%{transform:scaleX(0)}100%{transform:scaleX(1)}}
@keyframes spring{0%{transform:scaleX(0)}55%{transform:scaleX(1.06)}75%{transform:scaleX(0.98)}100%{transform:scaleX(1)}}
@keyframes fadeIn{0%{opacity:0}100%{opacity:1}}
@keyframes sheetUp{0%{transform:translateY(100%)}70%{transform:translateY(-6px)}100%{transform:translateY(0)}}
@keyframes ping{0%{transform:scale(1);opacity:0.55}100%{transform:scale(2.6);opacity:0}}
@keyframes blink{0%,49%{opacity:1}50%,100%{opacity:0}}
@keyframes draw{from{stroke-dashoffset:100}to{stroke-dashoffset:0}}
@keyframes slideIn{0%{opacity:0;transform:translateX(-14px)}100%{opacity:1;transform:translateX(0)}}
@keyframes wave{0%,100%{transform:scaleY(0.3)}50%{transform:scaleY(1)}}
@media (prefers-reduced-motion: reduce){*{animation:none !important}}'''


def page(title, font_href, ink, muted, root_style, body, extra_css=''):
    css = (f"body{{margin:0}}\n"
           f"a{{color:{ink};text-decoration:none}}a:hover{{color:{ink}}}\n"
           "button{font:inherit;color:inherit;cursor:pointer}\n"
           "input,textarea{font:inherit;color:inherit}\n"
           f"input::placeholder,textarea::placeholder{{color:{muted}}}\n"
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
<link href="{font_href}" rel="stylesheet">
<style>
{css}
</style>
</helmet>
<div style="width: 390px; height: 844px; position: relative; overflow: hidden; {root_style}">
{body}
</div>
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{{"$preview":{{"width":390,"height":844}}}}'>
class Component extends DCLogic {{
renderVals() {{
return {{}};
}}
}}
</script>
</body>
</html>
'''


def rolling(text, size, weight, color='inherit', delay=0.15, anims=None, label=None, extra=''):
    """Odometer number. text like '2,146.30'. anims: per-digit animation strings (None = static digit)."""
    digits = sum(ch.isdigit() for ch in text)
    if anims is None:
        anims = [f'roll {0.8 + 0.1 * i:.1f}s cubic-bezier(.2,1.3,.4,1) {delay}s both' for i in range(digits)]
    return (f'<span style="position: relative; display: flex; align-items: flex-start; font-size: {size}px; line-height: 1; '
            f'font-weight: {weight}; color: {color}; letter-spacing: -0.02em; font-variant-numeric: tabular-nums;{(" " + extra) if extra else ""}">'
            f'<span style="{SR}">{label or text}</span>{_reel_number(text, anims)}</span>')


def write(name, html):
    (OUT / name).write_text(html)
    return len(html)
