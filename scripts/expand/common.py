import json, os
P = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'data', 'cards.json')
def q(ar, en, fr, es, pt): return {'ar': ar, 'en': en, 'fr': fr, 'es': es, 'pt': pt}

def apply(cat_id, new_attrs, old_flags, items):
    """new_attrs: [(key, q)] appended; old_flags: {key: [old card ids having it]}; items: new cards."""
    d = json.load(open(P))
    c = next(x for x in d['cats'] if x['id'] == cat_id)
    have_keys = {a['key'] for a in c['attrs']}
    for k, qq in new_attrs:
        if k not in have_keys:
            c['attrs'].append({'key': k, 'q': qq})
    keys = {a['key'] for a in c['attrs']}
    for k, ids in old_flags.items():
        for x in c['cards']:
            if x['id'] in ids and k not in x['flags']:
                x['flags'].append(k)
    have = {x['id'] for x in c['cards']}
    added = 0
    for it in items:
        cid, em, en, ar, fr, es, pt, fl, al = it
        if cid in have:
            continue
        f = sorted(set(fl.split()))
        for x in f:
            assert x in keys, (cat_id, cid, x)
        c['cards'].append({'id': cid, 'emoji': em, 'en': en, 'name': {'ar': ar, 'en': en[:1].upper() + en[1:], 'fr': fr, 'es': es, 'pt': pt},
                           'flags': f, 'aliases': al})
        added += 1
    sig = {}
    for x in c['cards']:
        sig.setdefault(tuple(sorted(x['flags'])), []).append(x['id'])
    dups = [v for v in sig.values() if len(v) > 1]
    print(f'{cat_id}: +{added} -> {len(c["cards"])} cards, {len(c["attrs"])} questions; same answers: {dups}')
    json.dump(d, open(P, 'w'), ensure_ascii=False, separators=(',', ':'))
    return dups
