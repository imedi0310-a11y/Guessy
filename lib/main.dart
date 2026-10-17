import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data.dart';
import 'prefs.dart';
import 'strings.dart';
import 'theme.dart';
import 'screens/home.dart';

final langNotifier = ValueNotifier<String>('ar');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  await GameData.load();
  langNotifier.value = Lang.code;
  runApp(const GuessyApp());
}

class GuessyApp extends StatelessWidget {
  const GuessyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: langNotifier,
      builder: (context, code, _) => MaterialApp(
        key: ValueKey(code),
        title: 'Guessy',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        locale: Locale(code),
        supportedLocales: [for (final l in langs) Locale(l)],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const HomeScreen(),
      ),
    );
  }
}
