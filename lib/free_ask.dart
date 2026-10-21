import 'package:flutter/material.dart';
import 'data.dart';
import 'prefs.dart';
import 'sfx.dart';
import 'strings.dart';
import 'theme.dart';
import 'voice.dart';

/// Text field + microphone (speech to text) + send button for free questions.
class FreeAskBar extends StatefulWidget {
  final void Function(String text) onSubmit;
  const FreeAskBar({super.key, required this.onSubmit});

  @override
  State<FreeAskBar> createState() => _FreeAskBarState();
}

class _FreeAskBarState extends State<FreeAskBar> {
  final _ctrl = TextEditingController();
  bool _listening = false;

  void _snack(String s) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s), duration: const Duration(seconds: 3)));
  }

  void _onPartial() {
    if (_listening && Voice.partial.value.isNotEmpty) _ctrl.text = Voice.partial.value;
  }

  @override
  void initState() {
    super.initState();
    Voice.partial.addListener(_onPartial);
  }

  Future<void> _toggle() async {
    if (_listening) {
      Voice.stop(); // finish now with what was heard
      return;
    }
    if (Prefs.voiceLang.isEmpty) {
      _snack(t('voice_tip')); // once: tell how to pick a dialect
      Prefs.voiceLang = Voice.current;
    }
    setState(() => _listening = true);
    Sfx.play('tap', haptic: true);
    _ctrl.clear();
    try {
      final text = await Voice.listen();
      if (!mounted) return;
      final heard = (text ?? '').trim().isNotEmpty ? text!.trim() : _ctrl.text.trim();
      if (heard.isNotEmpty) {
        // several guesses of what was said, best first: the game keeps the first one it understands
        _ctrl.text = heard.split('\n').first;
        _ctrl.clear();
        FocusScope.of(context).unfocus();
        widget.onSubmit(heard);
      }
    } catch (e) {
      if (mounted) _snack(Voice.errorText(e));
    } finally {
      if (mounted) setState(() => _listening = false);
    }
  }

  void _pickVoice() {
    Sfx.play('tap');
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Text(t('voice_lang'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final ch in Voice.choices)
              ListTile(
                title: Text(ch.$2),
                trailing: ch.$1 == Voice.current ? const Icon(Icons.check_rounded, color: C.gold) : null,
                onTap: () {
                  Prefs.voiceLang = ch.$1;
                  Navigator.pop(c);
                  _snack('🎤 ${ch.$2}');
                },
              ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    _ctrl.clear();
    FocusScope.of(context).unfocus();
    widget.onSubmit(q);
  }

  @override
  void dispose() {
    Voice.partial.removeListener(_onPartial);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _ctrl,
          maxLength: 120,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _send(),
          decoration: InputDecoration(
            hintText: _listening ? t('listening') : t('ask_free_hint'),
            counterText: '',
            isDense: true,
            filled: true,
            fillColor: C.glass,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: C.gold.withValues(alpha: 0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.gold)),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Material(
        color: _listening ? C.pink : C.glass,
        shape: CircleBorder(side: BorderSide(color: _listening ? C.pink : C.gold.withValues(alpha: 0.5))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _toggle,
          onLongPress: _pickVoice,
          child: SizedBox(width: 46, height: 46, child: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white)),
        ),
      ),
      const SizedBox(width: 6),
      Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: const BoxDecoration(gradient: C.goldGrad, shape: BoxShape.circle),
          child: InkWell(onTap: _send, child: const SizedBox(width: 46, height: 46, child: Icon(Icons.send_rounded, color: C.ink))),
        ),
      ),
    ]);
  }
}

/// Normalizes Arabic/Latin text for loose matching.
String normText(String s) {
  var x = s.toLowerCase();
  x = x.replaceAll(RegExp(r'[ً-ْـ]'), '');
  x = x.replaceAll(RegExp('[أإآ]'), 'ا').replaceAll('ة', 'ه').replaceAll('ى', 'ي').replaceAll('ؤ', 'و').replaceAll('ئ', 'ي');
  x = x.replaceAll(RegExp(r'[؟?!.,،"«»¿¡:;()\[\]\-]'), ' ');
  const accents = {'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'é': 'e', 'è': 'e', 'ê': 'e', 'í': 'i', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ú': 'u', 'ç': 'c', 'ñ': 'n', 'ï': 'i', 'ü': 'u'};
  accents.forEach((k, v) => x = x.replaceAll(k, v));
  return x.replaceAll(RegExp(r'\s+'), ' ').trim();
}

