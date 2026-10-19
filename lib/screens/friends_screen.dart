import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../invite.dart';
import '../online.dart';
import '../prefs.dart';
import '../social.dart';
import '../strings.dart';
import '../theme.dart';
import '../ui.dart';
import 'online_screen.dart';

class FriendsScreen extends StatefulWidget {
  final String catId;
  const FriendsScreen({super.key, required this.catId});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _idCtrl = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Social.start().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _snack(String s) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s)));
  }

  Future<void> _add() async {
    final id = _idCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (id.length != 8 || _busy) {
      if (id.length != 8) _snack(t('id_8_digits'));
      return;
    }
    if (id == Social.myId.value) {
      _snack(t('cant_add_self'));
      return;
    }
    setState(() => _busy = true);
    try {
      final f = await Social.lookup(id).timeout(const Duration(seconds: 10));
      if (f == null) {
        _snack(t('id_not_found'));
      } else {
        Social.addFriend(f.id, f.name);
        _idCtrl.clear();
        _snack('${t('friend_added')} ${f.name}');
      }
    } catch (_) {
      _snack(t('online_off'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _challenge(String friendId) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final name = Prefs.name.trim().isEmpty ? t('you') : Prefs.name.trim();
      final code = await Online.createRoom(widget.catId, name).timeout(const Duration(seconds: 12));
      await Social.sendInvite(friendId, code);
      if (!mounted) return;
      _snack(t('invite_sent'));
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => OnlineGameScreen(code: code, seat: 'h')));
    } catch (_) {
      _snack(t('online_off'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final friends = Social.friends;
    return Scaffold(
      body: LuxBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            children: [
              Row(children: [
                GlassIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.maybePop(context)),
                const SizedBox(width: 12),
                Expanded(child: Text(t('friends'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
              ]),
              const SizedBox(height: 22),
              if (!Online.available)
                Glass(child: Text(t('online_off'), style: const TextStyle(color: C.pink, height: 1.5)))
              else ...[
                _myIdCard(),
                const SizedBox(height: 22),
                Text(t('add_friend'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _idCtrl,
                      maxLength: 8,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4),
                      decoration: InputDecoration(
                        hintText: t('enter_id'),
                        counterText: '',
                        hintStyle: const TextStyle(fontSize: 14, letterSpacing: 0, color: C.muted, fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: C.glass,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.glassBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.gold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(width: 110, child: LuxButton(label: t('add'), height: 56, onPressed: _busy ? null : _add)),
                ]),
                const SizedBox(height: 24),
                Text('${t('friends')} (${friends.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                if (friends.isEmpty)
                  Glass(child: Text(t('no_friends'), textAlign: TextAlign.center, style: const TextStyle(color: C.muted, height: 1.5)))
                else
                  for (final f in friends) _friendTile(f.$1, f.$2),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _myIdCard() {
    return ValueListenableBuilder<String?>(
      valueListenable: Social.myId,
      builder: (_, id, __) => GradientFrame(
        gradient: C.goldGrad,
        glow: C.gold,
        fill: const Color(0xFF1A1538),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(t('my_id'), style: const TextStyle(color: C.muted)),
          const SizedBox(height: 6),
          id == null
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: C.gold))
              : GradientText(id, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 4)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: GlassButton(
                label: t('copy'),
                icon: '📋',
                height: 44,
                onPressed: id == null
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: id));
                        _snack(t('copied'));
                      },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassButton(
                label: t('share'),
                icon: '📤',
                height: 44,
                onPressed: id == null
                    ? null
                    : () => SharePlus.instance.share(ShareParams(text: '${t('share_id_msg')} $id\n${t('invite_dl')}\n$downloadUrl')),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _friendTile(String id, String savedName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: StreamBuilder<FriendInfo>(
        stream: Social.watch(id),
        builder: (_, snap) {
          final f = snap.data;
          final online = f?.online ?? false;
          final name = f?.name ?? savedName;
          return Glass(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(children: [
              Stack(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: C.surface2,
                  child: Text(name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, color: C.goldLight)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: online ? C.green : C.muted,
                      shape: BoxShape.circle,
                      border: Border.all(color: C.bg, width: 2),
                    ),
                  ),
                ),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text('ID: $id · ${online ? t('online_now') : t('offline')}',
                      style: TextStyle(fontSize: 12, color: online ? C.green : C.muted)),
                ]),
              ),
              SizedBox(
                width: 96,
                child: LuxButton(label: t('challenge'), height: 42, gradient: C.roseGrad, textColor: Colors.white, onPressed: _busy ? null : () => _challenge(id)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: C.muted, size: 20),
                onPressed: () => setState(() => Social.removeFriend(id)),
              ),
            ]),
          );
        },
      ),
    );
  }
}
