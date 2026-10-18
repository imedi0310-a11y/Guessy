import 'package:flutter/material.dart';
import '../data.dart';
import '../game.dart';
import '../main.dart';
import '../prefs.dart';
import '../strings.dart';
import '../theme.dart';
import '../ui.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String catId = Prefs.cat;
  late String diff = Prefs.diff;

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: Tween(begin: 0.97, end: 1.0).animate(a), child: child),
      ),
    ));
    if (mounted) setState(() {});
  }

  void _playAI() => _open(GameScreen(cat: GameData.cat(catId), diff: diff));

  void _playDaily() {
    final card = dailyCard(GameData.cats, DateTime.now());
    final cat = GameData.cat(card.id.split('.').first);
    _open(GameScreen(cat: cat, diff: diff, daily: true, fixedCard: card));
  }

  void _pickLanguage() {
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final l in langs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassButton(
                    label: langNames[l]!,
                    color: l == Lang.code ? C.gold : Colors.white,
                    onPressed: () async {
                      Navigator.pop(c);
                      await Prefs.setLang(l);
                      langNotifier.value = l;
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyDone = Prefs.dailyMovesToday;
    return Scaffold(
      body: LuxBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              _header(),
              const SizedBox(height: 18),
              _profileCard(),
              const SizedBox(height: 26),
              _sectionTitle(t('choose_cat')),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
                children: [for (final c in GameData.cats) _catTile(c)],
              ),
              const SizedBox(height: 24),
              _sectionTitle(t('difficulty')),
              const SizedBox(height: 12),
              _diffPicker(),
              const SizedBox(height: 28),
              LuxButton(label: t('play_ai'), icon: '🤖', onPressed: _playAI),
              const SizedBox(height: 12),
              GlassButton(
                icon: '⭐',
                label: dailyDone == null ? t('daily') : '${t('daily')} · ${t('daily_done_today')}',
                onPressed: dailyDone == null ? _playDaily : null,
              ),
              const SizedBox(height: 26),
              Text(t('coming'), textAlign: TextAlign.center, style: const TextStyle(color: C.muted, fontSize: 13, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset('assets/icon/icon.png', width: 48, height: 48),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GradientText('Guessy', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
              Text(t('tagline'), style: const TextStyle(fontSize: 14, color: C.muted)),
            ],
          ),
        ),
        const SoundButton(),
        const SizedBox(width: 8),
        GlassIconButton(icon: Icons.translate_rounded, onPressed: _pickLanguage),
      ],
    );
  }

  Widget _sectionTitle(String s) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(gradient: C.goldGrad, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        Expanded(child: Text(s, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
      ],
    );
  }

  Widget _profileCard() {
    return GradientFrame(
      gradient: LinearGradient(colors: [C.gold.withValues(alpha: 0.7), C.violet.withValues(alpha: 0.4), C.glassBorder]),
      fill: const Color(0xFF1A1538),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: Prefs.levelProgress,
                    strokeWidth: 5,
                    backgroundColor: C.glassBorder,
                    color: C.gold,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                GradientText('${Prefs.level}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t('lvl')} ${Prefs.level}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('${Prefs.xp} XP', style: const TextStyle(color: C.gold, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _stat('🏆', '${Prefs.wins}', t('wins')),
                    const SizedBox(width: 8),
                    _stat('🔥', '${Prefs.streak}', t('streak')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String icon, String value, String label) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: C.glass, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.glassBorder)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 4),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.muted, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _catTile(Cat c) {
    final sel = c.id == catId;
    final tile = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(c.icon, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 6),
        Text(c.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, fontWeight: sel ? FontWeight.w800 : FontWeight.w500, color: sel ? C.goldLight : Colors.white)),
      ],
    );
    return GestureDetector(
      onTap: () => setState(() {
        catId = c.id;
        Prefs.cat = c.id;
      }),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: sel ? 1.0 : 0.96,
        child: sel
            ? GradientFrame(
                gradient: C.goldGrad,
                glow: C.gold,
                radius: 18,
                fill: const Color(0xFF2A2140),
                padding: const EdgeInsets.all(4),
                child: tile,
              )
            : Glass(radius: 18, padding: const EdgeInsets.all(4), child: tile),
      ),
    );
  }

  Widget _diffPicker() {
    const ds = ['easy', 'mid', 'hard'];
    return Glass(
      radius: 18,
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          for (final d in ds)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  diff = d;
                  Prefs.diff = d;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: diff == d ? C.goldGrad : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(t(d),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: diff == d ? C.ink : C.muted,
                      )),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
