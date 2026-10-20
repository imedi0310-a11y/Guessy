from common import q
META = dict(id='sololeveling', icon='🗡️', label=q('سولو ليفلينغ', 'Solo Leveling', 'Solo Leveling', 'Solo Leveling', 'Solo Leveling'),
            sample=q('تشا هاي إن', 'Cha Hae-In', 'Cha Hae-In', 'Cha Hae-In', 'Cha Hae-In'),
            example=q('هل هو صياد من الفئة S؟', 'Is he an S-rank hunter?', 'Est-ce un chasseur de rang S ?', '¿Es un cazador de rango S?', 'É um caçador rank S?'))
ATTRS = ['girl', 'villain', 'hero', 'sword', 'fly', 'glasses', 'old', 'animal', 'blond', 'black', 'red', {
 'hunter': q('هل هو صياد (هنتر)؟', 'Is it a Hunter?', 'Est-ce un chasseur ?', '¿Es un cazador?', 'É um caçador?'),
 'srank': q('هل هو من الفئة S؟', 'Is it S-rank?', 'Est-il de rang S ?', '¿Es de rango S?', 'É rank S?'),
 'shadow': q('هل هو من جنود الظل؟', 'Is it a shadow soldier?', 'Est-ce un soldat de l’ombre ?', '¿Es un soldado de las sombras?', 'É um soldado das sombras?'),
 'monarch': q('هل هو ملك (مونارك)؟', 'Is it a Monarch?', 'Est-ce un Monarque ?', '¿Es un Monarca?', 'É um Monarca?'),
}]
CHARS = [
 ('jinwoo', '🗡️', 'Sung Jin-Woo', 'سونغ جين وو', 'hero hunter srank monarch sword black', ['جين وو', 'جينوو', 'سونغ']),
 ('haein', '🌸', 'Cha Hae-In', 'تشا هاي إن', 'girl hunter srank sword blond', ['هاي ان', 'تشا']),
 ('jinah', '🎒', 'Sung Jin-Ah', 'سونغ جين آه', 'girl black', ['جين اه']),
 ('jinho', '💰', 'Yoo Jin-Ho', 'يو جين هو', 'hunter blond', ['جين هو']),
 ('gunhee', '🏛️', 'Go Gun-Hee', 'غو غون هي', 'hunter srank old', ['غون هي']),
 ('jongin', '🔥', 'Choi Jong-In', 'تشوي جونغ إن', 'hunter srank glasses', ['جونغ ان']),
 ('thomas', '💪', 'Thomas Andre', 'توماس أندريه', 'hunter srank blond', ['توماس']),
 ('igris', '⚔️', 'Igris', 'إيغريس', 'shadow sword red', ['ايغريس', 'إيجريس']),
 ('beru', '🐜', 'Beru', 'بيرو', 'shadow animal fly', ['بيرو']),
 ('tank', '🐻', 'Tank', 'تانك', 'shadow animal', ['تانك']),
 ('kamish', '🐉', 'Kamish', 'كاميش', 'villain animal fly', ['كاميش']),
 ('antares', '🔥', 'Antares', 'أنتاريس', 'villain monarch fly', ['انتاريس']),
 ('dongsoo', '😡', 'Hwang Dong-Soo', 'هوانغ دونغ سو', 'hunter villain', ['دونغ سو']),
]
