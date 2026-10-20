from common import q
META = dict(id='vinland', icon='🛶', label=q('فينلاند ساغا', 'Vinland Saga', 'Vinland Saga', 'Vinland Saga', 'Vinland Saga'),
            sample=q('أسكيلاد', 'Askeladd', 'Askeladd', 'Askeladd', 'Askeladd'),
            example=q('هل هو فايكنغ محارب؟', 'Is he a Viking warrior?', 'Est-ce un guerrier viking ?', '¿Es un guerrero vikingo?', 'É um guerreiro viking?'))
ATTRS = ['girl', 'villain', 'hero', 'sword', 'scar', 'old', 'blond', 'black', 'red', {
 'viking': q('هل هو محارب فايكنغ؟', 'Is it a Viking warrior?', 'Est-ce un guerrier viking ?', '¿Es un guerrero vikingo?', 'É um guerreiro viking?'),
 'king': q('هل هو ملك أو أمير؟', 'Is it a king or prince?', 'Est-ce un roi ou un prince ?', '¿Es rey o príncipe?', 'É rei ou príncipe?'),
 'slave': q('هل كان عبداً في المزرعة؟', 'Was it a slave on the farm?', 'A-t-il été esclave à la ferme ?', '¿Fue esclavo en la granja?', 'Foi escravo na fazenda?'),
 'beard': q('هل له لحية؟', 'Does it have a beard?', 'A-t-il une barbe ?', '¿Tiene barba?', 'Tem barba?'),
}]
CHARS = [
 ('thorfinn', '🗡️', 'Thorfinn', 'تورفين', 'hero viking slave scar blond', ['تورفين', 'ثورفين']),
 ('askeladd', '🦊', 'Askeladd', 'أسكيلاد', 'villain viking sword beard blond', ['اسكيلاد', 'أسكيلاد']),
 ('thors', '🛡️', 'Thors', 'تورز', 'viking sword beard black', ['تورز', 'ثورز']),
 ('canute', '👑', 'Canute', 'كانوت', 'king blond', ['كانوت', 'كنوت']),
 ('thorkell', '🪓', 'Thorkell', 'توركيل', 'viking beard', ['توركيل', 'ثوركيل']),
 ('einar', '🌾', 'Einar', 'آينار', 'slave red', ['اينار', 'آينار']),
 ('sweyn', '🤴', 'Sweyn Forkbeard', 'الملك سفين', 'king old beard', ['سفين']),
 ('leif', '⛵', 'Leif Erikson', 'لايف إريكسون', 'old beard', ['لايف']),
 ('ylva', '🍲', 'Ylva', 'إيلفا', 'girl blond', ['ايلفا', 'إيلفا']),
 ('floki', '🐍', 'Floki', 'فلوكي', 'villain old', ['فلوكي']),
 ('arnheid', '🌸', 'Arnheid', 'أرنهيد', 'girl slave', ['ارنهيد']),
 ('gudrid', '🧭', 'Gudrid', 'غودريد', 'girl black', ['غودريد']),
 ('bjorn', '🍄', 'Bjorn', 'بيورن', 'viking sword', ['بيورن']),
]
