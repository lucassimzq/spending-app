from r6 import *

FONTS = ('https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght,SOFT,WONK@0,9..144,100..900,0..100,0..1;1,9..144,100..900,0..100,0..1'
         '&amp;family=Figtree:ital,wght@0,300..900;1,300..900&amp;family=Bricolage+Grotesque:opsz,wdth,wght@12..96,75..100,200..800'
         '&amp;family=Schibsted+Grotesk:wght@400..900&amp;display=swap')
CARD_ST = f'box-sizing: border-box; padding: 24px; border-radius: 28px; background: {CARD}; display: flex; flex-direction: column; gap: 14px;'
CAP = f'font-size: 13px; line-height: 18px; color: {SEC};'

type_card = (f'<div style="{CARD_ST}"><span style="font-size: 12px; font-weight: 700; letter-spacing: 0.08em; color: {SEC};">TYPE</span>'
             f'<span style="{TITLE} font-size: 64px; line-height: 64px; font-weight: 600; letter-spacing: -0.01em;">Today</span>'
             f'<span style="font-family: {ROUND}; font-size: 44px; line-height: 48px; font-weight: 640; letter-spacing: -0.01em;">RM 2,146.30</span>'
             f'<span style="{TITLE} font-style: italic; font-size: 24px; line-height: 30px; font-weight: 500;">“lunch 12, grab <span style="color: {ACC_DEEP};">8.50</span>…”</span>'
             f'<div style="margin-top: 4px; height: 60px; box-sizing: border-box; padding: 0 12px; border-radius: 18px; background: {BG}; display: flex; align-items: center; gap: 12px;">{itile("Food")}'
             f'<span style="flex-grow: 1; display: flex; flex-direction: column;"><b style="font-size: 16px; font-weight: 600;">Burger</b><span style="font-size: 13px; color: {SEC};">Food · 7:42 PM</span></span><b style="font-size: 16px; font-weight: 700;">5.00</b></div>'
             f'<span style="margin-top: auto; {CAP}"><b style="color: {INK};">Fraunces</b>, a soft serif with a little wobble, for titles, money and what you said. <b style="color: {INK};">Figtree</b> for labels, lists and buttons, where it needs to stay plain and readable.</span></div>')


def alt(name, note, family, weight, extra=''):
    return (f'<div style="padding: 18px; border-radius: 20px; background: {BG}; display: flex; flex-direction: column; gap: 6px;">'
            f'<span style="font-size: 13px; font-weight: 700;">{name} <span style="font-weight: 500; color: {SEC};">· {note}</span></span>'
            f'<span style="font-family: {family}; font-size: 44px; line-height: 48px; font-weight: {weight}; letter-spacing: -0.02em;{extra}">Today</span>'
            f'<span style="font-family: {family}; font-size: 30px; line-height: 34px; font-weight: {weight}; letter-spacing: -0.01em;{extra}">RM 2,146.30</span></div>')

alts = (f'<div style="{CARD_ST}"><span style="font-size: 12px; font-weight: 700; letter-spacing: 0.08em; color: {SEC};">OR, IF YOU PREFER</span>'
        + alt('Bricolage Grotesque', 'playful', "'Bricolage Grotesque', sans-serif", 700)
        + alt('Schibsted Grotesk', 'crisp, the font from N', "'Schibsted Grotesk', sans-serif", 800)
        + f'<span style="margin-top: auto; {CAP}">Both keep the same layout. Pick one and I’ll swap it on every screen.</span></div>')


def swatch(hex_, name, use, dark_text=True, border=False):
    b = f' box-shadow: inset 0 0 0 1px {SEP};' if border else ''
    return (f'<div style="display: flex; align-items: center; gap: 14px;"><span style="flex-shrink: 0; width: 52px; height: 52px; border-radius: 16px; background: {hex_};{b}"></span>'
            f'<span style="display: flex; flex-direction: column;"><b style="font-size: 15px;">{name} <span style="font-weight: 500; color: {SEC};">{hex_}</span></b><span style="{CAP}">{use}</span></span></div>')

colour = (f'<div style="{CARD_ST}"><span style="font-size: 12px; font-weight: 700; letter-spacing: 0.08em; color: {SEC};">COLOUR</span>'
          + f'<div style="display: flex; align-items: center; gap: 12px;"><span aria-hidden="true" style="height: 52px; padding: 0 22px; border-radius: 26px; {GLASS_TINT} display: flex; align-items: center; gap: 8px; font-size: 16px; font-weight: 800;">{icon("plus", 20, 2.6)}Add</span>'
          + f'<span style="font-size: 14px; font-weight: 700; color: {ACC_DEEP};">Now · 7:45 PM</span>{tag("Guessed")}</div>'
          + swatch(ACC, 'Light tangerine', 'The main colour: Add, ✓, chips, “Now”, progress.')
          + swatch(ACC_DEEP, 'Deep tangerine', 'Small text and icons, so they stay readable.')
          + swatch(ACC_TINT, 'Tangerine tint', 'AI tips and anything the AI guessed.', border=True)
          + swatch(BG, 'Soft white', 'Background. Kept neutral, so tangerine only marks what matters.', border=True)
          + swatch(GREEN, 'Money-in green', 'Still means money in, nothing else.')
          + f'<span style="margin-top: auto; {CAP}">Dark text sits on tangerine buttons, and tangerine text uses the deeper shade. Both pass WCAG AA.</span></div>')

body = f'''
<div style="position: absolute; inset: 0; box-sizing: border-box; padding: 52px 56px; display: flex; flex-direction: column;">
<span style="display: flex; align-items: center; gap: 8px; font-size: 12px; font-weight: 700; letter-spacing: 0.12em; color: {SEC};"><span style="width: 8px; height: 8px; border-radius: 4px; background: {ACC}; animation: blink 1.2s steps(1) infinite;"></span>ROUND 6 · MORE PERSONALITY</span>
<h1 style="margin: 10px 0 0 0; {TITLE} font-size: 52px; line-height: 58px; font-weight: 600; letter-spacing: -0.01em;">Light tangerine, and type with a voice</h1>
<p style="margin: 10px 0 0 0; max-width: 1060px; font-size: 17px; line-height: 24px; color: {SEC};">Same 11 screens as Round 5, with two changes. A warm, light tangerine replaces the iPhone blue, and Fraunces gives titles and money some character. The glass controls and the calmer Today stay exactly as they were.</p>
<div style="margin-top: 24px; flex-grow: 1; display: grid; grid-template-columns: 1.15fr 0.85fr 1fr; gap: 20px;">{type_card}{alts}{colour}</div>
<div style="margin-top: 20px; min-height: 48px; box-sizing: border-box; padding: 12px 18px; border-radius: 16px; background: {INK}; color: #FFFFFF; display: flex; align-items: center; gap: 14px; font-size: 15px; line-height: 22px;">
<span style="flex-shrink: 0; font-size: 12px; font-weight: 700; letter-spacing: 0.12em; color: #D9CFC4;">11 SCREENS</span>
<span>Today · Add · Listening · Review · Edit · Month · Food · Search · Screenshot · Lock Screen · Widgets and controls</span>
</div>
</div>
'''
html = page('What changed from Round 5', body, root_bg=WASH, w=1368, h=900)
html = html.replace(FONT_HREF, FONTS)
print('TGNotes', write('TGNotes.dc.html', html))
