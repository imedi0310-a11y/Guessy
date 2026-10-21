import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'strings.dart';

/// Local storage. If the platform plugin fails, falls back to memory so the app still runs.
class Prefs {
  static SharedPreferences? _p;
  static final Map<String, Object> _mem = {};

  static Future<void> init() async {
    try {
      _p = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Prefs unavailable, using memory: $e');
      _p = null;
    }
    final saved = _getString('lang');
    if (saved != null && langs.contains(saved)) Lang.code = saved;
  }

  static String? _getString(String k) {
    try {
      if (_p != null) return _p!.getString(k);
    } catch (_) {}
    final v = _mem[k];
    return v is String ? v : null;
  }

  static int? _getInt(String k) {
    try {
      if (_p != null) return _p!.getInt(k);
    } catch (_) {}
    final v = _mem[k];
    return v is int ? v : null;
  }

  static void _setString(String k, String v) {
    _mem[k] = v;
    try {
      _p?.setString(k, v);
    } catch (_) {}
  }

  static void _setInt(String k, int v) {
    _mem[k] = v;
    try {
      _p?.setInt(k, v);
    } catch (_) {}
  }

  static Future<void> setLang(String code) async {
    Lang.code = code;
    _setString('lang', code);
  }

  static String get cat => _getString('cat') ?? 'animals';
  static set cat(String v) => _setString('cat', v);

  static String get name => _getString('name') ?? '';
  static set name(String v) => _setString('name', v);

  static String get myId => _getString('my_id') ?? '';
  static set myId(String v) => _setString('my_id', v);
  static String get friendsRaw => _getString('friends') ?? '';
  static set friendsRaw(String v) => _setString('friends', v);

  /// Speech recognition language/dialect (e.g. ar-DZ, ar-EG, fr-FR); empty = follow the app language.
  static String get voiceLang => _getString('voice_lang') ?? '';
  static set voiceLang(String v) => _setString('voice_lang', v);

  static bool get soundOn => (_getInt('sound') ?? 1) == 1;
  static set soundOn(bool v) => _setInt('sound', v ? 1 : 0);

  static String get diff => _getString('diff') ?? 'mid';
  static set diff(String v) => _setString('diff', v);

  static int get xp => _getInt('xp') ?? 0;
  static int get wins => _getInt('wins') ?? 0;
  static int get losses => _getInt('losses') ?? 0;
  static int get streak => _getInt('streak') ?? 0;
  static int get level => 1 + xp ~/ 200;
  static double get levelProgress => (xp % 200) / 200.0;

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String today() => _fmt(DateTime.now());

  static int? get dailyMovesToday => _getInt('daily_${today()}');

  static void _touchStreak() {
    final last = _getString('last_day');
    final todayStr = today();
    if (last == todayStr) return;
    final yStr = _fmt(DateTime.now().subtract(const Duration(days: 1)));
    _setInt('streak', last == yStr ? streak + 1 : 1);
    _setString('last_day', todayStr);
  }

  /// Records a finished round. Returns XP gained.
  static int recordRound({required bool win, required String diff}) {
    _touchStreak();
    final gain = win ? (diff == 'hard' ? 40 : diff == 'mid' ? 30 : 20) : 10;
    if (win) {
      _setInt('wins', wins + 1);
    } else {
      _setInt('losses', losses + 1);
    }
    _setInt('xp', xp + gain);
    return gain;
  }

  static int recordDaily(int moves) {
    _touchStreak();
    final gain = (40 - 2 * moves).clamp(5, 40);
    if (dailyMovesToday == null) {
      _setInt('daily_${today()}', moves);
      _setInt('xp', xp + gain);
      return gain;
    }
    return 0;
  }
}
