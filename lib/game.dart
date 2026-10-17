import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'data.dart';
import 'strings.dart';

enum Who { me, opp }

enum Kind { q, g }

class LogEntry {
  final Who who;
  final Kind kind;
  final String text;
  String? ans; // 'yes' | 'no'
  bool? ok; // for guesses
  String? note;
  LogEntry(this.who, this.kind, this.text, {this.ans, this.ok, this.note});
}

class Pending {
  final Kind kind;
  final String text;
  final String? key;
  final String? guessId;
  final bool suggestYes;
  final LogEntry entry;
  Pending(this.kind, this.text, this.entry, {this.key, this.guessId, required this.suggestYes});
}

class GameResult {
  final bool win;
  final int moves;
  GameResult(this.win, this.moves);
}

/// Daily card: same for everyone on a given date.
CardItem dailyCard(List<Cat> cats, DateTime day) {
  final n = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ 86400000;
  final cat = cats[n % cats.length];
  return cat.cards[(n * 7919 + 13) % cat.cards.length];
}

class GameController extends ChangeNotifier {
  final Cat cat;
  final String diff; // easy | mid | hard
  final bool daily;
  late final CardItem myCard;
  CardItem? oppCard;

  final List<LogEntry> log = [];
  Who turn = Who.me;
  Pending? pending;
  GameResult? over;

  final Map<String, bool> myKnown = {};
  final Set<String> myWrong = {};
  final Set<String> removed = {};
  final Map<String, bool> botAnswers = {};
  final Set<String> botWrong = {};

  bool lifeHint = true, lifeHalf = true, lifeSkip = true, skipNext = false;
  static const turnSecs = 45;
  int secsLeft = turnSecs;
  String? flash; // one-shot message key for the UI
  void Function(GameResult)? onEnd;

  Timer? _timer;
  bool _disposed = false;
  final _rnd = Random();