const _stop = {
  'هل', 'هو', 'هي', 'انا', 'في', 'من', 'على', 'او', 'ام', 'يا', 'ما', 'is', 'it', 'a', 'an', 'the', 'does', 'do', 'am', 'i', 'in', 'of',
  'est', 'ce', 'que', 'il', 'elle', 'le', 'la', 'les', 'un', 'une', 'de', 'du', 'es', 'el', 'los', 'las', 'eu', 'ele', 'o', 'os', 'as', 'um', 'uma',
};

Set<String> _tokens(String s) {
  return normText(s)
      .split(' ')
      .map((w) => w.length > 3 && w.startsWith('ال') ? w.substring(2) : w)
      .where((w) => w.isNotEmpty && !_stop.contains(w))
      .toSet();
}

/// Similarity 0..1 between two questions (token overlap).
double qSimilarity(String a, String b) {
  final ta = _tokens(a), tb = _tokens(b);
  if (ta.isEmpty || tb.isEmpty) return 0;
  var hit = 0.0;
  for (final w in ta) {
    if (tb.contains(w)) {
      hit += 1;
    } else if (w.length >= 4 && tb.any((v) => v.length >= 4 && (v.startsWith(w.substring(0, 4)) || w.startsWith(v.substring(0, 4))))) {
      hit += 0.7;
    }
  }
  return hit / ((ta.length + tb.length) / 2);
}


// ---------------------------------------------------------------------------
// Fuzzy name matching ("فنيسيوس" → فينيسيوس جونيور, "vinisius" → Vinícius Júnior)
// ---------------------------------------------------------------------------

const _nameStop = {
  'junior', 'jr', 'جونيور', 'جونيو', 'de', 'da', 'do', 'dos', 'das', 'del', 'di', 'van', 'von', 'der', 'den', 'le', 'la', 'el',
  'al', 'bin', 'ibn', 'بن', 'ابن', 'دي', 'دا', 'دو', 'فان', 'فون', 'لا', 'لو', 'sr', 'filho', 'neto', 'هل', 'هو', 'هي', 'انه',
};

String _strip(String w) => w.length > 4 && w.startsWith('ال') ? w.substring(2) : w;

List<String> _nameTokens(String s) =>
    normText(s).split(' ').map(_strip).where((w) => w.length >= 3 && !_nameStop.contains(w)).toList();

/// Consonant "skeleton": drops vowels / long-vowel letters after the first letter, so
/// different spellings of the same name collapse together.
String _skel(String w) {
  if (w.isEmpty) return w;
  final b = StringBuffer(w[0]);
  String? prev = w[0];
  for (var i = 1; i < w.length; i++) {
    final ch = w[i];
    if ('aeiouyاويهءh'.contains(ch)) continue;
    final n = ch == 'k' || ch == 'q' || ch == 'g' ? 'c' : (ch == 'z' ? 's' : (ch == 'ث' || ch == 'ص' ? 'س' : (ch == 'ق' || ch == 'غ' ? 'ك' : ch)));
    if (n == prev) continue;
    b.write(n);
    prev = n;
  }
  return b.toString();
}

int _lev(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0);
    cur[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      cur[j] = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost].reduce((x, y) => x < y ? x : y);
    }
    prev = cur;
  }
  return prev[b.length];
}

/// 1 = same word, ~0.85 = same name spelled differently, 0 = different.
double _tokScore(String typed, String name) {
  if (typed == name) return 1;
  if (typed.length < 4 || name.length < 4) return 0;
  if (name.startsWith(typed) && typed.length >= 5) return 0.9; // "فينيسي" while typing / voice cut
  final d = _lev(typed, name);
  final allowed = name.length >= 8 ? 2 : 1;
  if (d <= allowed) return 0.9;
  final sa = _skel(typed), sb = _skel(name);
  if (sa.length >= 3 && sa == sb) return 0.85;
  if (sa.length >= 4 && sb.length >= 4 && _lev(sa, sb) <= 1 && sa[0] == sb[0]) return 0.75;
  return 0;
}

