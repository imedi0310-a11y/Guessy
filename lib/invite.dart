import 'package:share_plus/share_plus.dart';
import 'strings.dart';

const downloadUrl = 'https://github.com/imedi0310-a11y/Guessy/releases/latest/download/Guessy.apk';

/// Opens the system share sheet (WhatsApp, Messenger, Telegram, SMS, Instagram...).
Future<void> shareInvite({String? code}) async {
  final msg = code == null
      ? '${t('invite_app_msg')}\n$downloadUrl'
      : '${t('invite_room_msg')} $code\n${t('invite_dl')}\n$downloadUrl';
  try {
    await SharePlus.instance.share(ShareParams(text: msg, subject: 'Guessy'));
  } catch (_) {}
}
