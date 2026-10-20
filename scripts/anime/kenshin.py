from common import q
META = dict(id='kenshin', icon='⚔️', label=q('ساموراي إكس', 'Rurouni Kenshin', 'Kenshin le vagabond', 'Rurouni Kenshin', 'Samurai X'),
            sample=q('هاجيمي سايتو', 'Hajime Saito', 'Hajime Saito', 'Hajime Saito', 'Hajime Saito'),
            example=q('هل يقاتل بالسيف؟', 'Does he fight with a sword?', 'Se bat-il avec une épée ?', '¿Lucha con espada?', 'Luta com espada?'))
ATTRS = ['girl', 'villain', 'sword', 'scar', 'old', 'kid', 'bald', 'black', 'red', 'white', {
 'kamiya': q('هل يعيش في دوجو كاميا مع كينشين؟', 'Does it live at the Kamiya dojo with Kenshin?', 'Vit-il au dojo Kamiya avec Kenshin ?', '¿Vive en el dojo Kamiya con Kenshin?', 'Vive no dojo Kamiya com Kenshin?'),
 'juppon': q('هل هو من سيوف شيشيو العشرة؟', 'Is it one of Shishio’s Ten Swords (Juppongatana)?', 'Fait-il partie des Juppongatana ?', '¿Es de las Diez Espadas de Shishio?', 'É uma das Dez Espadas de Shishio?'),
 'oniwa': q('هل هو من جماعة الأونيوابانشو؟', 'Is it from the Oniwabanshu?', 'Fait-il partie des Oniwabanshû ?', '¿Es del Oniwabanshu?', 'É do Oniwabanshu?'),
 'police': q('هل يعمل في الشرطة؟', 'Is it a police officer?', 'Est-ce un policier ?', '¿Es policía?', 'É policial?'),
 'ishin': q('هل كان قاتلاً في حرب الباكوماتسو لصالح الإيشين؟', 'Was it an assassin for the Ishin in the Bakumatsu war?', 'Était-il assassin pour les Ishin ?', '¿Fue asesino del Ishin en el Bakumatsu?', 'Foi assassino do Ishin no Bakumatsu?'),
}]
CHARS = [
 ('kenshin', '⚔️', 'Kenshin Himura', 'كينشين هيمورا', 'kamiya ishin sword scar red', ['كينشين', 'ساموراي اكس', 'باتوساي']),
 ('kaoru', '🌸', 'Kaoru Kamiya', 'كاورو كاميا', 'girl kamiya sword black', ['كاورو']),
 ('sanosuke', '✊', 'Sanosuke Sagara', 'سانوسكي ساغارا', 'kamiya', ['سانوسكي', 'سانو']),
 ('yahiko', '🧒', 'Yahiko Myojin', 'ياهيكو ميوجين', 'kamiya kid sword black', ['ياهيكو']),
 ('megumi', '💊', 'Megumi Takani', 'ميغومي تاكاني', 'girl kamiya black', ['ميغومي']),
 ('saito', '🐺', 'Hajime Saito', 'هاجيمي سايتو', 'police sword black', ['سايتو']),
 ('aoshi', '🗡️', 'Aoshi Shinomori', 'أوشي شينوموري', 'oniwa sword black', ['اوشي', 'أوشي']),
 ('misao', '🥷', 'Misao Makimachi', 'ميساو ماكيماتشي', 'girl oniwa black', ['ميساو']),
 ('okina', '👴', 'Okina', 'أوكينا', 'oniwa old', ['اوكينا']),
 ('hiko', '🍶', 'Hiko Seijuro', 'هيكو سيجورو', 'sword black', ['هيكو']),
 ('shishio', '🔥', 'Makoto Shishio', 'ماكوتو شيشيو', 'villain ishin sword', ['شيشيو']),
 ('soujiro', '😊', 'Soujiro Seta', 'سوجيرو سيتا', 'villain juppon sword black', ['سوجيرو']),
 ('anji', '🙏', 'Anji Yukyuzan', 'أنجي يوكيوزان', 'villain juppon bald', ['انجي', 'أنجي']),
 ('usui', '👁️', 'Usui', 'أوسوي', 'villain juppon', ['اوسوي']),
 ('enishi', '🩸', 'Enishi Yukishiro', 'إينيشي يوكيشيرو', 'villain sword white', ['انيشي', 'إينيشي']),
 ('tomoe', '❄️', 'Tomoe Yukishiro', 'توموي يوكيشيرو', 'girl black', ['توموي']),
 ('jine', '🌙', 'Jine Udo', 'جيني أودو', 'villain sword', ['جيني']),
]
