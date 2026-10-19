import 'package:flutter/material.dart';
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
