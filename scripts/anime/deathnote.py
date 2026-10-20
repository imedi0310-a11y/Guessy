from common import q
META = dict(id='deathnote', icon='📓', label=q('ديث نوت', 'Death Note', 'Death Note', 'Death Note', 'Death Note'),
            sample=q('إل (L)', 'L', 'L', 'L', 'L'),
            example=q('هل كتب أسماء في مذكرة الموت؟', 'Did he write names in a Death Note?', 'A-t-il écrit des noms dans un Death Note ?', '¿Escribió nombres en una Death Note?', 'Escreveu nomes num Death Note?'))
ATTRS = ['girl', 'hero', 'fly', 'glasses', 'old', 'kid', 'blond', 'black', 'white', {
 'kira': q('هل كتب أسماء في مذكرة الموت؟', 'Did it write names in a Death Note?', 'A-t-il écrit des noms dans un Death Note ?', '¿Escribió nombres en una Death Note?', 'Escreveu nomes num Death Note?'),
 'shinigami': q('هل هو شينيغامي (إله موت)؟', 'Is it a Shinigami (death god)?', 'Est-ce un dieu de la mort ?', '¿Es un shinigami (dios de la muerte)?', 'É um shinigami (deus da morte)?'),
 'detective': q('هل هو محقق يطارد كيرا؟', 'Is it a detective hunting Kira?', 'Est-ce un détective qui traque Kira ?', '¿Es un detective que persigue a Kira?', 'É um detetive caçando Kira?'),
 'police': q('هل هو من الشرطة؟', 'Is it a police officer?', 'Est-ce un policier ?', '¿Es policía?', 'É policial?'),
 'yagami': q('هل هو من عائلة ياغامي؟', 'Is it from the Yagami family?', 'Fait-il partie de la famille Yagami ?', '¿Es de la familia Yagami?', 'É da família Yagami?'),
}]
CHARS = [
 ('light', '📓', 'Light Yagami', 'لايت ياغامي', 'hero kira yagami', ['لايت', 'كيرا']),
 ('l', '🍰', 'L', 'إل (L)', 'detective black', ['ال', 'إل', 'لوليت']),
 ('misa', '🖤', 'Misa Amane', 'ميسا أماني', 'girl kira blond', ['ميسا']),
 ('ryuk', '🍎', 'Ryuk', 'ريوك', 'shinigami fly black', ['ريوك']),
 ('rem', '🦴', 'Rem', 'ريم', 'girl shinigami fly white', ['ريم']),
 ('near', '🧩', 'Near', 'نير', 'detective kid white', ['نير']),
 ('mello', '🍫', 'Mello', 'ميلو', 'detective blond', ['ميلو']),
 ('soichiro', '👮', 'Soichiro Yagami', 'سويتشيرو ياغامي', 'police yagami glasses black', ['سويتشيرو']),
 ('sayu', '🎀', 'Sayu Yagami', 'سايو ياغامي', 'girl yagami', ['سايو']),
 ('matsuda', '🙋', 'Touta Matsuda', 'ماتسودا', 'police black', ['ماتسودا']),
 ('watari', '☕', 'Watari', 'واتاري', 'old', ['واتاري']),
 ('mikami', '⚖️', 'Teru Mikami', 'تيرو ميكامي', 'kira glasses black', ['ميكامي']),
 ('takada', '📺', 'Kiyomi Takada', 'كيومي تاكادا', 'girl kira black', ['تاكادا']),
 ('higuchi', '💼', 'Kyosuke Higuchi', 'كيوسكي هيغوتشي', 'kira', ['هيغوتشي']),
]