  GameController({required this.cat, required this.diff, this.daily = false, CardItem? fixedCard}) {
    myCard = fixedCard ?? cat.cards[_rnd.nextInt(cat.cards.length)];
    if (!daily) {
      CardItem b;
      do {
        b = cat.cards[_rnd.nextInt(cat.cards.length)];
      } while (b.id == myCard.id);
      oppCard = b;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  int get myMoves => log.where((e) => e.who == Who.me && e.note == null).length;
  bool get canAct => turn == Who.me && pending == null && over == null;
  List<Attr> get unasked => cat.attrs.where((a) => !myKnown.containsKey(a.key)).toList();

  bool consistent(CardItem c) {
    if (myWrong.contains(c.id) || removed.contains(c.id)) return false;
    for (final e in myKnown.entries) {
      if (c.flags.contains(e.key) != e.value) return false;
    }
    return true;
  }

  List<CardItem> get possible => cat.cards.where(consistent).toList();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _tick() {
    if (over != null || turn != Who.me || pending != null) return;
    secsLeft--;
    if (secsLeft <= 0) {
      flash = 'time_up';
      _passToBot();
      return;
    }
    _notify();
  }

  // ---------- player actions ----------
  void ask(Attr a) {
    if (!canAct || myKnown.containsKey(a.key)) return;
    final yes = myCard.flags.contains(a.key);
    myKnown[a.key] = yes;
    log.add(LogEntry(Who.me, Kind.q, a.text, ans: yes ? 'yes' : 'no'));
    _afterMyTurn();
  }

  void guess(CardItem c) {
    if (!canAct) return;
    final ok = c.id == myCard.id;
    log.add(LogEntry(Who.me, Kind.g, '${t('is_it_pre')}${c.name}${t('is_it_post')}', ok: ok));
    if (ok) {
      _end(true);
      return;
    }
    myWrong.add(c.id);
    flash = 'wrong_guess';
    _afterMyTurn();
  }

  void useHint() {
    if (!canAct || !lifeHint) return;
    final pool = cat.attrs.where((a) => !myKnown.containsKey(a.key)).toList();
    if (pool.isEmpty) return;
    final yesPool = pool.where((a) => myCard.flags.contains(a.key)).toList();
    final a = (yesPool.isNotEmpty ? yesPool : pool)[_rnd.nextInt((yesPool.isNotEmpty ? yesPool : pool).length)];
    final yes = myCard.flags.contains(a.key);
    myKnown[a.key] = yes;
    log.add(LogEntry(Who.me, Kind.q, a.text, ans: yes ? 'yes' : 'no', note: 'hint'));
    lifeHint = false;
    _notify();
  }

  void useHalf() {
    if (!canAct || !lifeHalf) return;
    final wrong = possible.where((c) => c.id != myCard.id).toList()..shuffle(_rnd);
    for (final c in wrong.take(wrong.length ~/ 2)) {
      removed.add(c.id);
    }
    lifeHalf = false;
    flash = 'half_done';
    _notify();
  }

  void useSkip() {
    if (!canAct || !lifeSkip) return;
    lifeSkip = false;
    skipNext = true;
    flash = 'skip_armed';
    _notify();
  }

  void _afterMyTurn() {
    if (daily) {
      _notify();
      return;
    }
    if (skipNext) {
      skipNext = false;
      secsLeft = turnSecs;
      flash = 'extra_turn_msg';
      _notify();
      return;
    }
    _passToBot();
  }

  void _passToBot() {
    turn = Who.opp;
    _notify();
    Future.delayed(const Duration(milliseconds: 900), _botTurn);
  }

  // ---------- bot ----------
  List<CardItem> _botCandidates() {
    var best = 1 << 30;
    var out = <CardItem>[];
    for (final d in cat.cards) {
      if (botWrong.contains(d.id)) continue;
      var mis = 0;
      for (final e in botAnswers.entries) {
        if (d.flags.contains(e.key) != e.value) mis++;
      }
      if (mis < best) {
        best = mis;
        out = [d];
      } else if (mis == best) {
        out.add(d);
      }
    }
    return out;
  }

  void _botTurn() {
    if (_disposed || over != null || daily) return;
    final opp = oppCard!;
    final c = _botCandidates();
    String? key;
    final guessAt = diff == 'easy' ? 1 : 2;
    if (c.length > guessAt) {
      final opts = <MapEntry<String, double>>[];
      for (final a in cat.attrs) {
        if (botAnswers.containsKey(a.key)) continue;
        final yes = c.where((d) => d.flags.contains(a.key)).length;
        if (yes == 0 || yes == c.length) continue;
        opts.add(MapEntry(a.key, (yes - c.length / 2).abs() + _rnd.nextDouble() * 0.3));
      }
      opts.sort((a, b) => a.value.compareTo(b.value));
      if (opts.isNotEmpty) {
        if (diff == 'easy') {
          key = opts[_rnd.nextInt(opts.length)].key;
        } else if (diff == 'mid') {
          key = opts[_rnd.nextInt(min(3, opts.length))].key;
        } else {
          key = opts.first.key;
        }
      }
    }
    if (key != null) {
      final text = cat.attr(key)!.text;
      final entry = LogEntry(Who.opp, Kind.q, text);
      log.add(entry);
      pending = Pending(Kind.q, text, entry, key: key, suggestYes: opp.flags.contains(key));
    } else {
      final g = c[_rnd.nextInt(c.length)];
      final text = '${t('is_it_pre')}${g.name}${t('is_it_post')}';
      final entry = LogEntry(Who.opp, Kind.g, text);
      log.add(entry);
      pending = Pending(Kind.g, text, entry, guessId: g.id, suggestYes: g.id == opp.id);
    }
    _notify();
  }

  /// The player answers the bot's question / judges its guess.
  void answer(bool yes) {
    final p = pending;
    if (p == null || over != null) return;
    pending = null;
    if (p.kind == Kind.g) {
      p.entry.ok = yes;
      if (yes) {
        _end(false);
        return;
      }
      botWrong.add(p.guessId!);
    } else {
      p.entry.ans = yes ? 'yes' : 'no';
      botAnswers[p.key!] = yes;
    }
    turn = Who.me;
    secsLeft = turnSecs;
    _notify();
  }

  void _end(bool win) {
    final moves = win ? myMoves : log.where((e) => e.who == Who.opp).length;
    over = GameResult(win, moves);
    _timer?.cancel();
    onEnd?.call(over!);
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
