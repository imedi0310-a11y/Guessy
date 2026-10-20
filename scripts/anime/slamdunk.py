from common import q
META = dict(id='slamdunk', icon='🏀', label=q('سلام دانك', 'Slam Dunk', 'Slam Dunk', 'Slam Dunk', 'Slam Dunk'),
            sample=q('كايدي روكاوا', 'Kaede Rukawa', 'Kaede Rukawa', 'Kaede Rukawa', 'Kaede Rukawa'),
            example=q('هل يلعب في شوهوكو؟', 'Does he play for Shohoku?', 'Joue-t-il pour Shohoku ?', '¿Juega en Shohoku?', 'Joga pelo Shohoku?'))
ATTRS = ['girl', 'hero', 'glasses', 'scar', 'old', 'red', 'black', {
 'shohoku': q('هل هو من فريق شوهوكو؟', 'Is it from Shohoku?', 'Fait-il partie de Shohoku ?', '¿Es de Shohoku?', 'É do Shohoku?'),
 'captain': q('هل هو قائد فريقه؟', 'Is it its team captain?', 'Est-il capitaine de son équipe ?', '¿Es capitán de su equipo?', 'É capitão do time?'),
 'center': q('هل يلعب في مركز السنتر (تحت السلة)؟', 'Does it play center?', 'Joue-t-il pivot ?', '¿Juega de pívot?', 'Joga de pivô?'),
 'guard': q('هل يلعب كغارد (صانع ألعاب أو مسدد)؟', 'Does it play as a guard?', 'Joue-t-il arrière / meneur ?', '¿Juega de base o escolta?', 'Joga de armador ou ala-armador?'),
 'coach': q('هل هو مدرب؟', 'Is it a coach?', 'Est-ce un entraîneur ?', '¿Es entrenador?', 'É treinador?'),
}]
CHARS = [
 ('sakuragi', '🔴', 'Hanamichi Sakuragi', 'هاناميتشي ساكوراغي', 'hero shohoku red', ['ساكوراغي', 'هاناميتشي']),
 ('rukawa', '🦊', 'Kaede Rukawa', 'كايدي روكاوا', 'shohoku black', ['روكاوا']),
 ('akagi', '🦍', 'Takenori Akagi', 'تاكينوري أكاغي', 'shohoku captain center', ['اكاغي', 'أكاغي']),
 ('mitsui', '🎯', 'Hisashi Mitsui', 'هيساشي ميتسوي', 'shohoku guard scar black', ['ميتسوي']),
 ('miyagi', '💨', 'Ryota Miyagi', 'ريوتا ميياغي', 'shohoku guard', ['ميياغي']),
 ('kogure', '👓', 'Kiminobu Kogure', 'كيمينوبو كوغوري', 'shohoku glasses', ['كوغوري']),
 ('haruko', '🎀', 'Haruko Akagi', 'هاروكو أكاغي', 'girl', ['هاروكو']),
 ('anzai', '🍡', 'Coach Anzai', 'المدرب أنزاي', 'coach old glasses', ['انزاي', 'أنزاي']),
 ('sendoh', '🌊', 'Akira Sendoh', 'أكيرا سيندو', 'black', ['سيندو']),
 ('maki', '👑', 'Shinichi Maki', 'شينيتشي ماكي', 'captain guard', ['ماكي']),
 ('uozumi', '🐟', 'Jun Uozumi', 'جون أوزومي', 'captain center', ['اوزومي']),
]
