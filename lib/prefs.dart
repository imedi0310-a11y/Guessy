import 'package:shared_preferences/shared_preferences.dart';
import 'strings.dart';

class Prefs {
  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    final saved = _p.getString('lang');
    if (saved != null && langs.contains(saved)) Lang.code = saved;
  }

  static Future<void> setLang(String code) async {
    Lang.code = code;
    await _p.setString('lang', code);
  }

  static String get cat => _p.getString('cat') ?? 'animals';
  static set cat(String v) => _p.setString('cat', v);

  static String get diff => _p.getString('diff') ?? 'mid';
  static set diff(String v) => _p.setString('diff', v);

  static int get xp => _p.getInt('xp') ?? 0;
  static int get wins => _p.getInt('wins') ?? 0;
  static int get losses => _p.getInt('losses') ?? 0;
  static int get streak => _p.getInt('streak') ?? 0;
  static int get level => 1 + xp ~/ 200;
  static double get levelProgress => (xp % 200) / 200.0;

  static String today() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static int? get dailyMovesToday => _p.getInt('daily_${today()}');

  static void _touchStreak() {
    final last = _p.getString('last_day');
    final now = DateTime.now();
    final todayStr = today();
    if (last == todayStr) return;
    final y = now.subtract(const Duration(days: 1));
    final yStr = '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
    _p.setInt('streak', last == yStr ? streak + 1 : 1);
    _p.setString('last_day', todayStr);
  }

  /// Records a finished round. Returns XP gained.
  static int recordRound({required bool win, required String diff}) {
    _touchStreak();
    int gain = win ? (diff == 'hard' ? 40 : diff == 'mid' ? 30 : 20) : 10;
    if (win) {
      _p.setInt('wins', wins + 1);
    } else {
      _p.setInt('losses', losses + 1);
    }
    _p.setInt('xp', xp + gain);
    return gain;
  }

  static int recordDaily(int moves) {
    _touchStreak();
    final gain = (40 - 2 * moves).clamp(5, 40);
    if (dailyMovesToday == null) {
      _p.setInt('daily_${today()}', moves);
      _p.setInt('xp', xp + gain);
      return gain;
    }
    return 0;
  }
}
