from common import q
META = dict(id='opm', icon='👊', label=q('ون بنش مان', 'One Punch Man', 'One Punch Man', 'One Punch Man', 'One Punch Man'),
            sample=q('جينوس', 'Genos', 'Genos', 'Genos', 'Genos'),
            example=q('هل هو بطل من الفئة S؟', 'Is he an S-Class hero?', 'Est-ce un héros de classe S ?', '¿Es un héroe de Clase S?', 'É um herói Classe S?'))
ATTRS = ['girl', 'villain', 'sword', 'glasses', 'old', 'kid', 'scar', 'bald', 'blond', 'black', 'white', 'green', {
 'assoc': q('هل هو بطل مسجّل في جمعية الأبطال؟', 'Is it a registered Hero Association hero?', 'Est-ce un héros de l’Association des héros ?', '¿Es héroe de la Asociación de Héroes?', 'É herói da Associação de Heróis?'),
 'sclass': q('هل هو بطل من الفئة S؟', 'Is it an S-Class hero?', 'Est-ce un héros de classe S ?', '¿Es un héroe de Clase S?', 'É um herói Classe S?'),
 'monster': q('هل هو وحش؟', 'Is it a monster?', 'Est-ce un monstre ?', '¿Es un monstruo?', 'É um monstro?'),
 'cyborg': q('هل هو سايبورغ أو آلي؟', 'Is it a cyborg or robot?', 'Est-ce un cyborg ou un robot ?', '¿Es un cíborg o robot?', 'É um ciborgue ou robô?'),
 'esper': q('هل يملك قوى خارقة نفسية (تحريك الأشياء بالعقل)؟', 'Is it an esper (psychic powers)?', 'Est-ce un esper (pouvoirs psychiques) ?', '¿Es un esper (poderes psíquicos)?', 'É um esper (poderes psíquicos)?'),
 'martial': q('هل هو خبير فنون قتالية؟', 'Is it a martial artist?', 'Est-ce un expert en arts martiaux ?', '¿Es artista marcial?', 'É artista marcial?'),
 'alien': q('هل هو كائن فضائي؟', 'Is it an alien?', 'Est-ce un extraterrestre ?', '¿Es un extraterrestre?', 'É um alienígena?'),
}]
CHARS = [
 ('saitama', '👊', 'Saitama', 'سايتاما', 'assoc bald', ['سايتاما', 'سيتاما']),
 ('genos', '🦾', 'Genos', 'جينوس', 'assoc sclass cyborg blond', ['جينوس']),
 ('tatsumaki', '🌪️', 'Tatsumaki', 'تاتسوماكي', 'girl assoc sclass esper green', ['تاتسوماكي']),
 ('fubuki', '❄️', 'Fubuki', 'فوبوكي', 'girl assoc esper black', ['فوبوكي']),
 ('bang', '🐺', 'Bang (Silver Fang)', 'بانغ (الناب الفضي)', 'assoc sclass martial old white', ['بانغ', 'الناب الفضي']),
 ('king', '🎮', 'King', 'كينغ', 'assoc sclass scar blond', ['كينغ']),
 ('atomic', '⚔️', 'Atomic Samurai', 'الساموراي الذري', 'assoc sclass sword black', ['اتوميك ساموراي', 'الساموراي']),
 ('metalbat', '🏏', 'Metal Bat', 'ميتال بات', 'assoc sclass black', ['ميتال بات']),
 ('childemperor', '🧒', 'Child Emperor', 'الطفل الإمبراطور', 'assoc sclass kid glasses', ['الطفل الامبراطور']),
 ('driveknight', '🛡️', 'Drive Knight', 'درايف نايت', 'assoc sclass cyborg', ['درايف نايت']),
 ('mumen', '🚲', 'Mumen Rider', 'مومين رايدر', 'assoc glasses', ['مومين رايدر', 'سائق الدراجة']),
 ('garou', '🐺', 'Garou', 'غارو', 'villain martial white', ['غارو', 'جارو']),
 ('boros', '👁️', 'Boros', 'بوروس', 'villain alien', ['بوروس']),
 ('orochi', '🐍', 'Orochi', 'أوروتشي', 'villain monster', ['اوروتشي']),
 ('sonic', '🥷', 'Speed-o’-Sound Sonic', 'سونيك (سرعة الصوت)', 'villain sword martial black', ['سونيك']),
 ('psykos', '🧠', 'Psykos', 'سايكوس', 'girl villain monster esper', ['سايكوس']),
 ('bofoi', '🧪', 'Metal Knight', 'الفارس المعدني', 'assoc sclass cyborg villain', ['ميتال نايت', 'الفارس المعدني']),
]