final _catCache = <String, _NameIndex>{};

class _NameIndex {
  final Map<CardItem, List<List<String>>> variants = {};
  final Set<String> questionWords = {};
}

_NameIndex _index(Cat cat) => _catCache.putIfAbsent('${cat.id}:${cat.cards.length}', () {
      final ix = _NameIndex();
      for (final a in cat.attrs) {
        for (final v in a.q.values) {
          ix.questionWords.addAll(normText('$v').split(' ').map(_strip));
        }
      }
      for (final c in cat.cards) {
        final all = <String>{...c.names.values.map((e) => '$e'), c.en.replaceAll(RegExp(r'\s*\(.*\)'), ''), ...c.alias};
        ix.variants[c] = all.map(_nameTokens).where((t) => t.isNotEmpty).toList();
      }
      return ix;
    });

/// Cards whose name (in any language, or a nickname) the text refers to, best matches only.
/// Strength of the last [matchCardNames] result: >= 10 means a full name / nickname was written exactly.
double lastNameScore = 0;

List<CardItem> matchCardNames(String text, Cat cat) {
  lastNameScore = 0;
  final ix = _index(cat);
  // "is he FROM Naruto / One Piece?" is a question about the series, not a guess:
  // drop question words that come right after من / from / de ...
  final kept = <String>[];
  var afterFrom = false;
  for (final w in normText(text).split(' ')) {
    if (const {'من', 'فى', 'from', 'of', 'in', 'de', 'do', 'da', 'del', 'des', 'du', 'dans', 'en'}.contains(w)) {
      afterFrom = true;
      kept.add(w);
      continue;
    }
    if (afterFrom && ix.questionWords.contains(_strip(w))) continue;
    afterFrom = false;
    kept.add(w);
  }
  text = kept.join(' ');
  final typed = _nameTokens(text);
  if (typed.isEmpty) return const [];
  final n = ' ${normText(text)} ';
  var best = 0.0;
  var out = <CardItem>[];
  for (final e in ix.variants.entries) {
    var cardBest = 0.0;
    for (final toks in e.value) {
      // full name written exactly → strongest
      // (a nickname made only of question words, e.g. "Real", never counts as a written name)
      if (!toks.every(ix.questionWords.contains) &&
          (n.contains(' ${toks.join(' ')} ') || n.contains(' ال${toks.join(' ')} '))) {
        cardBest = 10.0 + toks.length;
        break;
      }
      var s = 0.0;
      for (final nt in toks) {
        var m = 0.0;
        for (final tt in typed) {
          // a name word that is also a question word ("ريال", "برازيلي") only counts when exact & long
          if (ix.questionWords.contains(tt) && tt != nt) continue;
          final v = _tokScore(tt, nt);
          if (v > m) m = v;
        }
        s += m;
      }
      if (s > cardBest) cardBest = s;
    }
    if (cardBest < 0.75) continue;
    if (cardBest > best + 0.001) {
      best = cardBest;
      out = [e.key];
    } else if ((cardBest - best).abs() <= 0.001) {
      out.add(e.key);
    }
  }
  lastNameScore = best;
  return out;
}

/// Loose search for the guess list.
bool nameMatchesQuery(CardItem d, String query) {
  final q = normText(query);
  if (q.isEmpty) return true;
  if (d.names.values.any((v) => normText('$v').contains(q)) || d.alias.any((v) => normText(v).contains(q))) return true;
  final typed = _nameTokens(query);
  if (typed.isEmpty) return false;
  final all = <String>{...d.names.values.map((e) => '$e'), ...d.alias};
  return typed.every((tt) => all.any((v) => _nameTokens(v).any((nt) => _tokScore(tt, nt) >= 0.75)));
}


// ---------------------------------------------------------------------------
// Understanding free questions (long sentences, dialect, synonyms, opposites)
// ---------------------------------------------------------------------------

