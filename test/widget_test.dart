import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guessy/main.dart';
import 'package:guessy/data.dart';
import 'package:guessy/game.dart';
import 'package:guessy/strings.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('home loads, all languages render, game screen plays', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GuessyApp());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
    await tester.pumpAndSettle();
    expect(find.text('Guessy'), findsWidgets);
    expect(GameData.cats.length, 8);

    for (final l in langs) {
      langNotifier.value = l;
      Lang.code = l;
      await tester.pumpAndSettle();
      expect(find.text(t('play_ai')), findsOneWidget);
    }
    langNotifier.value = 'ar';
    Lang.code = 'ar';
    await tester.pumpAndSettle();

    await tester.tap(find.text(t('play_ai')));
    await tester.pumpAndSettle();
    expect(find.text(t('your_turn')), findsOneWidget);

    await tester.tap(find.text('❓ ${t('ask')}'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile).first);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text(t('answer_opp')), findsWidgets);

    await tester.tap(find.text('✓ ${t('yes')}'));
    await tester.pumpAndSettle();
    expect(find.text(t('your_turn')), findsOneWidget);

    await tester.tap(find.text('🎯 ${t('guess')}'));
    await tester.pumpAndSettle();
    expect(find.text(t('tap_to_guess')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  test('bot always finds its card when answered honestly', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await GameData.load();
    for (final cat in GameData.cats) {
      final g = GameController(cat: cat, diff: 'hard');
      // Simulate honest answers without timers.
      for (var i = 0; i < 60 && g.over == null; i++) {
        if (g.pending != null) {
          g.answer(g.pending!.suggestYes);
        } else if (g.turn == Who.me) {
          g.guess(g.cat.cards.firstWhere((c) => c.id != g.myCard.id && !g.myWrong.contains(c.id),
              orElse: () => g.myCard));
          await Future<void>.delayed(const Duration(milliseconds: 950));
        } else {
          await Future<void>.delayed(const Duration(milliseconds: 950));
        }
      }
      expect(g.over, isNotNull, reason: cat.id);
      g.dispose();
    }
  }, timeout: const Timeout(Duration(minutes: 10)));
}
