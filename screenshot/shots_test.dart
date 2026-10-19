// Renders key screens to PNG (run with --update-goldens) so the design can be reviewed.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guessy/main.dart';
import 'package:guessy/strings.dart';
import 'package:guessy/screens/game_screen.dart';

Future<void> loadFonts() async {
  final loader = FontLoader('Tajawal');
  for (final w in ['Regular', 'Medium', 'Bold', 'ExtraBold', 'Black']) {
    loader.addFont(Future.value(ByteData.view(File('assets/fonts/Tajawal-$w.ttf').readAsBytesSync().buffer)));
  }
  await loader.load();
}

Future<void> shoot(WidgetTester tester, String name) async {
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'xp': 260, 'wins': 7, 'streak': 3}));

  for (final lang in ['ar', 'en']) {
    testWidgets('screens $lang', (tester) async {
      await loadFonts();
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const GuessyApp());
      for (var i = 0; i < 30 && find.text('Guessy').evaluate().isEmpty; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      langNotifier.value = lang;
      Lang.code = lang;
      await tester.pumpAndSettle();
      await shoot(tester, 'home_$lang');

      await tester.tap(find.text(t('play_ai')));
      await tester.pumpAndSettle();
      await shoot(tester, 'game_start_$lang');

      await tester.tap(find.byType(QuestionTile).first);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      await shoot(tester, 'game_pending_$lang');

      await tester.tap(find.text('✓ ${t('yes')}'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(QuestionTile).first);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('✗ ${t('no')}'));
      await tester.pumpAndSettle();
      await shoot(tester, 'game_mid_$lang');

      await tester.tap(find.text('🎯 ${t('guess')}'));
      await tester.pumpAndSettle();
      await shoot(tester, 'deck_$lang');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  }
}
