import 'package:flutter/material.dart';
import 'data.dart';
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
    setState(() => _listening = true);
    Sfx.play('tap', haptic: true);
    _ctrl.clear();
    try {
      final text = await Voice.listen();
      if (!mounted) return;
      final heard = (text ?? '').trim().isNotEmpty ? text!.trim() : _ctrl.text.trim();
      if (heard.isNotEmpty) {
        _ctrl.text = heard;
        _send();
      }
    } catch (e) {
      if (mounted) _snack(Voice.errorText(e));
    } finally {
      if (mounted) setState(() => _listening = false);
    }
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
  x = x.replaceAll(RegExp(r'[؟?!.,،"«»¿¡:;\-]'), ' ');
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
    final n = ch == 'k' || ch == 'q' ? 'c' : (ch == 'z' ? 's' : (ch == 'ث' || ch == 'ص' ? 'س' : (ch == 'ق' ? 'ك' : ch)));
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
List<CardItem> matchCardNames(String text, Cat cat) {
  final typed = _nameTokens(text);
  if (typed.isEmpty) return const [];
  final ix = _index(cat);
  final n = ' ${normText(text)} ';
  var best = 0.0;
  var out = <CardItem>[];
  for (final e in ix.variants.entries) {
    var cardBest = 0.0;
    for (final toks in e.value) {
      // full name written exactly → strongest
      if (n.contains(' ${toks.join(' ')} ') || n.contains(' ال${toks.join(' ')} ')) {
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
  'هل', 'هال', 'واش', 'وش', 'اش', 'شو', 'ايش', 'راه', 'راهو', 'راهي', 'هو', 'هي', 'هم', 'انه', 'انها', 'هذا', 'هذه', 'هاذا', 'هاذي',
  'هاد', 'هادي', 'هادا', 'ذلك', 'تلك', 'الذي', 'التي', 'شخص', 'شخصيه', 'مشهور', 'مشهوره', 'نجم', 'نجمه', 'حيوان', 'شي', 'شيء',
  'حاجه', 'لاعب', 'لاعبه', 'مدرب', 'دوله', 'بلد', 'مهنه', 'اكله', 'يكون', 'تكون', 'كان', 'كانت', 'في', 'من', 'على', 'الى', 'او',
  'ام', 'ما', 'يا', 'مع', 'و', 'ب', 'ل', 'انا', 'نتا', 'انت', 'عندو', 'عنده', 'بطاقتي', 'بطاقه', 'كارطه', 'ديالي', 'تاعي', 'هنا',
  'قل', 'قولي', 'اخبرني', 'ممكن', 'يعني', 'بصح', 'صح', 'برك', 'غير', 'كيما', 'مثل', 'جدا', 'بزاف', 'ياسر',
  // English
  'is', 'it', 'he', 'she', 'they', 'are', 'was', 'were', 'a', 'an', 'the', 'this', 'that', 'person', 'player', 'does', 'do', 'did',
  'has', 'have', 'had', 'can', 'my', 'card', 'of', 'in', 'on', 'at', 'to', 'for', 'or', 'and', 'still', 'famous', 'celebrity', 'thing', 'i', 'am', 'very',
  // French / Spanish / Portuguese
  'est', 'ce', 'que', 'qu', 'il', 'elle', 'ils', 'le', 'la', 'les', 'un', 'une', 'de', 'du', 'des', 'cette', 'personne', 'joueur',
  'es', 'el', 'ella', 'los', 'las', 'una', 'esta', 'este', 'persona', 'jugador', 'eu', 'ele', 'ela', 'o', 'os', 'as', 'um', 'uma',
  'essa', 'esse', 'pessoa', 'jogador', 'ainda', 'encore', 'todavia', 'sigue', 'toujours',
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
  'دزيري': 'جزايري', 'جزائري': 'جزايري', 'مروكي': 'مغربي', 'مصراوي': 'مصري', 'امريكاني': 'امريكي', 'فرانساوي': 'فرنسي',
  'سبنيولي': 'اسباني', 'طليان': 'ايطالي', 'طلياني': 'ايطالي', 'برازيلي': 'برازيلي', 'يغني': 'يغني', 'مغني': 'يغني', 'مطرب': 'يغني', 'يغنى': 'يغني',
  'ممثل': 'ممثل', 'يمثل': 'ممثل', 'كوميدي': 'كوميدي', 'يضحك': 'كوميدي', 'يوتيوبر': 'يوتيوب', 'انستغرام': 'يوتيوب', 'تيك': 'يوتيوب',
  'طاير': 'طاير', 'يبيض': 'يبيض', 'بيض': 'يبيض',
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
};

String _canonWord(String w) {
  w = _strip(w);
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
  _phrases.forEach((k, v) => n = n.replaceAll(' ${normText(k)} ', ' $v '));
  final out = <_QTok>[];
  for (final raw in n.split(' ')) {
    if (raw.isEmpty) continue;
    final w0 = _strip(raw);
    if (_filler.contains(raw) || _filler.contains(w0)) continue;
    final a = _anti[w0] ?? _anti[raw];
    if (a != null) {
      out.add(_QTok(a, true));
      continue;
    }
    // "ولد" means "born" in questions like "هل ولد قبل 1990" -> keep as born
    final w = _canonWord(raw);
    if (w.isNotEmpty) out.add(_QTok(w, false));
  }
  return out;
}

double _wMatch(String a, String b, [bool prefixTried = false]) {
  if (a == b) return 1;
  // Arabic attached prepositions: لبرشلونة / ببرشلونة = برشلونة
  if (!prefixTried) {
    for (final p in const ['ل', 'ب']) {
      if (a.length > 4 && a.startsWith(p) && _wMatch(a.substring(1), b, true) > 0) return 0.95;
      if (b.length > 4 && b.startsWith(p) && _wMatch(a, b.substring(1), true) > 0) return 0.95;
    }
  }
  if (a.length >= 4 && b.length >= 4 && (a.startsWith(b.substring(0, 4)) || b.startsWith(a.substring(0, 4)))) {
    final shorter = a.length < b.length ? a : b;
    final longer = a.length < b.length ? b : a;
    if (longer.startsWith(shorter) || _lev(a, b) <= 2) return 0.85;
  }
  return 0;
}

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
        a, () => a.q.values.map((v) => _qTokens('$v').where((t) => !t.anti).map((t) => t.w).toList()).where((l) => l.isNotEmpty).toList());
    for (final at in variants) {
      var hits = 0.0;
      var anti = 0, plain = 0;
      for (final w in at) {
        var m = 0.0;
        var isAnti = false;
        for (final it in input) {
          final v = _wMatch(it.w, w);
          if (v > m) {
            m = v;
            isAnti = it.anti;
          }
        }
        hits += m;
        if (m > 0) isAnti ? anti++ : plain++;
      }
      if (hits == 0) continue;
      final cov = hits / at.length;
      if (cov < 0.6) continue;
      final better = cov > bestScore + 0.01 || ((cov - bestScore).abs() <= 0.01 && hits > bestHits + 0.01);
      final same = (cov - bestScore).abs() <= 0.01 && (hits - bestHits).abs() <= 0.01;
      if (better) {
        bestScore = cov;
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