/// Words that carry no meaning for matching (question words, "this person", dialect fillers...).
const _filler = {
  // Arabic + Darija
  'هل', 'هال', 'واش', 'ال', 'وش', 'اش', 'شو', 'ايش', 'راه', 'راهو', 'راهي', 'هو', 'هي', 'هم', 'انه', 'انها', 'هذا', 'هذه', 'هاذا', 'هاذي',
  'هاد', 'هادي', 'هادا', 'ذلك', 'تلك', 'الذي', 'التي', 'شخص', 'شخصيه', 'مشهور', 'مشهوره', 'نجم', 'نجمه', 'حيوان', 'شي', 'شيء',
  'حاجه', 'لاعب', 'لاعبه', 'مدرب', 'دوله', 'بلد', 'مهنه', 'اكله', 'يكون', 'تكون', 'كان', 'كانت', 'في', 'من', 'على', 'الى', 'او',
  'ام', 'ما', 'يا', 'مع', 'و', 'ب', 'ل', 'انا', 'نتا', 'انت', 'عندو', 'عنده', 'بطاقتي', 'بطاقه', 'كارطه', 'ديالي', 'تاعي', 'هنا',
  'قل', 'قولي', 'اخبرني', 'member', 'membre', 'miembro', 'membro', 'ممكن', 'يعني', 'بصح', 'صح', 'برك', 'غير', 'كيما', 'مثل', 'جدا', 'بزاف', 'ياسر',
  // English
  'is', 'it', 'he', 'she', 'they', 'are', 'was', 'were', 'a', 'an', 'the', 'this', 'that', 'person', 'player', 'does', 'do', 'did',
  'has', 'have', 'had', 'can', 'my', 'card', 'of', 'in', 'on', 'at', 'to', 'for', 'or', 'and', 'still', 'famous', 'celebrity', 'thing', 'i', 'am', 'very',
  // French / Spanish / Portuguese
  'est', 'ce', 'que', 'qu', 'il', 'elle', 'ils', 'le', 'la', 'les', 'un', 'une', 'de', 'du', 'des', 'cette', 'personne', 'joueur',
  'es', 'el', 'ella', 'los', 'las', 'una', 'esta', 'este', 'persona', 'jugador', 'eu', 'ele', 'ela', 'o', 'os', 'as', 'um', 'uma',
  'essa', 'esse', 'pessoa', 'jogador', 'ainda', 'encore', 'todavia', 'sigue', 'toujours',
  // Darija (DZ / MA / TN), Egyptian, Levantine, Gulf
  'شنو', 'اشنو', 'شكون', 'كاين', 'كاينه', 'ياك', 'راني', 'راك', 'راهم', 'تاع', 'تاعو', 'تاعها', 'ديال', 'ديالو', 'متاع', 'متاعو',
  'كيفاش', 'هذاك', 'هديك', 'هاذاك', 'داك', 'ديك', 'ده', 'دي', 'دا', 'ايه', 'هيدا', 'هيدي', 'هيك', 'عم', 'كده', 'كدا',   'ماشي', 'مشي', 'مش', 'مو', 'موش', 'ليس', 'اليس', 'الا', 'لا', 'نعم', 'اه', 'ايوه', 'واه', 'سبق', 'له', 'لها', 'ان', 'أن', 'قد', 'لقد',
  'ذات', 'يوما', 'يوم', 'مره', 'ابدا', 'خويا', 'صاحبي', 'خو', 'اسمع', 'قلي', 'بربي', 'والله', 'هيا', 'ok', 'اوكي',
  'الكارطه', 'كارتي', 'متاعي', 'اللي', 'الي', 'لي', 'اللى', 'هذي', 'هاي', 'هادو', 'هدول', 'هذول',
  // English / French / Spanish / Portuguese spoken fillers
  'ever', 'like', 'kind', 'sort', 'guy', 'dude', 'someone', 'somebody', 'uh', 'please', 'tell', 'me', 'you', 'your', 'so', 'well',
  'cest', 'c', 'quil', 'quelle', 'alors', 'bon', 'bah', 'euh', 'genre', 'mec', 'gars', 'ton', 'ta', 'ma', 'mon', 'deja', 'jamais',
  'alguna', 'vez', 'tipo', 'eso', 'esto', 'pues', 'oye', 'tio', 'mi', 'tu', 'ya', 'nunca', 'ese',
  'ja', 'alguma', 'cara', 'ne', 'voce', 'minha', 'meu', 'sua', 'seu', 'aquele', 'aquela',
};

