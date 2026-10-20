"""Builds the 'world players' category from Wikidata: the most famous footballers (active + retired).

Writes assets/data/world.json (+ photos in assets/photos/world__<qid>.jpg).
Every answer is derived from Wikidata facts, so the game's automatic answers stay consistent.
"""
import io, json, os, sys, time, urllib.parse, urllib.request, urllib.error

UA = 'GuessyApp/1.0 (https://github.com/imedi0310-a11y/Guessy)'
EP = 'https://query.wikidata.org/sparql'
LIMIT = int(os.environ.get('WORLD_LIMIT', '1000'))  # cards wanted
FETCH = LIMIT + 450  # some get filtered out (no position, not really footballers...)
MIN_SITELINKS = int(os.environ.get('WORLD_MIN_SL', '15'))


def sparql(q, tries=5):
    data = urllib.parse.urlencode({'query': q, 'format': 'json'}).encode()
    for i in range(tries):
        try:
            req = urllib.request.Request(EP, data=data, headers={'User-Agent': UA, 'Accept': 'application/sparql-results+json'})
            with urllib.request.urlopen(req, timeout=90) as r:
                return json.load(r)['results']['bindings']
        except Exception as e:
            print('sparql retry', i, e)
            time.sleep(5 * (i + 1))
    raise RuntimeError('sparql failed')


def qid(uri):
    return uri.rsplit('/', 1)[-1]


# 1) the most famous footballers (by number of Wikipedia language editions)
rows = sparql(f'''
SELECT ?p ?sl WHERE {{
  ?p wdt:P106 wd:Q937857 ; wikibase:sitelinks ?sl .
  FILTER(?sl >= {MIN_SITELINKS})
}} ORDER BY DESC(?sl) LIMIT {FETCH}''')
ids = [qid(r['p']['value']) for r in rows]
print('players:', len(ids))
if len(ids) < 50:
    raise SystemExit('too few players')

P = {i: {'names': {}, 'countries': set(), 'continents': set(), 'iso': None, 'pos': set(), 'teams': set(),
         'leagues': set(), 'awards': set(), 'born': None, 'dead': False, 'img': None, 'alias': []} for i in ids}

LEAGUE_IDS = {'Q9448': 'prem', 'Q324867': 'liga', 'Q15804': 'seriea', 'Q82595': 'bundes', 'Q13394': 'ligue1'}
LEAGUES = {'Premier League': 'prem', 'La Liga': 'liga', 'LaLiga': 'liga', 'Saudi Professional League': 'saudi', 'Serie A': 'seriea', 'Bundesliga': 'bundes',
           'Ligue 1': 'ligue1', 'Saudi Pro League': 'saudi'}
CLUBS = {'Q8682': 'real', 'Q7156': 'barca', 'Q483020': 'psg', 'Q18656': 'manu', 'Q1130849': 'liv', 'Q9616': 'che',
         'Q9617': 'ars', 'Q50602': 'mci', 'Q1422': 'juve', 'Q1543': 'milan', 'Q631': 'inter', 'Q15789': 'bayern'}
ARAB = {'Q262', 'Q1028', 'Q948', 'Q1016', 'Q79', 'Q1049', 'Q1025', 'Q851', 'Q878', 'Q846', 'Q817', 'Q398', 'Q842',
        'Q805', 'Q796', 'Q858', 'Q822', 'Q810', 'Q219060', 'Q1045', 'Q977', 'Q970', 'Q23792'}
NATION = {'Q262': 'alg', 'Q1028': 'mar', 'Q79': 'egy', 'Q155': 'bra', 'Q414': 'arg', 'Q142': 'fra', 'Q29': 'esp',
          'Q21': 'eng', 'Q145': 'eng', 'Q183': 'ger', 'Q38': 'ita', 'Q45': 'por', 'Q55': 'ned'}
CONT = {'Q15': 'afr', 'Q46': 'eur', 'Q18': 'sam', 'Q49': 'nam', 'Q48': 'asia'}

# extra: today's Arab players (born 1990+) even if less famous worldwide -> for the "stars of today" mode
STARS = int(os.environ.get('STARS_LIMIT', '320'))
try:
    arab_vals = ' '.join('wd:' + c for c in ARAB)
    extra = sparql(f'''SELECT ?p ?sl WHERE {{ VALUES ?c {{ {arab_vals} }}
      ?p wdt:P106 wd:Q937857 ; wdt:P1532|wdt:P27 ?c ; wdt:P569 ?b ; wikibase:sitelinks ?sl .
      FILTER(YEAR(?b) >= 1990 && ?sl >= 8) }} ORDER BY DESC(?sl) LIMIT 220''')
    for r in extra:
        i = qid(r['p']['value'])
        if i not in P:
            ids.append(i)
            P[i] = {'names': {}, 'countries': set(), 'continents': set(), 'iso': None, 'pos': set(), 'teams': set(),
                    'leagues': set(), 'awards': set(), 'born': None, 'dead': False, 'img': None, 'alias': []}
    print('with arab extras:', len(ids))
