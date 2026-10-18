import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data.dart';
import 'prefs.dart';
import 'sfx.dart';
import 'online.dart';
import 'strings.dart';
import 'theme.dart';
import 'screens/home.dart';

final langNotifier = ValueNotifier<String>('ar');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GuessyApp());
}

/// Loads prefs + card data, showing a splash (or the error) instead of a blank screen.
Future<void> bootstrap() async {
  await Prefs.init();
  await GameData.load();
  Sfx.init();
  await Online.init();
  langNotifier.value = Lang.code;
}

class GuessyApp extends StatefulWidget {
  const GuessyApp({super.key});

  @override
  State<GuessyApp> createState() => _GuessyAppState();
}

class _GuessyAppState extends State<GuessyApp> {
  late final Future<void> _boot = bootstrap();

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
        home: FutureBuilder<void>(
          future: _boot,
          builder: (context, snap) {
            if (snap.hasError) {
              return Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: SelectableText('Guessy error:\n${snap.error}\n\n${snap.stackTrace}',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              );
            }
            if (snap.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(
                  child: Text('Guessy 🤔',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: C.yellow)),
                ),
              );
            }
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}