/// Same meaning → same word. Values must appear (normalized) in the attribute questions.
const _syn = {
  // dead
  'مات': 'توفي', 'ميت': 'توفي', 'متوفي': 'توفي', 'توفى': 'توفي', 'متوفى': 'توفي', 'راحل': 'توفي', 'رحل': 'توفي', 'مرحوم': 'توفي',
  'dead': 'توفي', 'died': 'توفي', 'deceased': 'توفي', 'mort': 'توفي', 'decede': 'توفي', 'muerto': 'توفي', 'fallecio': 'توفي',
  'morto': 'توفي', 'morreu': 'توفي', 'faleceu': 'توفي',
  // woman
  'امراه': 'امراه', 'مراه': 'امراه', 'انثى': 'امراه', 'انثي': 'امراه', 'بنت': 'امراه', 'فتاه': 'امراه', 'سيده': 'امراه', 'نسا': 'امراه',
  'woman': 'امراه', 'female': 'امراه', 'girl': 'امراه', 'lady': 'امراه', 'femme': 'امراه', 'fille': 'امراه', 'mujer': 'امراه', 'mulher': 'امراه',
  // football words (dialect / short forms)
  'برصا': 'برشلونه', 'بارصا': 'برشلونه', 'بارسا': 'برشلونه', 'برسا': 'برشلونه', 'barca': 'برشلونه', 'barcelona': 'برشلونه',
  'psg': 'باريس', 'باري': 'باريس', 'paris': 'باريس',
  'يونايتد': 'يونايتد', 'مانيو': 'يونايتد', 'سيتي': 'سيتي', 'بايرن': 'بايرن', 'يوفي': 'يوفنتوس', 'juve': 'يوفنتوس',
  'ليغا': 'اسباني', 'liga': 'اسباني', 'بريمرليغ': 'انجليزي', 'البريميرليغ': 'انجليزي', 'بريميرليغ': 'انجليزي', 'بريمير': 'انجليزي',
  'كالتشيو': 'ايطالي', 'بوندسليغا': 'الماني', 'بالون': 'ذهبيه', 'ballon': 'ذهبيه',
  'هداف': 'مهاجم', 'هجوم': 'مهاجم', 'جناح': 'جناح', 'دفاع': 'مدافع', 'بيك': 'مدافع', 'قول': 'حارس', 'كيبر': 'حارس',
  'goalkeeper': 'حارس', 'keeper': 'حارس', 'gardien': 'حارس', 'portero': 'حارس', 'goleiro': 'حارس',
  'striker': 'مهاجم', 'forward': 'مهاجم', 'attaquant': 'مهاجم', 'delantero': 'مهاجم', 'atacante': 'مهاجم',
  'defender': 'مدافع', 'defenseur': 'مدافع', 'defensa': 'مدافع', 'zagueiro': 'مدافع',
  'midfielder': 'وسط', 'milieu': 'وسط', 'centrocampista': 'وسط', 'meia': 'وسط',
  // dialect
  'اروبي': 'اوروبي', 'اوربي': 'اوروبي', 'افريقي': 'افريقيا', 'اسيوي': 'اسيا', 'امريكا': 'امريكي',
  'دزيري': 'جزايري', 'جزائري': 'جزايري', 'مروكي': 'مغربي', 'مصراوي': 'مصري', 'امريكاني': 'امريكي', 'فرانساوي': 'فرنسي',
  'سبنيولي': 'اسباني', 'طليان': 'ايطالي', 'طلياني': 'ايطالي', 'برازيلي': 'برازيلي', 'يغني': 'يغني', 'مغني': 'يغني', 'مطرب': 'يغني', 'يغنى': 'يغني',
  'ممثل': 'ممثل', 'يمثل': 'ممثل', 'كوميدي': 'كوميدي', 'يضحك': 'كوميدي', 'يوتيوبر': 'يوتيوب', 'انستغرام': 'يوتيوب', 'تيك': 'يوتيوب',
  'طاير': 'طاير',
  'كحل': 'اسود', 'كحله': 'اسود', 'كحلا': 'اسود', 'حمر': 'احمر', 'حمرا': 'احمر', 'حمره': 'احمر', 'صفر': 'اصفر', 'صفرا': 'اصفر',
  'خضر': 'اخضر', 'خضرا': 'اخضر', 'زرق': 'ازرق', 'زرقا': 'ازرق', 'شعرو': 'شعره', 'شعرها': 'شعره', 'كورة': 'كره', 'كوره': 'كره',   'طفله': 'امراه', 'بنية': 'امراه', 'بنيه': 'امراه', 'لالة': 'امراه', 'مدام': 'امراه', 'خالتي': 'امراه',
  'يسكن': 'يعيش', 'عايش': 'يعيش', 'يقدر': 'يستطيع', 'يجم': 'يستطيع', 'يعرف': 'يستطيع', 'يقدرش': 'يستطيع', 'يطيرو': 'يطير',
  'لعبت': 'لعب', 'يلعب': 'لعب', 'يلعبو': 'لعب', 'بيلعب': 'لعب', 'كيلعب': 'لعب', 'joue': 'played', 'jouait': 'played', 'jugo': 'played', 'jogou': 'played', 'plays': 'played', 'play': 'played',
  'ربح': 'فاز', 'ربحها': 'فاز', 'داها': 'فاز', 'خذا': 'فاز', 'خدا': 'فاز', 'كسب': 'فاز', 'won': 'won', 'gagne': 'won', 'gano': 'won', 'ganhou': 'won',
  'دزاير': 'جزايري', 'الدزاير': 'جزايري', 'جزاير': 'جزايري', 'الجزاير': 'جزايري', 'المغرب': 'مغربي', 'مصر': 'مصري', 'فرنسا': 'فرنسي', 'اسبانيا': 'اسباني',
  'البرازيل': 'برازيلي', 'برازيل': 'برازيلي', 'ارجنتين': 'ارجنتيني', 'الارجنتين': 'ارجنتيني', 'ايطاليا': 'ايطالي', 'المانيا': 'الماني', 'البرتغال': 'برتغالي',
  'انجلترا': 'انجليزي', 'انقلترا': 'انجليزي', 'انجليز': 'انجليزي', 'اوروبا': 'اوروبي', 'افريقيا': 'افريقيا',
  'algerie': 'algerien', 'algerienne': 'algerien', 'maroc': 'marocain', 'france': 'francais', 'espagne': 'espagnol', 'bresil': 'bresilien',
  'goal': 'حارس', 'لقول': 'حارس', 'بلاكور': 'مهاجم', 'اتاكون': 'مهاجم', 'ديفونسور': 'مدافع', 'ميليو': 'وسط',
  'ناري': 'نار', 'مايي': 'ماء', 'عشبي': 'عشب', 'كهربايي': 'كهرباء', 'جليدي': 'جليد', 'شبحي': 'شبح', 'سام': 'سم',
  'شياطين': 'شيطان', 'عمالقه': 'عملاق', 'قراصنه': 'قرصان', 'يبيض': 'يبيض', 'بيض': 'يبيض',
};

