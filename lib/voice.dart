import 'package:flutter/services.dart';
import 'strings.dart';

/// Speech-to-text through Android's built-in Google voice input dialog.
class Voice {
  static const _ch = MethodChannel('guessy/speech');
  static String get _lang => const {'ar': 'ar-DZ', 'en': 'en-US', 'fr': 'fr-FR', 'es': 'es-ES', 'pt': 'pt-BR'}[Lang.code] ?? 'en-US';

  /// Returns the recognized text, null if cancelled. Throws a short error code string on failure.
  static Future<String?> listen() async {
    try {
      return await _ch.invokeMethod<String>('listen', {'lang': _lang, 'prompt': t('listening')});
    } on PlatformException catch (e) {
      throw e.code;
    } on MissingPluginException {
      throw 'no_recognizer';
    }
  }
}
