"""Builds the anime modes into assets/data/cards.json (group 'anime').
Run: python3 scripts/anime/build.py  — fails if a mode has two characters with identical answers."""
import json, os, sys
sys.path.insert(0, os.path.dirname(__file__))
from common import COMMON, q
import naruto, onepiece, dragonball, demonslayer, aot, jjk, pokemon, mix, bleach, hxh, mha, conan, fairytail, blackclover, tokyoghoul, deathnote, opm, csm, kenshin, revengers, sololeveling, vinland, tsubasa, slamdunk

MODULES = [mix, naruto, onepiece, dragonball, demonslayer, aot, jjk, bleach, hxh, mha, fairytail, blackclover, tokyoghoul, opm, csm, deathnote, conan, kenshin, revengers, sololeveling, vinland, tsubasa, slamdunk, pokemon]
P = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'data', 'cards.json')
d = json.load(open(P))
ids = {m.META['id'] for m in MODULES}
d['cats'] = [c for c in d['cats'] if c['id'] not in ids]
d['groups'] = {'anime': {'icon': '🎌', 'label': q('أنمي', 'Anime', 'Anime', 'Anime', 'Anime')}}
# a theme colour per anime (tile background), inspired by each show's usual palette
COLORS = {'anime': '#C0392B', 'naruto': '#F39C12', 'onepiece': '#D35400', 'dragonball': '#F1C40F', 'demonslayer': '#16A085',
          'aot': '#7F6A4D', 'jjk': '#5B2C83', 'bleach': '#E67E22', 'hxh': '#27AE60', 'mha': '#2E86C1', 'fairytail': '#E84393',
          'blackclover': '#1E8449', 'tokyoghoul': '#922B21', 'opm': '#F4D03F', 'csm': '#E74C3C', 'deathnote': '#424949',
          'conan': '#2874A6', 'kenshin': '#B03A2E', 'revengers': '#1C2833', 'sololeveling': '#3949AB', 'vinland': '#5D6D7E',
          'tsubasa': '#1ABC9C', 'slamdunk': '#CB4335', 'pokemon': '#F7DC6F'}
bad = False
for m in MODULES:
    attrs = []
    for a in m.ATTRS:
        if isinstance(a, str):
            attrs.append({'key': a, 'q': COMMON[a]})
        else:
            attrs += [{'key': k, 'q': v} for k, v in a.items()]
    keys = [a['key'] for a in attrs]
    assert len(keys) == len(set(keys)), (m.META['id'], 'duplicate question key')
    cards, sig = [], {}
    for cid, em, en, ar, fl, al in m.CHARS:
        f = sorted(set(fl.split()))
        for x in f:
            assert x in keys, (m.META['id'], cid, x)
        names = {'ar': ar, 'en': en, 'fr': en, 'es': en, 'pt': en}
        names.update(getattr(m, 'NAMES', {}).get(cid, {}))
        cards.append({'id': cid, 'emoji': em, 'en': en, 'name': names, 'flags': f, 'aliases': al})
        sig.setdefault(tuple(f), []).append(cid)
    assert len({c['id'] for c in cards}) == len(cards), m.META['id']
    unused = [k for k in keys if not any(k in c['flags'] for c in cards)]
    dups = [v for v in sig.values() if len(v) > 1]
    print(f"{m.META['id']}: {len(cards)} characters, {len(attrs)} questions", 'SAME ANSWERS:' if dups else '', dups or '', 'unused:' if unused else '', unused or '')
    bad |= bool(dups)
    meta = dict(m.META)
    d['cats'].append({'id': meta.pop('id'), 'icon': meta.pop('icon'), 'en': 'anime character', 'noPhotos': True, 'group': 'anime',
                      'label': meta.pop('label'), 'example': meta.pop('example'), 'sample': meta.pop('sample'),
                      'people': True, 'color': COLORS.get(m.META['id']), 'attrs': attrs, 'cards': cards})
if bad:
    sys.exit('fix duplicates')
json.dump(d, open(P, 'w'), ensure_ascii=False, separators=(',', ':'))
print('total anime characters:', sum(len(m.CHARS) for m in MODULES))
