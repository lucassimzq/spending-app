from r6 import *

WALL = ("radial-gradient(80% 50% at 10% 8%, rgba(90,160,170,0.4) 0%, rgba(90,160,170,0) 70%), "
        "radial-gradient(90% 55% at 90% 100%, rgba(120,170,175,0.3) 0%, rgba(120,170,175,0) 70%), "
        "linear-gradient(180deg, #17343D 0%, #22464E 50%, #2B4E55 80%, #35585E 100%)")
GLASS_ON_WALL = ("background: linear-gradient(155deg, rgba(255,255,255,0.24) 0%, rgba(255,255,255,0.1) 50%, rgba(255,255,255,0.16) 100%); "
                 "-webkit-backdrop-filter: blur(20px) saturate(160%); backdrop-filter: blur(20px) saturate(160%); "
                 "box-shadow: inset 0 0 0 0.5px rgba(0,0,0,0.18), inset 1.5px 1.5px 1px -0.5px rgba(255,255,255,0.7), inset -1px -1px 1px -0.5px rgba(255,255,255,0.35), 0 6px 20px rgba(0,0,0,0.14); color: #FFFFFF;")


def app_icon(size):
    r = round(size * 0.2237)
    return (f'<span aria-hidden="true" style="flex-shrink: 0; width: {size}px; height: {size}px; border-radius: {r}px; background: linear-gradient(160deg, #FFB25E 0%, #F2802A 60%, #D9671A 100%); '
            f'box-shadow: inset 0 0 0 0.5px rgba(255,255,255,0.35), inset 1px 1px 1px rgba(255,255,255,0.45); color: #FFFFFF; display: flex; align-items: center; justify-content: center;">{icon("timeline", round(size * 0.58), 2.6)}</span>')


def gauge(pct, big, small, size=72):
    return (f'<div style="position: relative; width: {size}px; height: {size}px; border-radius: {size // 2}px; {GLASS_ON_WALL} display: flex; flex-direction: column; align-items: center; justify-content: center;">'
            f'<svg width="{size}" height="{size}" viewBox="0 0 72 72" aria-hidden="true" style="position: absolute; inset: 0; transform: rotate(-90deg);">'
            f'<circle cx="36" cy="36" r="30" fill="none" stroke="rgba(255,255,255,0.3)" stroke-width="5"></circle>'
            f'<circle cx="36" cy="36" r="30" fill="none" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round" pathLength="100" style="stroke-dasharray: {pct} 100; stroke-dashoffset: 0;"></circle></svg>'
            f'<span style="font-size: 16px; font-weight: 640; font-family: {ROUND}; line-height: 18px;">{big}</span><span style="font-size: 9px; font-weight: 600; opacity: 0.9;">{small}</span></div>')


