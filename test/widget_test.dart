import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guessy/main.dart';
import 'package:guessy/data.dart';
import 'package:guessy/game.dart';
import 'package:guessy/strings.dart';
import 'package:guessy/screens/game_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('home loads, all languages render, game screen plays', (tester) async {
    final loader = FontLoader('Tajawal');
    for (final w in ['Regular', 'Medium', 'Bold', 'ExtraBold', 'Black']) {
      final f = File('assets/fonts/Tajawal-$w.ttf');
      if (f.existsSync()) loader.addFont(Future.value(ByteData.view(f.readAsBytesSync().buffer)));
    }
    await loader.load();
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GuessyApp());
    for (var i = 0; i < 30 && find.text('Guessy').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('Guessy'), findsWidgets);
    expect(GameData.cats.length, greaterThanOrEqualTo(8));

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

    expect(find.byType(QuestionTile), findsWidgets);
    await tester.tap(find.byType(QuestionTile).first);
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
    // anime modes are checked for unique answers when built; play a couple of them here to keep CI fast
    for (final cat in GameData.cats.where((c) => c.group == null || const {'naruto', 'pokemon', 'players', 'ufc'}.contains(c.id))) {
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
