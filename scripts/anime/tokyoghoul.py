from common import q
META = dict(id='tokyoghoul', icon='🎭', label=q('طوكيو غول', 'Tokyo Ghoul', 'Tokyo Ghoul', 'Tokyo Ghoul', 'Tokyo Ghoul'),
            sample=q('توكا كيريشيما', 'Touka Kirishima', 'Touka Kirishima', 'Touka Kirishima', 'Touka Kirishima'),
            example=q('هل هو غول؟', 'Is it a ghoul?', 'Est-ce une goule ?', '¿Es un ghoul?', 'É um ghoul?'))
ATTRS = ['girl', 'villain', 'mask', 'glasses', 'old', 'kid', 'blond', 'black', 'white', 'blue', 'green', {
 'ghoul': q('هل هو غول؟', 'Is it a ghoul?', 'Est-ce une goule ?', '¿Es un ghoul?', 'É um ghoul?'),
 'oneeye': q('هل هو نصف غول (بعين واحدة)؟', 'Is it a half-ghoul (one-eyed)?', 'Est-ce une demi-goule (borgne) ?', '¿Es medio ghoul (tuerto)?', 'É meio-ghoul (caolho)?'),
 'ccg': q('هل هو من محققي الـ CCG؟', 'Is it a CCG investigator?', 'Est-ce un inspecteur du CCG ?', '¿Es investigador del CCG?', 'É investigador do CCG?'),
 'anteiku': q('هل يعمل في مقهى أنتيكو؟', 'Does it work at Anteiku café?', 'Travaille-t-il au café Anteiku ?', '¿Trabaja en el café Anteiku?', 'Trabalha no café Anteiku?'),
 'aogiri': q('هل هو من شجرة أوغيري؟', 'Is it in Aogiri Tree?', 'Fait-il partie de l’Arbre Aogiri ?', '¿Es del Árbol Aogiri?', 'É da Árvore Aogiri?'),
}]
CHARS = [
 ('kaneki', '🎭', 'Ken Kaneki', 'كين كانيكي', 'ghoul oneeye anteiku mask white', ['كانيكي', 'هايسي ساساكي', 'ساساكي']),
 ('touka', '🐰', 'Touka Kirishima', 'توكا كيريشيما', 'girl ghoul anteiku mask blue', ['توكا']),
 ('hide', '🎧', 'Hideyoshi Nagachika', 'هيدي ناغاتشيكا', 'blond', ['هيدي']),
 ('rize', '🍷', 'Rize Kamishiro', 'ريزي كاميشيرو', 'girl ghoul villain', ['ريزي']),
 ('yoshimura', '☕', 'Yoshimura', 'يوشيمورا', 'ghoul anteiku old', ['يوشيمورا']),
 ('nishiki', '🐍', 'Nishiki Nishio', 'نيشيكي نيشيو', 'ghoul anteiku glasses', ['نيشيكي']),
 ('hinami', '🌸', 'Hinami Fueguchi', 'هينامي فويغوتشي', 'girl ghoul anteiku kid', ['هينامي']),
 ('amon', '🛡️', 'Koutarou Amon', 'كوتارو أمون', 'ccg black', ['امون', 'أمون']),
 ('mado', '👁️', 'Kureo Mado', 'كوريو مادو', 'ccg old villain', ['مادو']),
 ('juuzou', '🧵', 'Juuzou Suzuya', 'جوزو سوزويا', 'ccg white', ['جوزو', 'سوزويا']),
 ('arima', '🌩️', 'Kishou Arima', 'كيشو أريما', 'ccg glasses white', ['اريما', 'أريما']),
 ('akira', '📋', 'Akira Mado', 'أكيرا مادو', 'girl ccg blond', ['اكيرا', 'أكيرا']),
 ('uta', '🎨', 'Uta', 'أوتا', 'ghoul mask black', ['اوتا', 'أوتا']),
 ('tsukiyama', '🌹', 'Shuu Tsukiyama', 'شو تسوكياما', 'ghoul villain', ['تسوكياما', 'شو']),
 ('jason', '🏒', 'Yamori (Jason)', 'ياموري (جيسون)', 'ghoul aogiri villain mask', ['جيسون', 'ياموري']),
 ('eto', '📕', 'Eto Yoshimura', 'إيتو يوشيمورا', 'girl ghoul aogiri oneeye villain green', ['ايتو', 'إيتو']),
 ('ayato', '🐇', 'Ayato Kirishima', 'أياتو كيريشيما', 'ghoul aogiri black', ['اياتو', 'أياتو']),
 ('tatara', '🐉', 'Tatara', 'تاتارا', 'ghoul aogiri villain mask white', ['تاتارا']),
]
