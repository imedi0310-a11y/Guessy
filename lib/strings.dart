// UI strings in 5 languages: [ar, en, fr, es, pt]
const langs = ['ar', 'en', 'fr', 'es', 'pt'];
const langNames = {
  'ar': 'العربية',
  'en': 'English',
  'fr': 'Français',
  'es': 'Español',
  'pt': 'Português',
};

class Lang {
  static String code = 'ar';
  static int get index => langs.indexOf(code) < 0 ? 0 : langs.indexOf(code);
  static bool get rtl => code == 'ar';
}

const Map<String, List<String>> _s = {
  'tagline': ['خمّن البطاقة التي على رأسك', 'Guess the card on your head', 'Devine la carte sur ta tête', 'Adivina la carta en tu cabeza', 'Adivinhe a carta na sua cabeça'],
  'choose_cat': ['اختر الفئة', 'Choose a category', 'Choisis une catégorie', 'Elige una categoría', 'Escolha uma categoria'],
  'difficulty': ['مستوى الذكاء', 'AI level', 'Niveau de l\'IA', 'Nivel de la IA', 'Nível da IA'],
  'easy': ['سهل', 'Easy', 'Facile', 'Fácil', 'Fácil'],
  'mid': ['متوسط', 'Medium', 'Moyen', 'Medio', 'Médio'],
  'hard': ['صعب', 'Hard', 'Difficile', 'Difícil', 'Difícil'],
  'play_ai': ['العب ضد الذكاء الاصطناعي', 'Play vs AI', 'Jouer contre l\'IA', 'Jugar contra la IA', 'Jogar contra a IA'],
  'daily': ['تحدي اليوم', 'Daily challenge', 'Défi du jour', 'Reto diario', 'Desafio diário'],
  'daily_done_today': ['حللته اليوم ✓', 'Solved today ✓', 'Réussi aujourd\'hui ✓', 'Resuelto hoy ✓', 'Resolvido hoje ✓'],
  'lvl': ['مستوى', 'Lv', 'Niv.', 'Nv.', 'Nv.'],
  'streak': ['أيام متتالية', 'day streak', 'jours de suite', 'días seguidos', 'dias seguidos'],
  'wins': ['انتصارات', 'wins', 'victoires', 'victorias', 'vitórias'],
  'ai_name': ['الذكاء الاصطناعي', 'AI', 'IA', 'IA', 'IA'],
  'you': ['أنت', 'You', 'Toi', 'Tú', 'Você'],
  'your_card': ['بطاقتك', 'Your card', 'Ta carte', 'Tu carta', 'Sua carta'],
  'on_head': ['بطاقتك · على رأسك', 'Your card · on your head', 'Ta carte · sur ta tête', 'Tu carta · en tu cabeza', 'Sua carta · na sua cabeça'],
  'their_card': ['بطاقة الخصم', 'Their card', 'Sa carte', 'Su carta', 'Carta dele'],
  'you_see': ['بطاقته · أنت تراها', 'Their card · you see it', 'Sa carte · tu la vois', 'Su carta · tú la ves', 'Carta dele · você vê'],
  'your_turn': ['دورك: اسأل سؤالاً أو خمّن', 'Your turn: ask or guess', 'À toi : demande ou devine', 'Tu turno: pregunta o adivina', 'Sua vez: pergunte ou adivinhe'],
  'ai_thinking': ['الذكاء الاصطناعي يفكر…', 'AI is thinking…', 'L\'IA réfléchit…', 'La IA está pensando…', 'A IA está pensando…'],
  'answer_opp': ['جاوب على سؤال الخصم', 'Answer your opponent', 'Réponds à ton adversaire', 'Responde a tu rival', 'Responda ao adversário'],
  'opp_asks': ['الخصم يسأل عن بطاقته (أنت تراها):', 'Your opponent asks about their card (you see it):', 'L\'adversaire demande sur sa carte (tu la vois) :', 'Tu rival pregunta por su carta (tú la ves):', 'O adversário pergunta sobre a carta dele (você vê):'],
  'opp_guess': ['الخصم يخمّن بطاقته. هل تخمينه صحيح؟', 'Your opponent is guessing. Is it right?', 'L\'adversaire devine. Est-ce correct ?', 'Tu rival adivina. ¿Acertó?', 'O adversário está adivinhando. Acertou?'],
  'card_says': ['💡 حسب بيانات البطاقة: ', '💡 Card data says: ', '💡 Selon la carte : ', '💡 Según la carta: ', '💡 Pelos dados da carta: '],
  'ask': ['اسأل', 'Ask', 'Demander', 'Preguntar', 'Perguntar'],
  'guess': ['خمّن', 'Guess', 'Deviner', 'Adivinar', 'Adivinhar'],
  'yes': ['نعم', 'Yes', 'Oui', 'Sí', 'Sim'],
  'no': ['لا', 'No', 'Non', 'No', 'Não'],
  'is_it_pre': ['هل أنا ', 'Am I ', 'Suis-je ', '¿Soy ', 'Eu sou '],
  'is_it_post': ['؟', '?', ' ?', '?', '?'],
  'you_won': ['عرفت بطاقتك! 🎉', 'You got it! 🎉', 'Trouvé ! 🎉', '¡La adivinaste! 🎉', 'Acertou! 🎉'],
  'you_lost': ['الذكاء الاصطناعي عرف بطاقته', 'The AI guessed its card', 'L\'IA a trouvé sa carte', 'La IA adivinó su carta', 'A IA adivinhou a carta'],
  'moves': ['الحركات', 'Moves', 'Coups', 'Jugadas', 'Jogadas'],
  'your_card_was': ['بطاقتك كانت', 'Your card was', 'Ta carte était', 'Tu carta era', 'Sua carta era'],
  'their_card_was': ['بطاقة الخصم كانت', 'Their card was', 'Sa carte était', 'Su carta era', 'A carta dele era'],
  'play_again': ['العب مرة أخرى', 'Play again', 'Rejouer', 'Jugar otra vez', 'Jogar de novo'],
  'home': ['الرئيسية', 'Home', 'Accueil', 'Inicio', 'Início'],
  'cards': ['البطاقات', 'Cards', 'Cartes', 'Cartas', 'Cartas'],
  'cards_left': ['بطاقات ممكنة', 'possible cards', 'cartes possibles', 'cartas posibles', 'cartas possíveis'],
  'tap_to_guess': ['اضغط على بطاقة لتخمينها', 'Tap a card to guess it', 'Touche une carte pour la deviner', 'Toca una carta para adivinarla', 'Toque numa carta para adivinhar'],
  'confirm_guess': ['تخمين هذه البطاقة؟', 'Guess this card?', 'Deviner cette carte ?', '¿Adivinar esta carta?', 'Adivinhar esta carta?'],
  'cancel': ['إلغاء', 'Cancel', 'Annuler', 'Cancelar', 'Cancelar'],
  'wrong_guess': ['تخمين خاطئ', 'Wrong guess', 'Raté', 'Fallaste', 'Errou'],
  'hint': ['تلميح', 'Hint', 'Indice', 'Pista', 'Dica'],
  'half': ['حذف النصف', '50/50', '50/50', '50/50', '50/50'],
  'skip': ['دور إضافي', 'Extra turn', 'Tour bonus', 'Turno extra', 'Turno extra'],
  'hint_note': ['💡 تلميح', '💡 Hint', '💡 Indice', '💡 Pista', '💡 Dica'],
  'half_done': ['حُذف نصف البطاقات الخاطئة', 'Half the wrong cards removed', 'La moitié des mauvaises cartes retirée', 'Se quitó la mitad de las cartas incorrectas', 'Metade das cartas erradas removida'],
  'skip_armed': ['ستحصل على دور إضافي بعد حركتك', 'You\'ll get an extra turn after your move', 'Tour bonus après ton coup', 'Tendrás un turno extra tras tu jugada', 'Você terá um turno extra após sua jogada'],
  'extra_turn_msg': ['دور إضافي لك!', 'Extra turn!', 'Tour bonus !', '¡Turno extra!', 'Turno extra!'],
  'time_up': ['انتهى الوقت! الدور للخصم', 'Time\'s up! Opponent\'s turn', 'Temps écoulé ! Au tour de l\'adversaire', '¡Tiempo! Turno del rival', 'Tempo esgotado! Vez do adversário'],
  'start_hint': ['ابدأ أنت: اختر سؤالاً جوابه نعم أو لا عن البطاقة التي على رأسك.', 'You start: pick a yes/no question about the card on your head.', 'Tu commences : choisis une question oui/non sur la carte sur ta tête.', 'Empiezas tú: elige una pregunta de sí o no sobre la carta en tu cabeza.', 'Você começa: escolha uma pergunta de sim ou não sobre a carta na sua cabeça.'],
  'daily_intro': ['بطاقة اليوم نفسها لكل اللاعبين. اعرفها بأقل عدد من الحركات.', 'Same card for everyone today. Find it in as few moves as you can.', 'Même carte pour tous aujourd\'hui. Trouve-la en un minimum de coups.', 'La misma carta para todos hoy. Encuéntrala con las menos jugadas.', 'A mesma carta para todos hoje. Descubra com o mínimo de jogadas.'],
  'daily_solved': ['حللت تحدي اليوم! 🏆', 'Daily challenge solved! 🏆', 'Défi du jour réussi ! 🏆', '¡Reto diario resuelto! 🏆', 'Desafio diário resolvido! 🏆'],
  'come_back': ['عد غداً لبطاقة جديدة', 'Come back tomorrow for a new card', 'Reviens demain pour une nouvelle carte', 'Vuelve mañana por una carta nueva', 'Volte amanhã para uma nova carta'],
  'score': ['النتيجة', 'Score', 'Score', 'Marcador', 'Placar'],
  'auto': ['تلقائي', 'auto', 'auto', 'auto', 'auto'],
  'pick_q': ['اختر سؤالاً', 'Pick a question', 'Choisis une question', 'Elige una pregunta', 'Escolha uma pergunta'],
  'no_q_left': ['لا أسئلة أخرى — خمّن الآن', 'No questions left — guess now', 'Plus de questions — devine', 'No quedan preguntas — adivina', 'Sem perguntas — adivinhe'],
  'coming': ['قريباً: الأونلاين مع الأصدقاء، مسابقة الجرس، الأسئلة الحرة', 'Coming soon: online with friends, buzzer quiz, free questions', 'Bientôt : en ligne, quiz buzzer, questions libres', 'Pronto: en línea, quiz de pulsador, preguntas libres', 'Em breve: online, quiz de campainha, perguntas livres'],
  'leave_q': ['الخروج من الجولة؟', 'Leave this round?', 'Quitter la manche ?', '¿Salir de la ronda?', 'Sair da rodada?'],
  'leave': ['خروج', 'Leave', 'Quitter', 'Salir', 'Sair'],
  'stay': ['أكمل', 'Stay', 'Rester', 'Seguir', 'Ficar'],
  'xp_gain': ['نقاط خبرة', 'XP', 'XP', 'XP', 'XP'],
  'loading': ['جارٍ التحميل…', 'Loading…', 'Chargement…', 'Cargando…', 'Carregando…'],
};

String t(String key) {
  final v = _s[key];
  if (v == null) return key;
  return v[Lang.index];
}

/// Pick the current-language value from a {ar,en,fr,es,pt} map.
String loc(Map<String, dynamic>? m) {
  if (m == null) return '';
  final v = m[Lang.code] ?? m['en'] ?? m['ar'];
  return v == null ? '' : v.toString();
}
