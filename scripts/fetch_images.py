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
 'Palestine':'State of Palestine', 'Tite':'Tite (football manager)', 'Marcello Lippi':'Marcello Lippi', 'Ramón Díaz':'Ramón Díaz', 'Hossam Hassan':'Hossam Hassan', 'Rafael Benítez':'Rafael Benítez', 'Gerardo Martino':'Gerardo Martino', 'Roberto Martínez':'Roberto Martínez', 'Óscar Tabárez':'Óscar Tabárez', 'Jorge Jesus':'Jorge Jesus', 'Stephen Keshi':'Stephen Keshi', 'Thierry Henry':'Thierry Henry', 'Aliou Cissé':'Aliou Cissé', 'seal':'Earless seal', 'crow':'Crow', 'pigeon':'Rock dove', 'sparrow':'House sparrow', 'turkey':'Wild turkey', 'falcon':'Peregrine falcon', 'vulture':'Griffon vulture', 'iguana':'Green iguana', 'rat':'Brown rat', 'praying mantis':'Mantis', 'housefly':'Housefly', 'spider':'Spider', 'corn':'Maize', 'peas':'Pea', 'soda':'Soft drink', 'tacos':'Taco', 'karantika':'Karantita', 'kesra':'Kesra', 'loubia':'Baked beans', 'leben':'Buttermilk', 'mhajeb':'Mahjouba', 'qalb el louz':'Qalb el louz', 'prickly pear':'Opuntia ficus-indica', 'drinking water':'Drinking water', 'chili pepper':'Chili pepper', 'electric fan':'Mechanical fan', 'cap':'Baseball cap', 'ring':'Ring (jewellery)', 'ball':'Ball', 'electric drill':'Drill', 'matches':'Match', 'table':'Table (furniture)', 'bookshelf':'Bookcase', 'tablet':'Tablet computer', 'phone charger':'Battery charger', 'printer':'Printer (computing)', 'keyboard':'Computer keyboard', 'game console':'Video game console', 'glue':'Adhesive', 'wristwatch':'Watch', 'socks':'Sock', 'belt':'Belt (clothing)', 'gloves':'Glove', 'slippers':'Slipper', 'trash can':'Waste container', 'coffee machine':'Coffeemaker', 'gas stove':'Gas stove', 'sponge':'Sponge (tool)', 'air conditioner':'Air conditioning', 'heater':'Space heater', 'plate':'Plate (dishware)', 'DJ':'Disc jockey', 'fashion model':'Model (person)', 'cleaner':'Janitor', 'news anchor':'News presenter', 'shoemaker':'Shoemaking', 'potter':'Pottery', 'carpet weaver':'Weaving', 'garbage collector':'Waste collector', 'kindergarten teacher':'Kindergarten', 'house painter':'House painter and decorator', 'delivery driver':'Delivery (commerce)', 'swimmer':'Swimming', 'boxer':'Boxing', 'diver':'Underwater diving', 'customs officer':'Customs', 'weather forecaster':'Weather forecasting', 'hotel receptionist':'Receptionist', 'game developer':'Video game developer', 'Drake':'Drake (musician)', 'Balqees Fathi':'Balqees', 'DR Congo':'Democratic Republic of the Congo', 'Idir':'Idir (singer)', 'The Rock (Dwayne Johnson)':'Dwayne Johnson', 'Dean Ambrose (Jon Moxley)':'Jon Moxley', 'Kane':'Kane (wrestler)', 'Edge':'Edge (wrestler)', 'Lita':'Lita (wrestler)', 'Asuka':'Asuka (wrestler)', 'Gunther':'Gunther (wrestler)', 'Batista':'Dave Bautista', 'Goldberg':'Bill Goldberg', 'Ronda Rousey (WWE)':'Ronda Rousey', '“Macho Man” Randy Savage':'Randy Savage', 'Demetrious Johnson (ONE)':'Demetrious Johnson (fighter)', 'Demetrious Johnson':'Demetrious Johnson (fighter)', 'Francis Ngannou (PFL)':'Francis Ngannou', 'Maurício “Shogun” Rua':'Maurício Rua', 'Quinton “Rampage” Jackson':'Quinton Jackson', 'Michael “Venom” Page':'Michael Page (fighter)', 'Angela Lee':'Angela Lee (fighter)', 'Mark Hunt':'Mark Hunt (fighter)', 'Derrick Lewis':'Derrick Lewis (fighter)', 'Matt Hughes':'Matt Hughes (fighter)', 'Omos':'Omos (wrestler)', 'Big E':'Big E', 'Sheamus':'Sheamus', 'Usman Nurmagomedov':'Usman Nurmagomedov', 'Big Show':'Big Show', 'Yokozuna':'Yokozuna (wrestler)', 'Sean O’Malley':"Sean O'Malley (fighter)", 'Michael Chandler':'Michael Chandler (fighter)', 'Robert Whittaker':'Robert Whittaker (fighter)','Neymar':'Neymar','Soolking':'Soolking','Mohamed Ramadan':'Mohamed Ramadan (actor)',
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
        if cat.get('noPhotos'):
            continue
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
            # only Wikimedia Commons files are freely licensed; local enwiki files (/wikipedia/en/) can be
            # non-free "fair use" images (posters, logos, some portraits) -> never bundle those
            if '/wikipedia/commons/' not in src and cat['id'] != 'countries':  # national flags are public domain
                miss.append(f'{cid}={title} (non-free)'); continue
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
