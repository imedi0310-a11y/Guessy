"""Builds the NBA basketball category from Wikidata (most famous NBA players, active + retired).
Writes assets/data/nba.json and photos assets/photos/nba__<qid>.jpg (Wikimedia Commons, free licences).
Entities are matched by English labels (teams, positions, awards) so no hard-coded IDs can go stale."""
import io, json, os, time, urllib.parse, urllib.request, urllib.error

UA = 'GuessyApp/1.0 (https://github.com/imedi0310-a11y/Guessy)'
EP = 'https://query.wikidata.org/sparql'
LIMIT = int(os.environ.get('NBA_LIMIT', '400'))


def sparql(q, tries=5):
    data = urllib.parse.urlencode({'query': q, 'format': 'json'}).encode()
    for i in range(tries):
        try:
            req = urllib.request.Request(EP, data=data, headers={'User-Agent': UA, 'Accept': 'application/sparql-results+json'})
            with urllib.request.urlopen(req, timeout=120) as r:
                return json.load(r)['results']['bindings']
        except Exception as e:
            print('sparql retry', i, e)
            time.sleep(5 * (i + 1))
    raise RuntimeError('sparql failed')


def qid(u):
    return u.rsplit('/', 1)[-1]


rows = sparql(f'''
SELECT ?p ?sl WHERE {{
  ?occ rdfs:label "basketball player"@en . ?p wdt:P106 ?occ ; wikibase:sitelinks ?sl .
  FILTER(?sl >= 20)
}} ORDER BY DESC(?sl) LIMIT {LIMIT + 250}''')
ids = list(dict.fromkeys(qid(r['p']['value']) for r in rows))
print('candidates', len(ids))
P = {i: {'names': {}, 'cs': {}, 'pos': set(), 'teams': set(), 'nba': False, 'awards': set(), 'born': None,
         'dead': False, 'img': None, 'h': None, 'alias': []} for i in ids}

TEAMS = {'Los Angeles Lakers': 'lakers', 'Boston Celtics': 'celtics', 'Chicago Bulls': 'bulls', 'Golden State Warriors': 'warriors',
         'Miami Heat': 'heat', 'San Antonio Spurs': 'spurs', 'New York Knicks': 'knicks', 'Cleveland Cavaliers': 'cavs',
         'Houston Rockets': 'rockets', 'Dallas Mavericks': 'mavs', 'Milwaukee Bucks': 'bucks', 'Philadelphia 76ers': 'sixers',
         'Oklahoma City Thunder': 'okc', 'Phoenix Suns': 'suns', 'Denver Nuggets': 'nuggets'}
ARAB = {'Q262', 'Q1028', 'Q948', 'Q1016', 'Q79', 'Q1049', 'Q1025', 'Q851', 'Q878', 'Q846', 'Q817', 'Q398', 'Q842', 'Q805', 'Q796', 'Q858', 'Q822', 'Q810', 'Q219060', 'Q1045', 'Q977', 'Q970'}
CONT = {'Q15': 'afr', 'Q46': 'eur', 'Q48': 'asia'}

for k in range(0, len(ids), 80):
    chunk = ids[k:k + 80]
    vals = ' '.join('wd:' + i for i in chunk)
    for r in sparql(f'''SELECT ?p ?l WHERE {{ VALUES ?p {{ {vals} }} ?p rdfs:label ?l . FILTER(LANG(?l) IN ("ar","en","fr","es","pt")) }}'''):
        P[qid(r['p']['value'])]['names'][r['l']['xml:lang']] = r['l']['value']
    for r in sparql(f'''SELECT ?p ?a WHERE {{ VALUES ?p {{ {vals} }} ?p skos:altLabel ?a . FILTER(LANG(?a) IN ("ar","en","fr")) }}'''):
        al = P[qid(r['p']['value'])]['alias']
        if len(r['a']['value']) <= 40 and len(al) < 8:
            al.append(r['a']['value'])
    for r in sparql(f'''SELECT ?p ?b ?d ?img ?h WHERE {{ VALUES ?p {{ {vals} }}
        OPTIONAL {{ ?p wdt:P569 ?b }} OPTIONAL {{ ?p wdt:P570 ?d }} OPTIONAL {{ ?p wdt:P18 ?img }}
        OPTIONAL {{ ?p p:P2048/psn:P2048/wikibase:quantityAmount ?h }} }}'''):
        x = P[qid(r['p']['value'])]
        if 'b' in r and not x['born']:
            try: x['born'] = int(r['b']['value'].lstrip('+')[:4])
            except Exception: pass
        if 'd' in r: x['dead'] = True
        if 'img' in r and not x['img']: x['img'] = r['img']['value']
        if 'h' in r and not x['h']:
            try: x['h'] = float(r['h']['value'])  # normalized to metres
            except Exception: pass
    for r in sparql(f'''SELECT ?p ?c ?cont ?iso ?sport WHERE {{ VALUES ?p {{ {vals} }}
        {{ ?p wdt:P1532 ?c . BIND(1 AS ?sport) }} UNION {{ ?p wdt:P27 ?c . BIND(0 AS ?sport) }}
        OPTIONAL {{ ?c wdt:P30 ?cont }} OPTIONAL {{ ?c wdt:P297 ?iso }} }}'''):
        x = P[qid(r['p']['value'])]
        e = x['cs'].setdefault(qid(r['c']['value']), {'sport': False, 'cont': set(), 'iso': None})
        e['sport'] |= r['sport']['value'] == '1'
        if 'cont' in r: e['cont'].add(qid(r['cont']['value']))
        if 'iso' in r: e['iso'] = r['iso']['value']
    for r in sparql(f'''SELECT ?p ?pl WHERE {{ VALUES ?p {{ {vals} }} ?p p:P413/ps:P413 ?pos . ?pos rdfs:label ?pl FILTER(LANG(?pl)="en") }}'''):
        P[qid(r['p']['value'])]['pos'].add(r['pl']['value'].lower())
    for r in sparql(f'''SELECT ?p ?tl ?ll WHERE {{ VALUES ?p {{ {vals} }} ?p p:P54 ?st . ?st ps:P54 ?t ; wikibase:rank ?rk . FILTER(?rk != wikibase:DeprecatedRank) ?t rdfs:label ?tl FILTER(LANG(?tl)="en")
        OPTIONAL {{ ?t wdt:P118 ?lg . ?lg rdfs:label ?ll FILTER(LANG(?ll)="en") }} }}'''):
        x = P[qid(r['p']['value'])]
        t = r['tl']['value']
        if t in TEAMS: x['teams'].add(TEAMS[t])
        if r.get('ll', {}).get('value') == 'National Basketball Association' or t in TEAMS: x['nba'] = True
    for r in sparql(f'''SELECT ?p ?al WHERE {{ VALUES ?p {{ {vals} }} ?p p:P166/ps:P166 ?a . ?a rdfs:label ?al FILTER(LANG(?al)="en") }}'''):
        a = r['al']['value']
        x = P[qid(r['p']['value'])]
        if a == 'NBA Most Valuable Player Award': x['awards'].add('mvp')
        # Hall of Fame / Olympic medals are too incomplete on Wikidata -> not used (answers must be reliable)
    time.sleep(1)


