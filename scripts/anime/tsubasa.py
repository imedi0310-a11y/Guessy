from common import q
META = dict(id='tsubasa', icon='⚽', label=q('كابتن ماجد', 'Captain Tsubasa', 'Olive et Tom', 'Oliver y Benji', 'Super Campeões'),
            sample=q('كوجيرو هيوغا', 'Kojiro Hyuga', 'Mark Landers', 'Mark Lenders', 'Kojiro Hyuga'),
            example=q('هل هو حارس مرمى؟', 'Is he a goalkeeper?', 'Est-il gardien de but ?', '¿Es portero?', 'É goleiro?'))
ATTRS = ['hero', 'hat', 'blond', {
 'japan': q('هل لعب لمنتخب اليابان؟', 'Did it play for the Japan national team?', 'A-t-il joué pour l’équipe du Japon ?', '¿Jugó en la selección de Japón?', 'Jogou pela seleção do Japão?'),
 'nankatsu': q('هل لعب لفريق نانكاتسو؟', 'Did it play for Nankatsu?', 'A-t-il joué pour la New Team ?', '¿Jugó en el Nankatsu?', 'Jogou pelo Nankatsu?'),
 'gk': q('هل هو حارس مرمى؟', 'Is it a goalkeeper?', 'Est-il gardien de but ?', '¿Es portero?', 'É goleiro?'),
 'striker': q('هل هو مهاجم؟', 'Is it a striker?', 'Est-il attaquant ?', '¿Es delantero?', 'É atacante?'),
 'mid': q('هل هو لاعب وسط؟', 'Is it a midfielder?', 'Est-il milieu de terrain ?', '¿Es centrocampista?', 'É meio-campista?'),
 'foreign': q('هل هو من خارج اليابان؟', 'Is it from outside Japan?', 'Vient-il d’un autre pays que le Japon ?', '¿Es de fuera de Japón?', 'É de fora do Japão?'),
 'coach': q('هل هو مدرب؟', 'Is it a coach?', 'Est-ce un entraîneur ?', '¿Es entrenador?', 'É treinador?'),
}]
CHARS = [
 ('tsubasa', '⚽', 'Tsubasa Ozora (Captain Majid)', 'كابتن ماجد (تسوباسا أوزورا)', 'hero japan nankatsu mid', ['ماجد', 'كابتن ماجد', 'تسوباسا']),
 ('misaki', '🤝', 'Taro Misaki', 'تارو ميساكي', 'japan nankatsu mid blond', ['ميساكي']),
 ('ishizaki', '🐵', 'Ryo Ishizaki', 'ريو إيشيزاكي', 'japan nankatsu', ['ايشيزاكي']),
 ('genzo', '🧤', 'Genzo Wakabayashi', 'غينزو واكاباياشي', 'japan gk hat', ['غينزو', 'واكاباياشي']),
 ('wakashimazu', '🥋', 'Ken Wakashimazu', 'كين واكاشيمازو', 'japan gk', ['واكاشيمازو']),
 ('hyuga', '🐯', 'Kojiro Hyuga', 'كوجيرو هيوغا', 'japan striker', ['هيوغا', 'كوجيرو']),
 ('misugi', '💓', 'Jun Misugi', 'جون ميسوغي', 'japan mid', ['ميسوغي']),
 ('roberto', '🇧🇷', 'Roberto Hongo', 'روبيرتو هونغو', 'foreign coach', ['روبيرتو']),
 ('schneider', '🇩🇪', 'Karl Heinz Schneider', 'كارل هاينز شنايدر', 'foreign striker blond', ['شنايدر']),
 ('santana', '🇧🇷', 'Carlos Santana', 'كارلوس سانتانا', 'foreign mid', ['سانتانا']),
 ('pierre', '🇫🇷', 'Elle Sid Pierre', 'إيل سيد بيير', 'foreign mid blond', ['بيير']),
 ('mikami', '🧢', 'Tatsuo Mikami', 'تاتسو ميكامي', 'japan coach hat', ['ميكامي']),
]
