"""Builds assets/data/images.json: card id -> free image URL from Wikipedia/Wikimedia Commons."""
import json, re, sys, time, urllib.parse, urllib.request, urllib.error

OVR = {
 'mouse':'House mouse','penguin':'Emperor penguin','fisherman':'Fishing','actor':'Acting','orange':'Orange (fruit)','dates':'Date palm','chorba soup':'Chorba','bourek':'Börek',
 'zlabia (fried honey sweet)':'Jalebi','donut':'Doughnut','burger':'Hamburger','grilled fish':'Fish as food',
 'mint tea':'Maghrebi mint tea','doctor':'Physician','pilot':'Aircraft pilot',
 'builder':'Construction worker','taxi driver':'Taxicab','postman':'Mail carrier','bank clerk':'Bank teller',
 'football player':'Association football','sports coach':'Coach (sport)','singer':'Singing','painter':'Painting',
 'computer':'Personal computer','radio':'Radio receiver','battery':'Electric battery','light bulb':'Incandescent light bulb',
 'glass cup':'Drinking glass','wall clock':'Clock','key':'Key (lock)','shoes':'Shoe','sofa':'Couch','television':'Television set',
 'nurse':'Nurse','soldier':'Soldier','judge':'Judge','chef':'Chef','barber':'Barber','salad':'Salad','juice':'Juice',
 'Xavi Hernández':'Xavi','Luis de la Fuente':'Luis de la Fuente (footballer, born 1961)','Rodri':'Rodri (footballer, born 1996)',
 'Pedri':'Pedri','Elissa':'Elissa (singer)','Mohamed Fellag':'Fellag','Luis Enrique':'Luis Enrique (footballer)',
 'Palestine':'State of Palestine','Neymar':'Neymar','Soolking':'Soolking','Mohamed Ramadan':'Mohamed Ramadan (actor)',
}
UA = 'GuessyApp/1.0 (https://github.com/imedi0310-a11y/Guessy)'

def fetch(req, timeout=20):
    for i in range(6):
        try:
            return urllib.request.urlopen(req, timeout=timeout)
        except urllib.error.HTTPError as e:
            if e.code in (429, 503) and i < 5:
                time.sleep(2 * (i + 1)); continue
            raise

def summary(title):
    url = 'https://en.wikipedia.org/api/rest_v1/page/summary/' + urllib.parse.quote(title.replace(' ', '_'), safe='')
    req = urllib.request.Request(url, headers={'User-Agent': UA})
    with fetch(req) as r:
        return json.load(r)

def pageimage(title):
    url = ('https://en.wikipedia.org/w/api.php?action=query&format=json&redirects=1&prop=pageimages&piprop=thumbnail'
           '&pithumbsize=330&titles=' + urllib.parse.quote(title))
    req = urllib.request.Request(url, headers={'User-Agent': UA})
    with fetch(req) as r:
        pages = json.load(r).get('query', {}).get('pages', {})
    for p in pages.values():
        th = p.get('thumbnail', {}).get('source')
        if th: return th
    return None

cards = json.load(open('assets/data/cards.json'))
out, miss = {}, []
for cat in cards['cats']:
    for c in cat['cards']:
        cid = f"{cat['id']}.{c['id']}"
        en = re.sub(r'\s*\(.*?\)\s*$', '', c['en']) if c['en'] not in OVR else c['en']
        title = OVR.get(c['en'], OVR.get(en, en))
        if cat['id'] == 'countries':
            title = OVR.get(c['en'], c['en'])
        try:
            src = None
            try:
                s = summary(title)
                if s.get('type') != 'disambiguation':
                    src = s.get('thumbnail', {}).get('source')
            except Exception:
                pass
            if not src:
                src = pageimage(title)
            if not src and cat['people']:
                for extra in [' (footballer)', ' (singer)', ' (actor)', ' (athlete)']:
                    src = pageimage(title + extra)
                    if src: break
            if not src:
                miss.append(f'{cid}={title}'); continue
            out[cid] = src
        except Exception as e:
            miss.append(f'{cid}={title} ({e.__class__.__name__})')
        time.sleep(0.15)
# Download + shrink every photo into the app (works offline, no hotlinking problems)
import io, os
from PIL import Image
os.makedirs('assets/photos', exist_ok=True)
bundled = {}
for cid, u in out.items():
    try:
        req = urllib.request.Request(u, headers={'User-Agent': UA})
        with fetch(req, 30) as r:
            data = r.read()
        im = Image.open(io.BytesIO(data)).convert('RGB')
        w, h = im.size
        side = min(w, h)
        top = 0 if h > w else (h - side) // 2  # keep faces (top) for portraits
        left = (w - side) // 2
        im = im.crop((left, top, left + side, top + side)).resize((256, 256), Image.LANCZOS)
        path = 'assets/photos/' + cid.replace('.', '__') + '.jpg'
        im.save(path, 'JPEG', quality=82, optimize=True)
        bundled[cid] = path
    except Exception as e:
        miss.append(f'{cid} download {getattr(e, "code", e.__class__.__name__)}')
    time.sleep(0.1)
out = bundled
json.dump(out, open('assets/data/images.json', 'w'), ensure_ascii=False, indent=0)
print(f'images: {len(out)} found, {len(miss)} missing')
if miss:
    print('::notice title=missing images::' + ' | '.join(miss)[:3000])


print(f'::notice title=photos bundled::{len(out)} of {sum(len(c["cards"]) for c in cards["cats"])}')