except Exception as e:
    print('arab extra failed', e)

for k in range(0, len(ids), 80):
    chunk = ids[k:k + 80]
    vals = ' '.join('wd:' + i for i in chunk)
    # labels
    for r in sparql(f'''SELECT ?p ?l WHERE {{ VALUES ?p {{ {vals} }} ?p rdfs:label ?l .
        FILTER(LANG(?l) IN ("ar","en","fr","es","pt")) }}'''):
        P[qid(r['p']['value'])]['names'][r['l']['xml:lang']] = r['l']['value']
    # nicknames / other spellings (Vini Jr., CR7, ...)
    for r in sparql(f'''SELECT ?p ?a WHERE {{ VALUES ?p {{ {vals} }} ?p skos:altLabel ?a .
        FILTER(LANG(?a) IN ("ar","en","fr","es","pt")) }}'''):
        al = P[qid(r['p']['value'])]['alias']
        v = r['a']['value']
        if len(v) <= 40 and v not in al and len(al) < 10:
            al.append(v)
    # birth / death / image / sex
    for r in sparql(f'''SELECT ?p ?b ?d ?img ?sex WHERE {{ VALUES ?p {{ {vals} }}
        OPTIONAL {{ ?p wdt:P569 ?b }} OPTIONAL {{ ?p wdt:P570 ?d }} OPTIONAL {{ ?p wdt:P18 ?img }} OPTIONAL {{ ?p wdt:P21 ?sex }} }}'''):
        x = P[qid(r['p']['value'])]
        if r.get('sex', {}).get('value', '').endswith('/Q6581072'):
            x['woman'] = True
        if 'b' in r and not x['born']:
            try:
                x['born'] = int(r['b']['value'][:5].lstrip('+')[:4])
            except Exception:
                pass
        if 'd' in r:
            x['dead'] = True
        if 'img' in r and not x['img']:
            x['img'] = r['img']['value']
    # country for sport (fallback: citizenship) + continent + ISO code
    for r in sparql(f'''SELECT ?p ?c ?cont ?iso ?sport WHERE {{ VALUES ?p {{ {vals} }}
        {{ ?p wdt:P1532 ?c . BIND(1 AS ?sport) }} UNION {{ ?p wdt:P27 ?c . BIND(0 AS ?sport) }}
        OPTIONAL {{ ?c wdt:P30 ?cont }} OPTIONAL {{ ?c wdt:P297 ?iso }} }}'''):
        x = P[qid(r['p']['value'])]
        c = qid(r['c']['value'])
        sport = r['sport']['value'] == '1'
        x.setdefault('cs', {}).setdefault(c, {'sport': False, 'cont': set(), 'iso': None})
        e = x['cs'][c]
        e['sport'] |= sport
        if 'cont' in r:
            e['cont'].add(qid(r['cont']['value']))
        if 'iso' in r:
            e['iso'] = r['iso']['value']
    # positions
    for r in sparql(f'''SELECT ?p ?pl WHERE {{ VALUES ?p {{ {vals} }} ?p p:P413/ps:P413 ?pos .
        ?pos rdfs:label ?pl FILTER(LANG(?pl)="en") }}'''):
        P[qid(r['p']['value'])]['pos'].add(r['pl']['value'].lower())
    # clubs and their leagues
    # p:/ps: = ALL club statements (wdt: would only return the 'preferred' current club)
    for r in sparql(f'''SELECT ?p ?t ?lg ?ll WHERE {{ VALUES ?p {{ {vals} }} ?p p:P54 ?st . ?st ps:P54 ?t ; wikibase:rank ?rk . FILTER(?rk != wikibase:DeprecatedRank)
        OPTIONAL {{ ?t wdt:P118 ?lg . OPTIONAL {{ ?lg rdfs:label ?ll FILTER(LANG(?ll)="en") }} }} }}'''):
        x = P[qid(r['p']['value'])]
        x['teams'].add(qid(r['t']['value']))
        if 'lg' in r and qid(r['lg']['value']) in LEAGUE_IDS:
            x['leagues'].add(LEAGUE_IDS[qid(r['lg']['value'])])
        if 'll' in r and r['ll']['value'] in LEAGUES:
            x['leagues'].add(LEAGUES[r['ll']['value']])
    # Ballon d'Or
    for r in sparql(f'''SELECT DISTINCT ?p WHERE {{ VALUES ?p {{ {vals} }} ?p p:P166/ps:P166 wd:Q166177 }}'''):
        P[qid(r['p']['value'])]['awards'].add('bdo')
    time.sleep(1)


def flag_emoji(iso, country):
    if country in ('Q21',):
        return '🏴\U000E0067\U000E0062\U000E0065\U000E006E\U000E0067\U000E007F'
    if not iso or len(iso) != 2:
        return '⚽'
    return ''.join(chr(0x1F1E6 + ord(ch) - ord('A')) for ch in iso.upper())


