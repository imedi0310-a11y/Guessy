from common import q, apply
NEW = [
 ('semolina', q('هل تُصنع من السميد؟', 'Is it made from semolina?', 'Est-ce fait de semoule ?', '¿Está hecho de sémola?', 'É feito de sêmola?')),
 ('stuffed', q('هل هي محشوة؟', 'Is it stuffed / filled?', 'Est-ce farci ou fourré ?', '¿Está relleno?', 'É recheado?')),
 ('east', q('هل أصلها من المشرق أو تركيا؟', 'Is it from the Middle East or Turkey?', 'Vient-il du Moyen-Orient ou de Turquie ?', '¿Es de Oriente Medio o Turquía?', 'É do Oriente Médio ou Turquia?')),
 ('small', q('هل هي صغيرة (أصغر من حبة جوز)؟', 'Is it small (smaller than a walnut)?', 'Est-ce petit (plus petit qu’une noix) ?', '¿Es pequeño (menor que una nuez)?', 'É pequeno (menor que uma noz)?')),
 ('citrus', q('هل هي من الحمضيات؟', 'Is it a citrus fruit?', 'Est-ce un agrume ?', '¿Es un cítrico?', 'É uma fruta cítrica?')),
 ('purple', q('هل لونها بنفسجي؟', 'Is it purple?', 'Est-ce violet ?', '¿Es morado?', 'É roxo?')),
 ('brown', q('هل لونها بني؟', 'Is it brown?', 'Est-ce marron ?', '¿Es marrón?', 'É marrom?')),
 ('white', q('هل لونها أبيض؟', 'Is it white?', 'Est-ce blanc ?', '¿Es blanco?', 'É branco?')),
 ('breakfast', q('هل تؤكل غالباً في الفطور (الصباح)؟', 'Is it usually eaten at breakfast?', 'Est-ce mangé surtout au petit-déjeuner ?', '¿Se come sobre todo en el desayuno?', 'É comido principalmente no café da manhã?')),
 ('leaf', q('هل هي أوراق؟', 'Is it leaves?', 'Ce sont des feuilles ?', '¿Son hojas?', 'São folhas?')),
 ('smell', q('هل رائحتها قوية جداً؟', 'Does it have a very strong smell?', 'A-t-il une odeur très forte ?', '¿Tiene un olor muy fuerte?', 'Tem cheiro muito forte?')),
]
OLD = {
 'semolina': ['couscous', 'kesra', 'mhajeb', 'makroud', 'chakhchoukha'],
 'stuffed': ['dolma', 'bourek', 'mhajeb', 'makroud', 'sandwich', 'burger', 'shawarma', 'tacos', 'hotdog'],
 'east': ['shawarma', 'falafel', 'hummus', 'baklava', 'dolma'],
 'small': ['cherry', 'grapes', 'olive', 'peas', 'raspberry', 'almond', 'peanut', 'shrimp', 'candy', 'dates', 'popcorn'],
 'citrus': ['orange', 'lemon'],
 'purple': ['plum', 'eggplant', 'fig'],
 'brown': ['chocolate', 'coffee', 'dates', 'hotchoc', 'cookie', 'almond', 'peanut', 'mushroom'],
 'white': ['rice', 'milk', 'yogurt', 'loubia', 'garlic', 'coconut'],
 'breakfast': ['egg', 'bread', 'croissant', 'milk', 'coffee', 'tea', 'butter', 'jam', 'honey', 'pancake', 'msemen', 'cheese'],
 'leaf': ['lettuce', 'spinach', 'cabbage'],
 'smell': ['garlic', 'onion', 'fish', 'sardine'],
}
apply('food', NEW, OLD, [])
