"""Builds assets/data/images.json: card id -> free image URL from Wikipedia/Wikimedia Commons."""
import json, re, sys, time, urllib.parse, urllib.request

OVR = {
 'mouse':'House mouse','orange':'Orange (fruit)','dates':'Date palm','chorba soup':'Chorba','bourek':'Börek',
 'zlabia (fried honey sweet)':'Jalebi','donut':'Doughnut','burger':'Hamburger','grilled fish':'Fish as food',
 'mint tea':'Maghrebi mint tea','doctor':'Physician','pilot':'Aircraft pilot','fisherman':'Fisher',
 'builder':'Construction worker','taxi driver':'Taxicab','postman':'Mail carrier','bank clerk':'Bank teller',
 'football player':'Association football','sports coach':'Coach (sport)','singer':'Singing','painter':'Painting',
 'computer':'Personal computer','radio':'Radio receiver','battery':'Electric battery','light bulb':'Incandescent light bulb',
 'glass cup':'Drinking glass','wall clock':'Clock','key':'Key (lock)','shoes':'Shoe','sofa':'Couch','television':'Television set',
 'nurse':'Nurse','soldier':'Soldier','judge':'Judge','chef':'Chef','barber':'Barber','salad':'Salad','juice':'Juice',
 'Xavi Hernández':'Xavi','Luis de la Fuente':'Luis de la Fuente (footballer, born 1961)','Rodri':'Rodri (footballer, born 1996)',
 'Pedri':'Pedri','Elissa':'Elissa (singer)','Mohamed Fellag':'Fellag','Luis Enrique':'Luis Enrique (footballer)',
 'Palestine':'State of Palestine','Neymar':'Neymar','Soolking':'Soolking',
}
UA = 'GuessyApp/1.0 (https://github.com/imedi0310-a11y/Guessy)'

def summary(title):
    url = 'https://en.wikipedia.org/api/rest_v1/page/summary/' + urllib.parse.quote(title.replace(' ', '_'), safe='')
    req = urllib.request.Request(url, headers={'User-Agent': UA})
    with urllib.request.urlopen(req, timeout=20) as r:
        return json.load(r)

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
            s = summary(title)
            if s.get('type') == 'disambiguation' or 'thumbnail' not in s:
                miss.append(f'{cid}={title}'); continue
            src = s['thumbnail']['source']
            src = re.sub(r'/(\d+)px-', '/400px-', src)
            out[cid] = src
        except Exception as e:
            miss.append(f'{cid}={title} ({e.__class__.__name__})')
        time.sleep(0.05)
json.dump(out, open('assets/data/images.json', 'w'), ensure_ascii=False, indent=0)
print(f'images: {len(out)} found, {len(miss)} missing')
if miss:
    print('::notice title=missing images::' + ' | '.join(miss)[:3000])