cards = []
for i in ids:
    x = P[i]
    n = x['names']
    if 'en' not in n:
        continue
    cs = x.get('cs', {})
    if not cs:
        continue
    # main country = country-for-sport if present, else first citizenship
    main = next((c for c, e in cs.items() if e['sport']), next(iter(cs)))
    e = cs[main]
    f = set()
    if main in ARAB:
        f.add('arab')
    if main in NATION:
        f.add(NATION[main])
    for ct in e['cont']:
        if ct in CONT:
            f.add(CONT[ct])
    if main in ('Q21', 'Q145', 'Q22', 'Q25', 'Q26'):
        f.add('eur')
    pos = ' '.join(x['pos'])
    if 'goalkeeper' in pos:
        f.add('gk')
    elif any(w in pos for w in ('forward', 'striker', 'winger')):
        f.add('fwd')
    elif 'midfielder' in pos:
        f.add('mid')
    elif any(w in pos for w in ('back', 'defender', 'sweeper', 'libero')):
        f.add('def')
    else:
        continue  # unknown position -> skip, answers must be reliable
    if x['born'] is None or x['born'] < 1920 or len(x['teams']) < 3:
        continue  # skips people famous for something else (e.g. scientists who played as amateurs)
    if x['born'] < 1970:
        f.add('b70')
    if x['born'] < 1990:
        f.add('old')
    if x['born'] >= 2000:
        f.add('young')
    if x['dead']:
        f.add('dead')
    if x.get('woman'):
        f.add('woman')
    f |= x['leagues'] | x['awards']
    for t in x['teams']:
        if t in CLUBS:
            f.add(CLUBS[t])
    names = {l: n.get(l) or n['en'] for l in ('ar', 'en', 'fr', 'es', 'pt')}
    cards.append({'id': i, 'emoji': flag_emoji(e['iso'], main), 'en': n['en'], 'name': names,
                  'flags': sorted(f), 'aliases': x['alias'], 'img_src': x['img'], '_born': x['born']})

allcards = cards
cards = allcards[:LIMIT]  # world: the most famous of all time
stars = [c for c in allcards if c['_born'] >= 1990 and 'dead' not in c['flags']][:STARS]
have = {c['id'] for c in stars}
stars += [c for c in allcards if c['_born'] >= 1990 and 'arab' in c['flags'] and c['id'] not in have][:150]
print('cards:', len(cards), 'stars:', len(stars))

# 2) photos (Commons, free licenses) bundled in the app
from PIL import Image
os.makedirs('assets/photos', exist_ok=True)
got = 0
for c in list({id(c): c for c in cards + stars}.values()):
    src = c.pop('img_src', None)
    if not src:
        continue
    fn = urllib.parse.unquote(src.rsplit('/', 1)[-1])
    url = 'https://commons.wikimedia.org/wiki/Special:FilePath/' + urllib.parse.quote(fn) + '?width=330'
    for t in range(4):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': UA})
            with urllib.request.urlopen(req, timeout=30) as r:
                data = r.read()
            im = Image.open(io.BytesIO(data)).convert('RGB')
            w, h = im.size
            side = min(w, h)
            top = 0 if h > w else (h - side) // 2
            left = (w - side) // 2
            im = im.crop((left, top, left + side, top + side)).resize((256, 256), Image.LANCZOS)
            path = f'assets/photos/world__{c["id"]}.jpg'
            im.save(path, 'JPEG', quality=74, optimize=True)
            c['img'] = path
            got += 1
            break
        except urllib.error.HTTPError as e:
            if e.code in (429, 503):
                time.sleep(3 * (t + 1)); continue
            break
        except Exception:
            break
    time.sleep(0.1)

for c in cards + stars:
    c.pop('_born', None)
json.dump({'cards': cards}, open('assets/data/world.json', 'w'), ensure_ascii=False, separators=(',', ':'))
json.dump({'cards': stars}, open('assets/data/stars.json', 'w'), ensure_ascii=False, separators=(',', ':'))
meta = json.load(open('assets/data/world_meta.json'))
meta.update({'id': 'stars', 'icon': '⭐', 'group': 'sports',
             'label': {'ar': 'نجوم الكرة اليوم', 'en': 'Football stars today', 'fr': 'Stars du foot actuelles',
                       'es': 'Estrellas actuales del fútbol', 'pt': 'Estrelas do futebol atuais'}})
meta['attrs'] = [a for a in meta['attrs'] if a['key'] not in ('b70', 'old', 'dead')]
json.dump(meta, open('assets/data/stars_meta.json', 'w'), ensure_ascii=False, indent=0)
print(f'::notice title=stars::{len(stars)} current players, {sum(1 for c in stars if "arab" in c["flags"])} Arab')
sample = cards[:4]
print(f'::notice title=world players::{len(cards)} players, {got} photos. sample: ' +
      ' | '.join(f"{s['name']['ar']} {s['emoji']} {','.join(s['flags'])}" for s in sample))
