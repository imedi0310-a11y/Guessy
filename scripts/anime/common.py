"""Shared questions for the anime modes (5 languages)."""
def q(ar, en, fr, es, pt):
    return {'ar': ar, 'en': en, 'fr': fr, 'es': es, 'pt': pt}

COMMON = {
 'girl': q('هل هي فتاة؟', 'Is it a girl?', 'Est-ce une fille ?', '¿Es una chica?', 'É uma garota?'),
 'villain': q('هل هو شرير؟', 'Is it a villain?', 'Est-ce un méchant ?', '¿Es un villano?', 'É um vilão?'),
 'hero': q('هل هو البطل الرئيسي؟', 'Is it the main hero?', 'Est-ce le héros principal ?', '¿Es el protagonista?', 'É o protagonista?'),
 'sword': q('هل يقاتل بالسيف؟', 'Does it fight with a sword?', 'Se bat-il avec une épée ?', '¿Lucha con espada?', 'Luta com espada?'),
 'gun': q('هل يستعمل مسدساً أو سلاحاً نارياً؟', 'Does it use a gun?', 'Utilise-t-il une arme à feu ?', '¿Usa un arma de fuego?', 'Usa arma de fogo?'),
 'fly': q('هل يستطيع الطيران؟', 'Can it fly?', 'Peut-il voler ?', '¿Puede volar?', 'Consegue voar?'),
 'mask': q('هل يغطي وجهه أو فمه بقناع؟', 'Does it cover its face or mouth with a mask?', 'Porte-t-il un masque ?', '¿Lleva máscara?', 'Usa máscara?'),
 'glasses': q('هل يلبس نظارات؟', 'Does it wear glasses?', 'Porte-t-il des lunettes ?', '¿Lleva gafas?', 'Usa óculos?'),
 'hat': q('هل يلبس قبعة؟', 'Does it wear a hat?', 'Porte-t-il un chapeau ?', '¿Lleva sombrero?', 'Usa chapéu?'),
 'scar': q('هل على وجهه ندبة واضحة؟', 'Does it have a visible scar on its face?', 'A-t-il une cicatrice visible au visage ?', '¿Tiene una cicatriz visible en la cara?', 'Tem uma cicatriz visível no rosto?'),
 'old': q('هل هو عجوز؟', 'Is it an old person?', 'Est-ce une personne âgée ?', '¿Es una persona mayor?', 'É uma pessoa idosa?'),
 'kid': q('هل هو طفل؟', 'Is it a child?', 'Est-ce un enfant ?', '¿Es un niño?', 'É uma criança?'),
 'animal': q('هل هو حيوان؟', 'Is it an animal?', 'Est-ce un animal ?', '¿Es un animal?', 'É um animal?'),
 'bald': q('هل هو أصلع أو بلا شعر؟', 'Is it bald (no hair)?', 'Est-il chauve ?', '¿Es calvo?', 'É careca?'),
 'blond': q('هل شعره أشقر؟', 'Is its hair blond?', 'A-t-il les cheveux blonds ?', '¿Tiene el pelo rubio?', 'Tem cabelo loiro?'),
 'black': q('هل شعره أسود؟', 'Is its hair black?', 'A-t-il les cheveux noirs ?', '¿Tiene el pelo negro?', 'Tem cabelo preto?'),
 'white': q('هل شعره أبيض أو فضي؟', 'Is its hair white or silver?', 'A-t-il les cheveux blancs ou argentés ?', '¿Tiene el pelo blanco o plateado?', 'Tem cabelo branco ou prateado?'),
 'red': q('هل شعره أحمر أو برتقالي؟', 'Is its hair red or orange?', 'A-t-il les cheveux roux ou orange ?', '¿Tiene el pelo rojo o naranja?', 'Tem cabelo ruivo ou laranja?'),
 'pink': q('هل شعره أو لونه وردي؟', 'Is its hair (or body) pink?', 'Est-il rose (cheveux ou corps) ?', '¿Es rosa (pelo o cuerpo)?', 'É rosa (cabelo ou corpo)?'),
 'green': q('هل شعره أخضر؟', 'Is its hair green?', 'A-t-il les cheveux verts ?', '¿Tiene el pelo verde?', 'Tem cabelo verde?'),
 'blue': q('هل شعره أزرق؟', 'Is its hair blue?', 'A-t-il les cheveux bleus ?', '¿Tiene el pelo azul?', 'Tem cabelo azul?'),
}