/// Opposites: asking "is he alive?" = asking "has he died?" with the answer reversed.
const _anti = {
  'حي': 'توفي', 'حيه': 'توفي', 'عايش': 'توفي', 'عايشه': 'توفي', 'احياء': 'توفي',
  'alive': 'توفي', 'living': 'توفي', 'vivant': 'توفي', 'vivante': 'توفي', 'vivo': 'توفي', 'viva': 'توفي', 'vive': 'توفي',
  'رجل': 'امراه', 'راجل': 'امراه', 'ذكر': 'امراه', 'man': 'امراه', 'male': 'امراه', 'boy': 'امراه',
  'homme': 'امراه', 'hombre': 'امراه', 'homem': 'امراه',
};

const _phrases = {
  'passed away': 'توفي', 'ballon d or': 'ballon', 'ballon dor': 'ballon', 'كره ذهبيه': 'ذهبيه', 'الكره الذهبيه': 'ذهبيه',
  'paris saint germain': 'باريس', 'paris sg': 'باريس', 'بي اس جي': 'باريس', 'باريس سان جيرمان': 'باريس',
  'man utd': 'يونايتد', 'manchester united': 'يونايتد', 'مانشستر يونايتد': 'يونايتد', 'man city': 'سيتي', 'manchester city': 'سيتي',
  'مانشستر سيتي': 'سيتي', 'real madrid': 'ريال مدريد', 'still alive': 'alive', 'تيك توك': 'يوتيوب',
  'ياكل اللحم': 'مفترس', 'ياكل لحم': 'مفترس', 'eats meat': 'مفترس', 'mange de la viande': 'مفترس',
  'يعوم': 'يعيش ماء', 'يعوم في الما': 'يعيش ماء', 'في الما': 'ماء', 'الما': 'ماء', 'تحت الما': 'ماء',
  'شعرو كحل': 'شعره اسود', 'شعرو اصفر': 'شعره اشقر', 'شعرو اشقر': 'شعره اشقر', 'blond': 'اشقر',
  'مازال حي': 'alive', 'مازال عايش': 'alive', 'باقي حي': 'alive', 'est vivant': 'alive', 'sigue vivo': 'alive', 'ainda vivo': 'alive',
  'est mort': 'توفي', 'is dead': 'توفي', 'الله يرحمو': 'توفي', 'الله يرحمه': 'توفي',
  'كاس العالم': 'كاس العالم', 'المونديال': 'كاس العالم', 'مونديال': 'كاس العالم', 'coupe du monde': 'world cup', 'mundial': 'world cup',
  'ligue des champions': 'champions', 'champions league': 'champions', 'لي شومبيون': 'ابطال', 'شومبيونز': 'ابطال', 'التشامبيونز': 'ابطال',
  'البالون دور': 'ذهبيه', 'بالون دور': 'ذهبيه',
};