# ---------- 10 · Lock Screen ----------
lock = f'''
<span style="position: absolute; top: 92px; left: 0; right: 0; text-align: center; font-size: 19px; font-weight: 600; color: #FFFFFF;">Friday 18 September</span>
<span style="position: absolute; top: 116px; left: 0; right: 0; text-align: center; font-family: -apple-system, 'SF Pro Display', 'Helvetica Neue', sans-serif; font-size: 104px; line-height: 112px; font-weight: 600; letter-spacing: -0.02em; color: #FFFFFF; text-shadow: 0 2px 18px rgba(0,0,0,0.12);">7:46</span>
<div style="position: absolute; top: 252px; left: 0; right: 0; display: flex; justify-content: center; gap: 12px;">
{gauge(41, '41%', 'spent')}
<div style="width: 158px; height: 72px; box-sizing: border-box; padding: 10px 14px; border-radius: 22px; {GLASS_ON_WALL} display: flex; flex-direction: column; justify-content: center; gap: 1px;">
<span style="font-size: 12px; font-weight: 600; opacity: 0.9;">Kira · Spent today</span><span style="font-size: 20px; line-height: 24px; font-weight: 640; font-family: {ROUND};">RM 46.10</span><span style="font-size: 12px; opacity: 0.9;">Last: Burger, 5.00</span></div>
{gauge(60, '254', 'RM a day')}
</div>
<div style="position: absolute; top: 520px; left: 12px; right: 12px; box-sizing: border-box; padding: 12px 14px; border-radius: 26px; {GLASS} display: flex; gap: 12px; animation: dropIn 0.6s {EASE} 0.4s both;">
{app_icon(38)}
<div style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px;">
<div style="display: flex; justify-content: space-between; font-size: 13px;"><b style="font-weight: 700;">Kira</b><span style="color: {SEC};">now</span></div>
<span style="font-size: 15px; font-weight: 700;">Saved 3 entries</span>
<span style="font-size: 14px; line-height: 19px;">Lunch 12.00 · Grab 8.50 · Ali paid you back <b style="font-weight: 700; color: {GREEN};">+20.00</b></span>
</div>
</div>
<a href="TGListen.dc.html" aria-label="Log by voice" style="position: absolute; left: 44px; bottom: 54px; width: 52px; height: 52px; border-radius: 26px; {GLASS_ON_WALL} background: rgba(20,16,12,0.38); display: flex; align-items: center; justify-content: center;">{icon("mic", 22, 2.2)}</a>
<button type="button" aria-label="Camera" style="position: absolute; right: 44px; bottom: 54px; width: 52px; height: 52px; padding: 0; border: 0; border-radius: 26px; {GLASS_ON_WALL} background: rgba(20,16,12,0.38); display: flex; align-items: center; justify-content: center;">{icon("camera", 22, 2)}</button>
<span style="position: absolute; left: 24px; bottom: 116px; height: 28px; padding: 0 12px; border-radius: 14px; background: rgba(0,0,0,0.28); color: #FFFFFF; display: flex; align-items: center; font-size: 12px; font-weight: 600;">Your Lock Screen control: hold to log</span>
'''
print('TGLock', write('TGLock.dc.html', page('Timeline · Lock Screen', lock, root_bg=WALL)))

# ---------- 11 · Widgets, Control Center, Action button ----------
CAP = 'position: absolute; left: 24px; font-size: 13px; font-weight: 700; color: rgba(255,255,255,0.92); letter-spacing: 0.02em;'


def widget_btn(name, amount):
    return (f'<button type="button" style="height: 40px; padding: 0 12px; border: 0; border-radius: 20px; {GLASS} background: {TILE}; display: flex; align-items: center; justify-content: space-between; gap: 6px; font-size: 13px; font-weight: 600;">'
            f'<span style="display: flex; align-items: center; gap: 4px;"><span style="color: {ACC_DEEP}; display: flex;">{icon("plus", 14, 2.6)}</span>{name}</span><b style="font-weight: 800;">{amount}</b></button>')


def control(icon_name, title, sub, wide=False, tint=False):
    w = 'grid-column: span 2;' if wide else ''
    circle = (f'<span style="flex-shrink: 0; width: 44px; height: 44px; border-radius: 22px; {GLASS_TINT if tint else "background: rgba(255,255,255,0.25);"} '
              f'display: flex; align-items: center; justify-content: center; color: {INK if tint else "#FFFFFF"};">{icon(icon_name, 20, 2.2)}</span>')
    text = (f'<span style="display: flex; flex-direction: column; text-align: left;"><b style="font-size: 13px; font-weight: 700;">{title}</b><span style="font-size: 11px; opacity: 0.85;">{sub}</span></span>') if wide else ''
    return (f'<button type="button" aria-label="{title}" style="{w} height: 72px; box-sizing: border-box; padding: 0 {14 if wide else 0}px; border: 0; border-radius: 36px; {GLASS_ON_WALL} '
            f'display: flex; align-items: center; justify-content: {"flex-start" if wide else "center"}; gap: 10px;">{circle}{text}</button>')

