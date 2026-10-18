import 'dart:async';
import 'dart:io' show Platform;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'prefs.dart';

/// Game sound effects. Never throws: a sound failing must not break the game.
class Sfx {
  static final ValueNotifier<bool> on = ValueNotifier<bool>(true);
  static final Map<String, AudioPlayer> _players = {};
  static bool get _disabled {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return true;
    }
  }

  static void init() {
    on.value = Prefs.soundOn;
  }

  static void toggle() {
    on.value = !on.value;
    Prefs.soundOn = on.value;
    if (on.value) play('tap');
  }

  static void play(String name, {bool haptic = false}) {
    if (haptic) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
    if (!on.value || _disabled) return;
    unawaited(_play(name));
  }

  static Future<void> _play(String name) async {
    try {
      final p = _players.putIfAbsent(name, () => AudioPlayer()..setPlayerMode(PlayerMode.lowLatency));
      await p.stop();
      await p.play(AssetSource('sfx/$name.wav'), volume: 0.9);
    } catch (e) {
      debugPrint('sfx $name failed: $e');
    }
  }
}
