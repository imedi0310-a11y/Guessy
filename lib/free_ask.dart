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

  Future<void> _toggle() async {
    if (_listening) return;
    setState(() => _listening = true);
    Sfx.play('tap', haptic: true);
    try {
      final text = await Voice.listen();
      if (!mounted) return;
      if (text != null && text.trim().isNotEmpty) {
        _ctrl.text = text;
        _send();
      }
    } catch (e) {
      _snack(t('voice_unavailable'));
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
