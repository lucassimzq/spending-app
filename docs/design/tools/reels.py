# Builds odometer-style reels: each digit is a column 0-9,0-9,0 that rolls up and settles.
DIGITS = ''.join(f'<span>{d}</span>' for d in list(range(10)) * 2 + [0])

def reel(d, anim=None):
    style = f"display: flex; flex-direction: column; text-align: center; transform: translateY(-{10 + int(d)}em);"
    if anim:
        style += f" animation: {anim};"
    return (f'<span aria-hidden="true" style="display: inline-block; height: 1em; overflow: hidden; vertical-align: top;">'
            f'<span style="{style}">{DIGITS}</span></span>')

def number(text, anims):
    """text like '2,146.30'; anims: list (one per digit) of animation strings or None."""
    out, i = [], 0
    for ch in text:
        if ch.isdigit():
            out.append(reel(ch, anims[i] if i < len(anims) else None))
            i += 1
        else:
            out.append(f'<span aria-hidden="true">{ch}</span>')
    return ''.join(out)

if __name__ == '__main__':
    import sys
    which = sys.argv[1]
    ease = 'cubic-bezier(.2,1.3,.4,1)'
    if which == 'home':
        durs = [0.9, 1.0, 1.1, 1.2, 1.3, 1.4]
        print(number('2,146.30', [f'roll {d}s {ease} 0.15s both' for d in durs]))
    elif which == 'burger':
        print(number('5.00', [f'roll {d}s {ease} 0.9s both' for d in [0.9, 1.0, 1.1]]))
    elif which == 'talk':
        an = [None, None, f'r46 0.9s {ease} 1.0s both', None, f'r38 1.1s {ease} 1.0s both', None]
        print(number('2,166.80', an))
    elif which == 'edit':
        print(number('12.00', [None, f'roll 0.8s {ease} 0.3s both', None, None]))