/// Also drops attached بال / وال / فال / كال ("بالكرة" -> "كرة") — questions only, not names.
String _qStrip(String w) {
  for (final p in const ['بال', 'وال', 'فال', 'كال']) {
    if (w.length > 5 && w.startsWith(p)) return w.substring(3);
  }
  return _strip(w);
}

String _canonWord(String w) {
  w = _qStrip(w);
  if (w.length > 4 && w.startsWith('لل')) w = w.substring(1); // لليفربول -> ليفربول
  return _syn[w] ?? w;
}

class _QTok {
  final String w;
  final bool anti;
  const _QTok(this.w, this.anti);
}

List<_QTok> _qTokens(String s) {
  var n = ' ${normText(s).replaceAll('’', ' ').replaceAll("'", ' ')} ';
  _phrases.forEach((k, v) {
    final nk = normText(k);
    for (final pre in const ['', 'ل', 'ب', 'و']) {
      n = n.replaceAll(' $pre$nk ', ' $v ');
    }
  });
  final out = <_QTok>[];
  for (final raw in n.split(' ')) {
    if (raw.isEmpty) continue;
    final w0 = _qStrip(raw);
    if (_filler.contains(raw) || _filler.contains(w0)) continue;
    final a = _anti[w0] ?? _anti[raw];
    if (a != null) {
      out.add(_QTok(a, true));
      continue;
    }
    // "ولد" means "born" in questions like "هل ولد قبل 1990" -> keep as born
    // Darija negation "ما…ش" (مايطيرش -> يطير): treated like the plain question
    var r = raw;
    if (r.length > 5 && r.startsWith('ما') && r.endsWith('ش')) r = r.substring(2, r.length - 1);
    final w = _canonWord(r);
    if (w.isEmpty) continue;
    for (final part in w.split(' ')) {
      if (part.isNotEmpty) out.add(_QTok(part, false));
    }
  }
  return out;
}

double _wMatch(String a, String b, [bool prefixTried = false]) {
  if (a == b) return 1;
  // Arabic attached prepositions: لبرشلونة / ببرشلونة = برشلونة
  if (!prefixTried) {
    for (final p in const ['ل', 'ب', 'ك', 'و', 'ف']) {
      if (a.length > 4 && a.startsWith(p) && _wMatch(a.substring(1), b, true) > 0) return 0.95;
      if (b.length > 4 && b.startsWith(p) && _wMatch(a, b.substring(1), true) > 0) return 0.95;
    }
  }
  if (a.length >= 4 && b.length >= 4 && (a.startsWith(b.substring(0, 4)) || b.startsWith(a.substring(0, 4)))) {
    final shorter = a.length < b.length ? a : b;
    final longer = a.length < b.length ? b : a;
    if (longer.startsWith(shorter) || _lev(a, b) <= 2) return 0.85;
  }
  // one letter missing / extra / wrong ("اروبي" = "اوروبي")
  if (a.length >= 5 && b.length >= 5 && _lev(a, b) <= 1) return 0.85;
  return 0;
}

