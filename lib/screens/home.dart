import 'package:flutter/material.dart';
import '../data.dart';
import '../game.dart';
import '../main.dart';
import '../prefs.dart';
import '../strings.dart';
import '../theme.dart';
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
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  void _playAI() {
    _open(GameScreen(cat: GameData.cat(catId), diff: diff));
  }

  void _playDaily() {
    final card = dailyCard(GameData.cats, DateTime.now());
    final cat = GameData.cat(card.id.split('.').first);
    _open(GameScreen(cat: cat, diff: diff, daily: true, fixedCard: card));
  }

  @override
  Widget build(BuildContext context) {
    final dailyDone = Prefs.dailyMovesToday;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                const Text('Guessy', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: C.yellow)),
                const SizedBox(width: 8),
                const Text('🤔', style: TextStyle(fontSize: 28)),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.translate),
                  tooltip: 'Language',
                  initialValue: Lang.code,
                  onSelected: (code) async {
                    await Prefs.setLang(code);
                    langNotifier.value = code;
                  },
                  itemBuilder: (_) => [
                    for (final l in langs) PopupMenuItem(value: l, child: Text(langNames[l]!)),
                  ],
                ),
              ],
            ),
            Text(t('tagline'), style: const TextStyle(fontSize: 16, color: C.muted)),
            const SizedBox(height: 16),
            _statsCard(),
            const SizedBox(height: 20),
            Text(t('choose_cat'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [for (final c in GameData.cats) _catTile(c)],
            ),
            const SizedBox(height: 18),
            Text(t('difficulty'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                for (final d in ['easy', 'mid', 'hard']) ButtonSegment(value: d, label: Text(t(d))),
              ],
              selected: {diff},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() {
                diff = s.first;
                Prefs.diff = diff;
              }),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _playAI,
              icon: const Text('🤖', style: TextStyle(fontSize: 20)),
              label: Text(t('play_ai')),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: dailyDone == null ? _playDaily : null,
              icon: const Text('📅', style: TextStyle(fontSize: 18)),
              label: Text(dailyDone == null ? t('daily') : '${t('daily')} · ${t('daily_done_today')}'),
            ),
            const SizedBox(height: 22),
            Text(t('coming'), textAlign: TextAlign.center, style: const TextStyle(color: C.muted, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _statsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: C.yellow,
            child: Text('${Prefs.level}',
                style: const TextStyle(color: C.bg, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t('lvl')} ${Prefs.level} · ${Prefs.xp} XP',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: Prefs.levelProgress,
                    minHeight: 8,
                    backgroundColor: C.surface2,
                    color: C.yellow,
                  ),
                ),
                const SizedBox(height: 6),
                Text('🏆 ${Prefs.wins} ${t('wins')}   🔥 ${Prefs.streak} ${t('streak')}',
                    style: const TextStyle(color: C.muted, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _catTile(Cat c) {
    final sel = c.id == catId;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => setState(() {
        catId = c.id;
        Prefs.cat = c.id;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: sel ? C.yellow.withValues(alpha: 0.16) : C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? C.yellow : Colors.transparent, width: 2),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(c.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(c.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
