import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'strings.dart';

/// Speech-to-text: Android's recognizer inside the app (live text), or the system voice dialog.
class Voice {
  static const _ch = MethodChannel('guessy/speech');
  static String get _lang => const {'ar': 'ar-DZ', 'en': 'en-US', 'fr': 'fr-FR', 'es': 'es-ES', 'pt': 'pt-BR'}[Lang.code] ?? 'en-US';

  /// Live text heard so far (updates while the user talks).
  static final partial = ValueNotifier<String>('');

  /// 'ready' | 'speaking' | 'thinking' | ''
  static final state = ValueNotifier<String>('');

  static bool _wired = false;
  static void _wire() {
    if (_wired) return;
    _wired = true;
    _ch.setMethodCallHandler((call) async {
      if (call.method == 'partial') partial.value = '${call.arguments}';
      if (call.method == 'state') state.value = '${call.arguments}';
      return null;
    });
  }

  /// Returns the recognized text, null if cancelled. Throws an error code string on failure:
  /// mic_denied | no_speech | network | no_recognizer | speech_error
  static Future<String?> listen() async {
    _wire();
    partial.value = '';
    state.value = '';
    try {
      return await _ch.invokeMethod<String>('listen', {'lang': _lang, 'prompt': t('listening')});
    } on PlatformException catch (e) {
      throw e.code;
    } on MissingPluginException {
      throw 'no_recognizer';
    } finally {
      state.value = '';
    }
  }

  /// Stop listening now and use what was heard.
  static Future<void> stop() async {
    try {
      await _ch.invokeMethod('stop');
    } catch (_) {}
  }

  /// Message to show for an error code from [listen].
  static String errorText(Object code) => switch ('$code') {
        'mic_denied' => t('mic_denied'),
        'no_speech' => t('voice_no_speech'),
        'network' => t('voice_network'),
        _ => t('voice_unavailable'),
      };
}