/// Words that only "frame" a question (has / wears / uses / member / hair…): they count 4x less,
/// so "هل عنده شارينغان" still matches "هل يملك عين الشارينغان".
const _light = {
  'يملك', 'لديه', 'عنده', 'عندو', 'له', 'لها', 'عين', 'عيون', 'عضو', 'عضوا', 'يستطيع', 'يقدر', 'يستعمل', 'يلبس', 'يقاتل', 'يغطي',
  'اصبح', 'صار', 'نوع', 'لون', 'لونه', 'اساسي', 'شعره', 'شعر', 'جسمه', 'وجهه', 'فمه', 'واضحه', 'قائد', 'فريق', 'طاقم', 'عشيره', 'عائله',
  'مدرسه', 'قريه', 'own', 'use', 'uses', 'wear', 'wears', 'member', 'hair', 'its', 'type', 'from', 'fight', 'with', 'face', 'clan', 'family',
  'team', 'crew', 'main', 'color', 'colour', 'بوكيمون', 'pokemon', 'ufc', 'اشتهر', 'known', 'best', 'كره', 'قدم', 'football',
};

final _attrCache = <Attr, List<List<String>>>{};

/// Finds which listed question a free sentence means. `not` = the sentence asks the opposite.
({Attr attr, bool not})? matchQuestion(String text, List<Attr> attrs) {
  final input = _qTokens(text);
  if (input.isEmpty) return null;
  var bestScore = 0.0, bestHits = 0.0;
  Attr? best;
  var bestNot = false, tie = false;
  for (final a in attrs) {
    final variants = _attrCache.putIfAbsent(
        a,
        () => a.q.values
            // "A (B)?" can be asked as "A" alone, or with B
            .expand((v) => {'$v', '$v'.replaceAll(RegExp(r'\s*\([^)]*\)'), '')})
            .map((v) => _qTokens(v).where((t) => !t.anti).map((t) => t.w).toList())
            .where((l) => l.isNotEmpty)
            .toList());
    for (final at in variants) {
      var hits = 0.0;
      var anti = 0, plain = 0;
      var total = 0.0;
      for (final w in at) {
        final weight = _light.contains(w) ? 0.25 : 1.0;
        total += weight;
        var m = 0.0;
        var isAnti = false;
        for (final it in input) {
          final v = _wMatch(it.w, w);
          if (v > m) {
            m = v;
            isAnti = it.anti;
          }
        }
        hits += m * weight;
        if (m > 0 && weight == 1.0) isAnti ? anti++ : plain++;
      }
      if (hits == 0) continue;
      final cov = hits / total;
      if (cov < 0.6) continue;
      // the other way round: how much of what the player said is explained by this question?
      // ("did he play in a European league?" must not become "is he European?")
      var inTotal = 0.0, inHit = 0.0;
      for (final it in input) {
        final wt = _light.contains(it.w) ? 0.25 : 1.0;
        inTotal += wt;
        if (at.any((t) => _wMatch(it.w, t) >= 0.75)) inHit += wt;
      }
      final prec = inTotal == 0 ? 1.0 : inHit / inTotal;
      if (prec < 0.5) continue;
      final score = cov * (0.6 + 0.4 * prec);
      final better = score > bestScore + 0.01 || ((score - bestScore).abs() <= 0.01 && hits > bestHits + 0.01);
      final same = (score - bestScore).abs() <= 0.01 && (hits - bestHits).abs() <= 0.01;
      if (better) {
        bestScore = score;
        bestHits = hits;
        best = a;
        bestNot = anti > 0 && plain == 0;
        tie = false;
      } else if (same && best != null && best.key != a.key) {
        tie = true;
      }
    }
  }
  if (best == null || tie) return null;
  return (attr: best, not: bestNot);
}
