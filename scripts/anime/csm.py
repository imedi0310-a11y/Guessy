from common import q
META = dict(id='csm', icon='🪚', label=q('رجل المنشار', 'Chainsaw Man', 'Chainsaw Man', 'Chainsaw Man', 'Chainsaw Man'),
            sample=q('آكي هاياكاوا', 'Aki Hayakawa', 'Aki Hayakawa', 'Aki Hayakawa', 'Aki Hayakawa'),
            example=q('هل هو شيطان؟', 'Is it a devil?', 'Est-ce un démon ?', '¿Es un demonio?', 'É um demônio?'))
ATTRS = ['girl', 'villain', 'sword', 'fly', 'old', 'scar', 'animal', 'blond', 'black', 'white', 'red', {
 'devil': q('هل هو شيطان أو فيند؟', 'Is it a devil or fiend?', 'Est-ce un démon ou un démon possédant ?', '¿Es un demonio o diablo?', 'É um demônio ou diabo?'),
 'hunter': q('هل هو صياد شياطين في الأمن العام؟', 'Is it a Public Safety devil hunter?', 'Est-ce un chasseur de démons de la Sécurité publique ?', '¿Es cazador de demonios de Seguridad Pública?', 'É caçador de demônios da Segurança Pública?'),
 'hybrid': q('هل هو هجين (يتحول بسحب حبل أو سلاح)؟', 'Is it a hybrid (transforms by pulling a cord)?', 'Est-ce un hybride ?', '¿Es un híbrido?', 'É um híbrido?'),
 'eyepatch': q('هل يضع رقعة على عينه؟', 'Does it wear an eyepatch?', 'Porte-t-il un cache-œil ?', '¿Lleva parche en el ojo?', 'Usa tapa-olho?'),
}]
CHARS = [
 ('denji', '🪚', 'Denji', 'دينجي', 'hunter hybrid blond', ['دينجي', 'رجل المنشار']),
 ('power', '🩸', 'Power', 'باور', 'girl hunter devil blond', ['باور']),
 ('aki', '🦊', 'Aki Hayakawa', 'آكي هاياكاوا', 'hunter sword black', ['اكي', 'آكي']),
 ('makima', '🐕', 'Makima', 'ماكيما', 'girl hunter devil villain red', ['ماكيما']),
 ('kobeni', '😰', 'Kobeni Higashiyama', 'كوبيني هيغاشياما', 'girl hunter black', ['كوبيني']),
 ('himeno', '👻', 'Himeno', 'هيمينو', 'girl hunter eyepatch black', ['هيمينو']),
 ('kishibe', '🔪', 'Kishibe', 'كيشيبي', 'hunter old scar', ['كيشيبي']),
 ('pochita', '🐶', 'Pochita', 'بوتشيتا', 'devil animal', ['بوتشيتا']),
 ('reze', '💣', 'Reze', 'ريزي', 'girl hybrid villain black', ['ريزي']),
 ('angel', '😇', 'Angel Devil', 'شيطان الملاك', 'hunter devil fly red', ['الملاك', 'انجل']),
 ('beam', '🦈', 'Beam', 'بيم', 'hunter devil', ['بيم']),
 ('quanxi', '🗡️', 'Quanxi', 'كوانشي', 'girl sword white', ['كوانشي']),
 ('katana', '⚔️', 'Katana Man', 'رجل الكاتانا', 'hybrid villain sword', ['رجل الكاتانا', 'كاتانا مان']),
 ('asa', '📚', 'Asa Mitaka', 'آسا ميتاكا', 'girl black', ['اسا', 'آسا']),
 ('yoru', '⚔️', 'Yoru (War Devil)', 'يورو (شيطان الحرب)', 'girl devil scar', ['يورو']),
]