def flag_emoji(iso):
    if not iso or len(iso) != 2: return '🏀'
    return ''.join(chr(0x1F1E6 + ord(ch) - ord('A')) for ch in iso.upper())


cards = []
for i in ids:
    x = P[i]
    n = x['names']
    if 'en' not in n or not x['nba'] or not x['cs'] or not x['born'] or x['born'] < 1925:
        continue
    pos = ' '.join(x['pos'])
    f = set()
    if 'center' in pos or 'centre' in pos: f.add('center')
    elif 'forward' in pos: f.add('forward')
    elif 'guard' in pos: f.add('guard')
    else: continue
    main = next((c for c, e in x['cs'].items() if e['sport']), next(iter(x['cs'])))
    e = x['cs'][main]
    if main == 'Q30': f.add('usa')
    else: f.add('intl')
    if main in ARAB: f.add('arab')
    for ct in e['cont']:
        if ct in CONT: f.add(CONT[ct])
    if main == 'Q142': f.add('fra')
    if main == 'Q16': f.add('can')
    if x['born'] < 1970: f.add('b70')
    if x['born'] < 1990: f.add('old')
    if x['born'] >= 2000: f.add('young')
    if x['dead']: f.add('dead')
    if x['h']:
        if x['h'] >= 2.11: f.add('tall')
        if x['h'] < 1.90: f.add('short')
    f |= x['teams'] | x['awards']
    names = {l: n.get(l) or n['en'] for l in ('ar', 'en', 'fr', 'es', 'pt')}
    cards.append({'id': i, 'emoji': flag_emoji(e['iso']), 'en': n['en'], 'name': names, 'flags': sorted(f),
                  'aliases': x['alias'], 'img_src': x['img']})
    if len(cards) >= LIMIT: break
print('cards', len(cards))
if len(cards) < 50: raise SystemExit('too few NBA players')

from PIL import Image
os.makedirs('assets/photos', exist_ok=True)
got = 0
for c in cards:
    src = c.pop('img_src')
    if not src: continue
    fn = urllib.parse.unquote(src.rsplit('/', 1)[-1])
    url = 'https://commons.wikimedia.org/wiki/Special:FilePath/' + urllib.parse.quote(fn) + '?width=330'
    for t in range(4):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': UA}), timeout=30) as r:
                im = Image.open(io.BytesIO(r.read())).convert('RGB')
            w, h = im.size
            side = min(w, h)
            top = 0 if h > w else (h - side) // 2
            left = (w - side) // 2
            im = im.crop((left, top, left + side, top + side)).resize((256, 256), Image.LANCZOS)
            path = f'assets/photos/nba__{c["id"]}.jpg'
            im.save(path, 'JPEG', quality=74, optimize=True)
            c['img'] = path
            got += 1
            break
        except urllib.error.HTTPError as e:
            if e.code in (429, 503): time.sleep(3 * (t + 1)); continue
            break
        except Exception:
            break
    time.sleep(0.1)
json.dump({'cards': cards}, open('assets/data/nba.json', 'w'), ensure_ascii=False, separators=(',', ':'))
print(f"::notice title=nba::{len(cards)} players, {got} photos. sample: " +
      ' | '.join(f"{s['name']['ar']} {','.join(s['flags'])}" for s in cards[:4]))
