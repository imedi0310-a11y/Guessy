import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../online.dart';
import '../social.dart';
import '../invite.dart';
import '../prefs.dart';
import '../sfx.dart';
import '../strings.dart';
import '../theme.dart';
import '../ui.dart';
import 'game_screen.dart' show QuestionTile;

/// Create or join a room.
class OnlineLobby extends StatefulWidget {
  final String catId;
  const OnlineLobby({super.key, required this.catId});

  @override
  State<OnlineLobby> createState() => _OnlineLobbyState();
}

class _OnlineLobbyState extends State<OnlineLobby> {
  final _name = TextEditingController(text: Prefs.name);
  final _code = TextEditingController();
  bool _busy = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    Online.ready?.then((_) {
      if (mounted) setState(() {});
    });
  }

  String get _myName => _name.text.trim().isEmpty ? t('you') : _name.text.trim();

  Future<void> _go(Future<(String, String)> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _err = null;
    });
    Prefs.name = _name.text.trim();
    Social.updateName();
    try {
      final (code, seat) = await action().timeout(const Duration(seconds: 15));
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OnlineGameScreen(code: code, seat: seat)),
      );
    } catch (e) {
      final s = '$e';
      setState(() => _err = s.contains('not_found')
          ? t('room_not_found')
          : s.contains('full')
              ? t('room_full')
              : t('online_off'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LuxBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
            children: [
              Row(
                children: [
                  GlassIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.maybePop(context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(t('play_friend'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              if (!Online.available)
                Glass(child: Text(t('online_off'), style: const TextStyle(color: C.pink, height: 1.5)))
              else ...[
                _label(t('your_name')),
                _field(_name, maxLen: 16),
                const SizedBox(height: 22),
                LuxButton(
                  label: t('create_room'),
                  icon: '✨',
                  onPressed: _busy
                      ? null
                      : () => _go(() async {
                            final code = await Online.createRoom(widget.catId, _myName);
                            return (code, 'h');
                          }),
                ),
                const SizedBox(height: 28),
                Row(children: [
                  const Expanded(child: Divider(color: C.glassBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(t('join_room'), style: const TextStyle(color: C.muted)),
                  ),
                  const Expanded(child: Divider(color: C.glassBorder)),
                ]),
                const SizedBox(height: 16),
                _field(_code, hint: t('enter_code'), maxLen: 4, code: true),
                const SizedBox(height: 12),
                GlassButton(
                  label: t('join'),
                  icon: '🚪',
                  onPressed: _busy
                      ? null
                      : () => _go(() async {
                            final code = _code.text.trim().toUpperCase();
                            final seat = await Online.joinRoom(code, _myName);
                            return (code, seat);
                          }),
                ),
              ],
              if (_busy) ...[
                const SizedBox(height: 20),
                Center(child: Text(t('connecting'), style: const TextStyle(color: C.muted))),
              ],
              if (_err != null) ...[
                const SizedBox(height: 16),
                Center(child: Text(_err!, textAlign: TextAlign.center, style: const TextStyle(color: C.pink))),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s, style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600)),
      );

  Widget _field(TextEditingController c, {String? hint, int maxLen = 20, bool code = false}) {
    return TextField(
      controller: c,
      maxLength: maxLen,
      textAlign: code ? TextAlign.center : TextAlign.start,
      textCapitalization: code ? TextCapitalization.characters : TextCapitalization.words,
      style: TextStyle(fontSize: code ? 28 : 17, fontWeight: FontWeight.w800, letterSpacing: code ? 8 : 0),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: C.glass,
        hintStyle: const TextStyle(color: C.muted, fontSize: 15, letterSpacing: 0, fontWeight: FontWeight.w500),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.gold)),
      ),
    );
  }
}

/// The online match screen.
class OnlineGameScreen extends StatefulWidget {
  final String code;
  final String seat;
  const OnlineGameScreen({super.key, required this.code, required this.seat});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  late final OnlineGame g = OnlineGame(widget.code, widget.seat);
  final _scroll = ScrollController();
  int _logLen = 0;
  int _round = -1;
  String? _bubble;
  Timer? _bubbleT;
  int _prevSecs = 99;
  bool _endSound = false;
  int _answeredF = 0;
  String? _rrBy;
  final _voicePlayer = AudioPlayer();
  final _freeCtrl = TextEditingController();
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _listening = false;
  final _rec = AudioRecorder();
  bool _recording = false;
  Timer? _recT;

  @override
  void initState() {
    super.initState();
    g.addListener(_onChange);
    g.start();
  }

  void _onChange() {
    if (!mounted) return;
    final log = g.log;
    if (g.round != _round) {
      _round = g.round;
      _logLen = log.length;
      _endSound = false;
    }
    if (log.length < _logLen) _logLen = log.length;
    if (g.rerollBy != _rrBy) {
      final first = _rrBy == null;
      _rrBy = g.rerollBy;
      if (!first && _rrBy!.isNotEmpty) {
        Sfx.play('magic', haptic: true);
        if (!_rrBy!.startsWith(g.me)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(t('friend_changed'))));
        }
      }
    }
    if (log.length > _logLen) {
      final e = log.last;
      if (e.kind == 'f') {
        if (e.who != g.me) Sfx.play('pop', haptic: true);
      } else if (e.kind == 'q') {
        Sfx.play(e.yes == true ? 'yes' : 'no');
      } else if (e.yes != true) {
        Sfx.play('wrong');
      }
      _logLen = log.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    }
    final answered = log.where((e) => e.kind == 'f' && e.raw != null).toList();
    if (answered.length > _answeredF) {
      final a = answered.last;
      if (a.who == g.me) Sfx.play(a.raw == 1 ? 'yes' : a.raw == 0 ? 'no' : 'magic');
    }
    if (answered.length < _answeredF) _answeredF = answered.length;
    _answeredF = answered.length;
    final voice = g.lastVoice;
    if (voice != null) {
      g.lastVoice = null;
      _voicePlayer.play(BytesSource(voice)).catchError((_) {});
      _bubble = '🎙️ ${t('voice_msg')}';
      _bubbleT?.cancel();
      _bubbleT = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _bubble = null);
      });
    }
    if (g.over != null && !_endSound) {
      _endSound = true;
      Sfx.play(g.over == g.me ? 'win' : 'lose', haptic: true);
      if (g.over == g.me) Prefs.recordRound(win: true, diff: 'mid');
    }
    final msg = g.lastIncoming;
    if (msg != null) {
      g.lastIncoming = null;
      Sfx.play('pop', haptic: true);
      _bubble = msg.text;
      _bubbleT?.cancel();
      _bubbleT = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _bubble = null);
      });
    }
    if (g.myTurn && g.ready && g.secsLeft <= 10 && g.secsLeft > 0 && g.secsLeft != _prevSecs) Sfx.play('tick');
    _prevSecs = g.secsLeft;
    setState(() {});
  }

  @override
  void dispose() {
    g.removeListener(_onChange);
    _voicePlayer.dispose();
    _freeCtrl.dispose();
    _recT?.cancel();
    _rec.dispose();
    g.leave();
    g.dispose();
    _scroll.dispose();
    _bubbleT?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LuxBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _header(),
              if (!g.ready) Expanded(child: _waiting()) else ...[
                _cards(),
                _status(),
                Expanded(child: _logView()),
                _bottom(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.maybePop(context)),
          Expanded(
            child: Column(
              children: [
                Text('${g.cat.icon} ${g.cat.label}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text('${t('room_code')}: ${widget.code}  ·  ${g.score(g.me)} - ${g.score(g.opp)}',
                    style: const TextStyle(fontSize: 12, color: C.muted)),
              ],
            ),
          ),
          const SoundButton(),
          const SizedBox(width: 8),
          _pttButton(),
          const SizedBox(width: 8),
          GlassIconButton(icon: Icons.chat_bubble_rounded, onPressed: _openChat),
        ],
      ),
    );
  }

  Widget _waiting() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(t('share_code'), style: const TextStyle(color: C.muted, fontSize: 15)),
            const SizedBox(height: 14),
            GradientFrame(
              gradient: C.goldGrad,
              glow: C.gold,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
              child: GradientText(widget.code, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: 10)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              child: GlassButton(
                label: t('copy'),
                icon: '📋',
                height: 46,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.code));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('copied'))));
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 260,
              child: LuxButton(label: t('invite_friend'), icon: '📤', height: 50, onPressed: () => shareInvite(code: widget.code)),
            ),
            const SizedBox(height: 30),
            const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5, color: C.gold)),
            const SizedBox(height: 12),
            Text(g.hasPlayer(g.opp) ? t('connecting') : t('waiting_friend'), style: const TextStyle(color: C.muted)),
          ],
        ),
      ),
    );
  }

  Widget _cards() {
    final opp = g.oppCard!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: _card(C.goldGrad, C.gold, t('you'),
                const GradientText('?', style: TextStyle(fontSize: 46, fontWeight: FontWeight.w900, height: 1.05)), null, t('on_head'), C.goldLight),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _card(C.roseGrad, C.pink, g.nameOf(g.opp).isEmpty ? t('friend') : g.nameOf(g.opp),
                    CardPic(opp, size: 62), opp.name, t('you_see'), const Color(0xFFFF9DBE)),
                if (!g.isOnline(g.opp))
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(22)),
                      alignment: Alignment.center,
                      child: Text(t('opp_left'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                if (_bubble != null)
                  Positioned(
                    top: -6,
                    left: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
                      ),
                      child: Text(_bubble!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: C.ink, fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Gradient grad, Color glow, String title, Widget center, String? name, String sub, Color nameColor) {
    return SizedBox(
      height: 150,
      child: GradientFrame(
        gradient: grad,
        glow: glow,
        fill: const Color(0xFF191433),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: C.muted, fontWeight: FontWeight.w600)),
            center,
            if (name != null)
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: nameColor)),
            Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: C.muted)),
          ],
        ),
      ),
    );
  }

  Widget _status() {
    final over = g.over;
    final String s;
    final Color dot;
    if (over != null) {
      s = over == g.me ? t('you_won_online') : t('opp_won_online');
      dot = over == g.me ? C.green : C.pink;
    } else if (g.myTurn) {
      s = t('your_turn');
      dot = C.gold;
    } else {
      s = t('opp_turn');
      dot = C.violet;
    }
    final low = g.secsLeft <= 10 && over == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: C.glass, borderRadius: BorderRadius.circular(30), border: Border.all(color: dot.withValues(alpha: 0.45))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle, boxShadow: [BoxShadow(color: dot, blurRadius: 8)])),
                  const SizedBox(width: 8),
                  Flexible(child: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
                ]),
              ),
            ),
          ),
          if (over == null) ...[
            RerollChip(left: OnlineGame.maxRerolls - g.rerolls, onTap: g.reroll),
            const SizedBox(width: 8),
            Text('⏱ ${g.secsLeft}', style: TextStyle(fontWeight: FontWeight.w900, color: low ? C.pink : C.gold)),
          ],
        ],
      ),
    );
  }

  Widget _logView() {
    final log = g.log;
    if (log.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(t('start_hint'), textAlign: TextAlign.center, style: const TextStyle(color: C.muted, height: 1.6)),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      itemCount: log.length,
      itemBuilder: (_, i) {
        final e = log[i];
        final mine = e.who == g.me;
        final ok = e.yes == true;
        final badge = e.kind == 'f'
            ? (e.raw == null ? '⏳' : e.raw == 1 ? t('yes') : e.raw == 0 ? t('no') : t('sometimes'))
            : e.kind == 'q'
                ? (ok ? t('yes') : t('no'))
                : (ok ? '✓' : '✗');
        return Align(
          alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
            decoration: BoxDecoration(
              color: mine ? C.glass : C.pink.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: mine ? C.gold.withValues(alpha: 0.28) : C.pink.withValues(alpha: 0.35)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(mine ? '🙋' : '🧑', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Flexible(child: Text(g.entryText(e), style: const TextStyle(fontSize: 14.5, height: 1.35))),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(gradient: ok ? C.greenGrad : C.roseGrad, borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: const TextStyle(color: C.ink, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _bottom() {
    Widget child;
    if (g.over != null) {
      child = Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: _reveal(t('your_card_was'), g.myCard!, C.goldGrad)),
          const SizedBox(width: 12),
          Expanded(child: _reveal(t('their_card_was'), g.oppCard!, C.roseGrad)),
        ]),
        const SizedBox(height: 14),
        LuxButton(label: t('new_round'), icon: '🔄', onPressed: () => g.newRound()),
      ]);
    } else if (g.pendingFree != null) {
      final p = g.pendingFree!;
      if (p.who != g.me) {
        child = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(t('friend_asks'), style: const TextStyle(color: C.muted, fontSize: 13)),
          const SizedBox(height: 8),
          Text(p.text ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, height: 1.3)),
          const SizedBox(height: 6),
          Text('${t('about_card')} ${g.oppCard?.emoji ?? ''} ${g.oppCard?.name ?? ''}',
              textAlign: TextAlign.center, style: const TextStyle(color: C.goldLight, fontSize: 13)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: LuxButton(label: t('yes'), gradient: C.greenGrad, textColor: C.ink, height: 50, onPressed: () => g.answerFree(1))),
            const SizedBox(width: 8),
            Expanded(child: LuxButton(label: t('sometimes'), gradient: C.goldGrad, textColor: C.ink, height: 50, onPressed: () => g.answerFree(2))),
            const SizedBox(width: 8),
            Expanded(child: LuxButton(label: t('no'), gradient: C.roseGrad, textColor: Colors.white, height: 50, onPressed: () => g.answerFree(0))),
          ]),
        ]);
      } else {
        child = Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('⏳ ${t('waiting_answer')}', style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _quickChat(),
          ]),
        );
      }
    } else if (!g.myTurn) {
      child = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(t('opp_turn'), style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _quickChat(),
        ]),
      );
    } else {
      final qs = g.unasked;
      child = Column(mainAxisSize: MainAxisSize.min, children: [
        _freeRow(),
        const SizedBox(height: 12),
        Row(children: [
          Container(width: 3, height: 16, decoration: BoxDecoration(gradient: C.goldGrad, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Text(qs.isEmpty ? t('no_q_left') : t('pick_q'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        if (qs.isNotEmpty)
          SizedBox(
            height: 122,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 8, mainAxisExtent: 168),
              itemCount: qs.length,
              itemBuilder: (_, i) => QuestionTile(
                  text: qs[i].text,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    g.ask(qs[i]);
                  }),
            ),
          ),
        const SizedBox(height: 12),
        LuxButton(label: '🎯 ${t('guess')}', gradient: C.roseGrad, textColor: Colors.white, height: 50, onPressed: _openDeck),
      ]);
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1C1640), Color(0xFF120F26)]),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: C.gold.withValues(alpha: 0.30))),
      ),
      child: child,
    );
  }

  String get _sttLocale => const {'ar': 'ar_SA', 'en': 'en_US', 'fr': 'fr_FR', 'es': 'es_ES', 'pt': 'pt_BR'}[Lang.code] ?? 'en_US';

  void _snack(String s) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s), duration: const Duration(seconds: 2)));
  }

  Future<void> _toggleListen() async {
    if (_listening) {
      await _stt.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    try {
      final ok = await _stt.initialize(
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
        onStatus: (st) {
          if ((st == 'done' || st == 'notListening') && mounted) setState(() => _listening = false);
        },
      );
      if (!ok) {
        _snack(t('mic_denied'));
        return;
      }
      setState(() => _listening = true);
      Sfx.play('tap', haptic: true);
      await _stt.listen(
        onResult: (r) {
          if (mounted) setState(() => _freeCtrl.text = r.recognizedWords);
        },
        localeId: _sttLocale,
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (_) {
      if (mounted) setState(() => _listening = false);
      _snack(t('mic_denied'));
    }
  }

  void _sendFree() {
    final q = _freeCtrl.text.trim();
    if (q.isEmpty) return;
    Sfx.play('tap', haptic: true);
    g.askFree(q);
    _freeCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  Widget _freeRow() {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _freeCtrl,
          maxLength: 120,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _sendFree(),
          decoration: InputDecoration(
            hintText: _listening ? t('listening') : t('ask_free_hint'),
            counterText: '',
            isDense: true,
            filled: true,
            fillColor: C.glass,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: C.gold.withValues(alpha: 0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.gold)),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Material(
        color: _listening ? C.pink : C.glass,
        shape: CircleBorder(side: BorderSide(color: _listening ? C.pink : C.gold.withValues(alpha: 0.5))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _toggleListen,
          child: SizedBox(width: 46, height: 46, child: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white)),
        ),
      ),
      const SizedBox(width: 6),
      Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: const BoxDecoration(gradient: C.goldGrad, shape: BoxShape.circle),
          child: InkWell(
            onTap: _sendFree,
            child: const SizedBox(width: 46, height: 46, child: Icon(Icons.send_rounded, color: C.ink)),
          ),
        ),
      ),
    ]);
  }

  Future<void> _startRec() async {
    if (_recording) return;
    try {
      if (!await _rec.hasPermission()) {
        _snack(t('mic_denied'));
        return;
      }
      final dir = await getTemporaryDirectory();
      await _rec.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 32000, sampleRate: 16000, numChannels: 1),
        path: '${dir.path}/ptt.m4a',
      );
      Sfx.play('tap', haptic: true);
      setState(() => _recording = true);
      _recT?.cancel();
      _recT = Timer(const Duration(seconds: 8), _stopRec);
    } catch (_) {
      _snack(t('mic_denied'));
    }
  }

  Future<void> _stopRec() async {
    if (!_recording) return;
    _recT?.cancel();
    setState(() => _recording = false);
    try {
      final path = await _rec.stop();
      if (path == null) return;
      final bytes = await File(path).readAsBytes();
      if (bytes.length < 2000) return; // too short
      await g.sendVoice(bytes);
      _snack('🎙️ ${t('voice_sent')}');
    } catch (_) {}
  }

  Widget _pttButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startRec(),
      onLongPressEnd: (_) => _stopRec(),
      onTap: () => _snack(t('hold_to_talk')),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: _recording ? 52 : 44,
        height: _recording ? 52 : 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _recording ? C.pink : C.glass,
          border: Border.all(color: _recording ? C.pink : C.glassBorder),
          boxShadow: _recording ? [BoxShadow(color: C.pink.withValues(alpha: 0.6), blurRadius: 18)] : null,
        ),
        child: const Icon(Icons.mic_rounded, size: 22, color: Colors.white),
      ),
    );
  }

  Widget _reveal(String label, CardItem d, Gradient grad) {
    return GradientFrame(
      gradient: grad,
      fill: const Color(0xFF1A1536),
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(children: [
        Text(label, style: const TextStyle(color: C.muted, fontSize: 12)),
        CardPic(d, size: 60),
        Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
      ]),
    );
  }

  List<String> get _phrases => ['😂', '👏', '🔥', '😱', '🤔', '😎', t('ch_close'), t('ch_nice'), t('ch_hurry'), t('ch_luck'), t('ch_again'), 'GG'];

  Widget _quickChat() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        for (final p in _phrases)
          ActionChip(
            label: Text(p, style: const TextStyle(fontSize: 14)),
            backgroundColor: C.glass,
            side: const BorderSide(color: C.glassBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onPressed: () {
              Sfx.play('tap');
              g.sendChat(p);
            },
          ),
      ],
    );
  }

  void _openChat() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(c).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _quickChat(),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                maxLength: 60,
                decoration: InputDecoration(
                  hintText: t('type_msg'),
                  counterText: '',
                  filled: true,
                  fillColor: C.glass,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GlassIconButton(
              icon: Icons.send_rounded,
              onPressed: () {
                final s = ctrl.text.trim();
                if (s.isEmpty) return;
                g.sendChat(s);
                Navigator.pop(c);
              },
            ),
          ]),
        ]),
      ),
    );
  }

  void _openDeck() {
    Sfx.play('tap');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(c).size.height * 0.78,
          child: Column(children: [
            Text(t('tap_to_guess'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.78),
                itemCount: g.cat.cards.length,
                itemBuilder: (_, i) {
                  final d = g.cat.cards[i];
                  final ok = g.consistent(d);
                  final gone = g.myWrong.contains(d.id);
                  return Opacity(
                    opacity: ok ? 1 : 0.25,
                    child: Material(
                      color: ok ? C.surface2 : C.glass,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: ok ? C.gold.withValues(alpha: 0.35) : C.glassBorder),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: gone
                            ? null
                            : () {
                                Navigator.pop(c);
                                g.guess(d);
                              },
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          CardPic(d, size: 46, radius: 10),
                          const SizedBox(height: 4),
                          Text(d.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