widgets = f'''
<span style="{CAP} top: 44px;">HOME SCREEN WIDGETS</span>
<div style="position: absolute; top: 70px; left: 20px; right: 20px; height: 170px; box-sizing: border-box; padding: 16px; border-radius: 28px; background: {CARD}; box-shadow: 0 8px 24px rgba(0,0,0,0.16); display: flex; gap: 14px; animation: pop 0.5s {EASE} 0.1s both;">
<div style="flex-grow: 1; display: flex; flex-direction: column;">
<span style="display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 700;">{app_icon(18)}September</span>
<span style="margin-top: 12px; font-size: 12px; font-weight: 600; color: {SEC};">Spent</span><span style="font-family: {ROUND}; font-size: 24px; line-height: 28px; font-weight: 640;">RM 2,146.30</span>
<span style="margin-top: 8px; font-size: 12px; font-weight: 600; color: {SEC};">Came in</span><span style="font-family: {ROUND}; font-size: 18px; line-height: 22px; font-weight: 640; color: {GREEN};">RM 5,200.00</span>
</div>
<div style="width: 140px; display: flex; flex-direction: column; gap: 6px;"><span style="font-size: 12px; font-weight: 600; color: {SEC};">Log again</span>{widget_btn('Teh tarik', '2.80')}{widget_btn('Grab', '15.00')}{widget_btn('Lunch', '12.00')}</div>
</div>
<div style="position: absolute; top: 252px; left: 20px; width: 170px; height: 170px; box-sizing: border-box; padding: 16px; border-radius: 28px; background: {CARD}; box-shadow: 0 8px 24px rgba(0,0,0,0.16); display: flex; flex-direction: column; animation: pop 0.5s {EASE} 0.2s both;">
<span style="display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 700;">{app_icon(18)}Today</span>
<span style="margin-top: 8px; font-family: {ROUND}; font-size: 28px; line-height: 32px; font-weight: 640;">RM 46.10</span>
<span style="font-size: 12px; color: {SEC};">4 entries</span>
<span style="margin-top: auto; display: flex; flex-direction: column; gap: 4px; font-size: 12px;"><span style="display: flex; justify-content: space-between;"><span>Burger</span><b style="font-weight: 700;">5.00</b></span><span style="display: flex; justify-content: space-between;"><span>Grab ride home</span><b style="font-weight: 700;">18.70</b></span></span>
</div>
<a href="TGListen.dc.html" style="position: absolute; top: 252px; right: 20px; width: 170px; height: 170px; box-sizing: border-box; border-radius: 28px; {GLASS_ON_WALL} display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 10px; animation: pop 0.5s {EASE} 0.3s both;">
<span style="width: 72px; height: 72px; border-radius: 36px; {GLASS_TINT} display: flex; align-items: center; justify-content: center;">{icon("mic", 30, 2.2)}</span>
<span style="font-size: 14px; font-weight: 700; color: #FFFFFF;">Hold to log</span></a>

<span style="{CAP} top: 452px;">CONTROL CENTER</span>
<div style="position: absolute; top: 478px; left: 20px; right: 20px; box-sizing: border-box; padding: 14px; border-radius: 34px; background: rgba(8,24,28,0.32); -webkit-backdrop-filter: blur(20px); backdrop-filter: blur(20px); display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; animation: pop 0.5s {EASE} 0.4s both;">
{control('mic', 'Log by voice', 'Kira', wide=True, tint=True)}{control('scan', 'Scan a screenshot', '')}{control('repeat', 'Log again', '')}
</div>

<span style="{CAP} top: 616px;">ACTION BUTTON</span>
<div style="position: absolute; top: 642px; left: 20px; right: 20px; height: 64px; box-sizing: border-box; padding: 0 10px 0 10px; border-radius: 32px; {GLASS_ON_WALL} display: flex; align-items: center; gap: 12px; animation: pop 0.5s {EASE} 0.5s both;">
<span style="flex-shrink: 0; width: 44px; height: 44px; border-radius: 22px; {GLASS_TINT} display: flex; align-items: center; justify-content: center;">{icon("mic", 20, 2.2)}</span>
<span style="display: flex; flex-direction: column;"><b style="font-size: 15px; font-weight: 700;">Press and hold to log</b><span style="font-size: 12px; opacity: 0.9;">Set the Action button to Kira › Log by voice</span></span>
</div>
<p style="position: absolute; top: 724px; left: 24px; right: 24px; margin: 0; font-size: 13px; line-height: 18px; color: rgba(255,255,255,0.92);">All of these start the same listening screen, so you can log without opening the app.</p>
'''
print('TGWidgets', write('TGWidgets.dc.html', page('Timeline · Widgets and controls', widgets, root_bg=WALL)))
