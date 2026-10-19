import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../game.dart';
import '../prefs.dart';
import '../sfx.dart';
import '../strings.dart';
import '../theme.dart';
import '../ui.dart';
import '../free_ask.dart';

class GameScreen extends StatefulWidget {
  final Cat cat;
  final String diff;
  final bool daily;
  final CardItem? fixedCard;
  const GameScreen({super.key, required this.cat, required this.diff, this.daily = false, this.fixedCard});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController g;
  final _scroll = ScrollController();
  int _lastLog = 0;
  bool _resultShown = false;
  int _xpGain = 0;
  int _rerolls = 0;
  int _sndLen = 0;
  int _prevSecs = 99;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    g = GameController(cat: widget.cat, diff: widget.diff, daily: widget.daily, fixedCard: widget.fixedCard);
    g.onEnd = (r) {
      _xpGain = widget.daily ? Prefs.recordDaily(r.moves) : Prefs.recordRound(win: r.win, diff: widget.diff);
    };
    g.addListener(_onChange);
    _lastLog = 0;
    _sndLen = 0;
    _prevSecs = 99;
    _resultShown = false;
  }

  void _sounds() {
    if (g.log.length > _sndLen) {
      final e = g.log.last;
      if (e.who == Who.me) {
        if (e.kind == Kind.q) {
          Sfx.play(e.ans == 'yes' ? 'yes' : 'no');
        } else if (e.ok == false) {
          Sfx.play('wrong', haptic: true);
        }
      } else {
        Sfx.play('pop');
      }
    }
    _sndLen = g.log.length;
    final myClock = g.turn == Who.me && g.pending == null && g.over == null && !widget.daily;
    if (myClock && g.secsLeft <= 10 && g.secsLeft > 0 && g.secsLeft != _prevSecs) Sfx.play('tick');
    _prevSecs = g.secsLeft;
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
    _sounds();
    final f = g.flash;
    if (f != null) {
      g.flash = null;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t(f)), duration: const Duration(milliseconds: 1800)));
    }
    if (g.log.length != _lastLog) {
      _lastLog = g.log.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
        }
      });
    }
    if (g.over != null && !_resultShown) {
      _resultShown = true;
      Sfx.play(g.over!.win ? 'win' : 'lose', haptic: true);
      Future.delayed(const Duration(milliseconds: 500), _showResult);
    }
  }

  @override
  void dispose() {
    g.removeListener(_onChange);
    g.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<bool> _confirmLeave() async {
    if (g.over != null) return true;
    final r = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t('leave_q'), style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('stay'))),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(t('leave'), style: const TextStyle(color: C.pink)),
          ),
        ],
      ),
    );
    return r == true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        if (await _confirmLeave()) nav.pop();
      },
      child: Scaffold(
        body: LuxBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(),
                _cardsRow(),
                _statusLine(),
                Expanded(child: _logView()),
                _bottomPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- header ----------------
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_rounded, onPressed: () => Navigator.maybePop(context)),
          Expanded(
            child: Column(
              children: [
                Text(widget.daily ? t('daily') : widget.cat.label,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                Text(widget.daily ? widget.cat.label : t(widget.diff),
                    style: const TextStyle(fontSize: 12, color: C.muted)),
              ],
            ),
          ),
          const SoundButton(),
          const SizedBox(width: 8),
          if (!widget.daily) _timerRing() else const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _timerRing() {
    final active = g.turn == Who.me && g.pending == null && g.over == null;
    final low = g.secsLeft <= 10;
    final color = low ? C.pink : C.gold;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: active ? 1 : 0.35,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: g.secsLeft / GameController.turnSecs,
                strokeWidth: 3.5,
                backgroundColor: C.glassBorder,
                color: color,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text('${g.secsLeft}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
          ],
        ),
      ),
    );
  }

  // ---------------- cards ----------------
  Widget _cardsRow() {
    final opp = g.oppCard;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: _playCard(
              gradient: C.goldGrad,
              glow: C.gold,
              title: t('you'),
              center: const GradientText('?', style: TextStyle(fontSize: 46, fontWeight: FontWeight.w900, height: 1.05)),
              name: null,
              sub: t('on_head'),
              nameColor: C.goldLight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: widget.daily
                ? _playCard(
                    gradient: C.roseGrad,
                    glow: C.pink,
                    title: t('cards_left'),
                    center: GradientText('${g.possible.length}',
                        gradient: C.roseGrad,
                        style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w900, height: 1.2)),
                    name: null,
                    sub: widget.cat.label,
                    nameColor: C.pink,
                  )
                : _playCard(
                    gradient: C.roseGrad,
                    glow: C.pink,
                    title: t('ai_name'),
                    center: CardPic(opp!, size: 62),
                    name: opp.name,
                    sub: t('you_see'),
                    nameColor: const Color(0xFFFF9DBE),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _playCard({
    required Gradient gradient,
    required Color glow,
    required String title,
    required Widget center,
    required String? name,
    required String sub,
    required Color nameColor,
  }) {
    return SizedBox(
      height: 150,
      child: GradientFrame(
        gradient: gradient,
        glow: glow,
        radius: 22,
        fill: const Color(0xFF191433),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: C.muted, fontWeight: FontWeight.w600)),
            center,
            if (name != null)
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: nameColor)),
            Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: C.muted)),
          ],
        ),
      ),
    );
  }

  // ---------------- status ----------------
  Widget _statusLine() {
    String s;
    Color dot;
    if (g.over != null) {
      s = g.over!.win ? t('you_won') : t('you_lost');
      dot = g.over!.win ? C.green : C.pink;
    } else if (g.pending != null) {
      s = t('answer_opp');
      dot = C.pink;
    } else if (g.turn == Who.opp) {
      s = t('ai_thinking');
      dot = C.violet;
    } else {
      s = widget.daily ? '${t('moves')}: ${g.myMoves}' : t('your_turn');
      dot = C.gold;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: C.glass,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: dot.withValues(alpha: 0.45)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: dot, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                      child: Text(s,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                ],
              ),
            ),
            ),
          ),
          const SizedBox(width: 10),
          if (!widget.daily && g.over == null && g.log.isEmpty) ...[
            RerollChip(
              left: 3 - _rerolls,
              onTap: () {
                if (_rerolls >= 3 || g.log.isNotEmpty) return;
                Sfx.play('magic', haptic: true);
                setState(() {
                  _rerolls++;
                  g.removeListener(_onChange);
                  g.dispose();
                  _newGame();
                });
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(t('cards_changed')), duration: const Duration(milliseconds: 1500)));
              },
            ),
            const SizedBox(width: 8),
          ],
          Text('${g.possible.length}', style: const TextStyle(color: C.gold, fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(width: 4),
          Text(t('cards_left'), style: const TextStyle(color: C.muted, fontSize: 12)),
        ],
      ),
    );
  }

  // ---------------- log ----------------
  Widget _logView() {
    if (g.log.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💬', style: TextStyle(fontSize: 26)),
              const SizedBox(height: 8),
              Text(widget.daily ? t('daily_intro') : t('start_hint'),
                  textAlign: TextAlign.center, style: const TextStyle(color: C.muted, fontSize: 15, height: 1.6)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      itemCount: g.log.length,
      itemBuilder: (_, i) => _bubble(g.log[i]),
    );
  }

  Widget _bubble(LogEntry e) {
    final mine = e.who == Who.me;
    String badge = '';
    Gradient? badgeGrad;
    if (e.kind == Kind.q && e.ans != null) {
      badge = e.ans == 'yes' ? t('yes') : t('no');
      badgeGrad = e.ans == 'yes' ? C.greenGrad : C.roseGrad;
    } else if (e.kind == Kind.g && e.ok != null) {
      badge = e.ok! ? '✓' : '✗';
      badgeGrad = e.ok! ? C.greenGrad : C.roseGrad;
    }
    final r = BorderRadiusDirectional.only(
      topStart: const Radius.circular(18),
      topEnd: const Radius.circular(18),
      bottomStart: Radius.circular(mine ? 4 : 18),
      bottomEnd: Radius.circular(mine ? 18 : 4),
    );
    return Align(
      alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: mine ? C.glass : C.pink.withValues(alpha: 0.12),
          borderRadius: r,
          border: Border.all(color: mine ? C.gold.withValues(alpha: 0.28) : C.pink.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mine ? (e.note == 'hint' ? '💡' : '🙋') : '🤖', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(child: Text(e.text, style: const TextStyle(fontSize: 14.5, height: 1.35))),
            if (badge.isNotEmpty) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(gradient: badgeGrad, borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: const TextStyle(color: C.ink, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- bottom panel ----------------
  Widget _bottomPanel() {
    Widget child;
    if (g.over != null) {
      child = const SizedBox(height: 8);
    } else if (g.pending != null) {
      child = _pendingPanel(g.pending!);
    } else if (g.turn == Who.opp) {
      child = Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: C.violet)),
            const SizedBox(width: 12),
            Text(t('ai_thinking'), style: const TextStyle(color: C.muted, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    } else {
      child = _myTurnPanel();
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C1640), Color(0xFF120F26)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: C.gold.withValues(alpha: 0.30))),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, -6))],
      ),
      child: AnimatedSize(duration: const Duration(milliseconds: 220), curve: Curves.easeOut, child: child),
    );
  }

  void _freeAsk(String text) {
    final r = g.askFree(text);
    if (r == 'amb') {
      _openDeck(only: g.candidates);
      return;
    }
    if (r == null || r == 'dup') {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t(r == 'dup' ? 'already_asked' : 'not_understood'))));
    }
  }

  Widget _myTurnPanel() {
    final qs = g.unasked;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FreeAskBar(onSubmit: _freeAsk),
        const SizedBox(height: 10),
        if (!widget.daily) ...[
          Row(
            children: [
              _life('💡', t('hint'), g.lifeHint, g.useHint),
              const SizedBox(width: 8),
              _life('✂️', t('half'), g.lifeHalf, g.useHalf),
              const SizedBox(width: 8),
              _life('⏭️', t('skip'), g.lifeSkip && !g.skipNext, g.useSkip),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Container(width: 3, height: 16, decoration: BoxDecoration(gradient: C.goldGrad, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 8),
            Text(qs.isEmpty ? t('no_q_left') : t('pick_q'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (qs.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: BoxDecoration(color: C.gold.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
                child: Text('${qs.length}', style: const TextStyle(color: C.gold, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (qs.isNotEmpty)
          SizedBox(
            height: 122,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                stops: [0, 0.04, 0.94, 1],
              ).createShader(r),
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 168,
                ),
                itemCount: qs.length,
                itemBuilder: (_, i) => QuestionTile(
                    text: qs[i].text,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      g.ask(qs[i]);
                    }),
              ),
            ),
          ),
        const SizedBox(height: 12),
        LuxButton(
          label: '🎯 ${t('guess')}',
          gradient: C.roseGrad,
          textColor: Colors.white,
          height: 50,
          onPressed: () => _openDeck(),
        ),
      ],
    );
  }

  Widget _life(String icon, String label, bool enabled, VoidCallback onTap) {
    return Expanded(
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Material(
          color: C.glass,
          shape: StadiumBorder(side: BorderSide(color: enabled ? C.gold.withValues(alpha: 0.5) : C.glassBorder)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: enabled
                ? () {
                    Sfx.play('magic', haptic: true);
                    onTap();
                  }
                : null,
            child: SizedBox(
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: C.goldLight)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pendingPanel(Pending p) {
    final isGuess = p.kind == Kind.g;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('🤖', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(isGuess ? t('opp_guess') : t('opp_asks'),
                  style: const TextStyle(color: C.muted, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(p.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.3)),
        const SizedBox(height: 10),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: C.gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: C.gold.withValues(alpha: 0.35)),
            ),
            child: Text('${t('card_says')}${p.suggestYes ? t('yes') : t('no')}',
                style: const TextStyle(color: C.goldLight, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: LuxButton(
                label: '✓ ${t('yes')}',
                gradient: C.greenGrad,
                textColor: C.ink,
                height: 54,
                onPressed: () {
                  Sfx.play('tap', haptic: true);
                  g.answer(true);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LuxButton(
                label: '✗ ${t('no')}',
                gradient: C.roseGrad,
                textColor: Colors.white,
                height: 54,
                onPressed: () {
                  Sfx.play('tap', haptic: true);
                  g.answer(false);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- deck ----------------
  void _openDeck({List<CardItem>? only}) {
    Sfx.play('tap');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) {
        var query = '';
        return StatefulBuilder(builder: (c, setS) {
        final qn = normText(query);
        final cards = (only ?? widget.cat.cards)
            .where((d) => qn.isEmpty || nameMatchesQuery(d, query))
            .toList()
          ..sort((a, b) => (g.consistent(a) ? 0 : 1) - (g.consistent(b) ? 0 : 1));
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(c).size.height * 0.78,
            child: Column(
              children: [
                Text(t('tap_to_guess'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('${g.possible.length} ${t('cards_left')}', style: const TextStyle(color: C.gold, fontSize: 13)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                  child: TextField(
                    onChanged: (v) => setS(() => query = v),
                    decoration: InputDecoration(
                      hintText: t('search_name'),
                      prefixIcon: const Icon(Icons.search_rounded),
                      isDense: true,
                      filled: true,
                      fillColor: C.glass,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (_, i) {
                      final d = cards[i];
                      final ok = g.consistent(d);
                      final gone = g.myWrong.contains(d.id) || g.removed.contains(d.id);
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
                            onTap: gone ? null : () => _confirmGuess(c, d),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CardPic(d, size: 46, radius: 10),
                                  const SizedBox(height: 4),
                                  Text(d.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        decoration: gone ? TextDecoration.lineThrough : null,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
        });
      },
    );
  }

  Future<void> _confirmGuess(BuildContext sheetCtx, CardItem d) async {
    final yes = await showDialog<bool>(
      context: sheetCtx,
      builder: (c) => AlertDialog(
        title: Text(t('confirm_guess'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardPic(d, size: 130, radius: 18),
            const SizedBox(height: 6),
            GradientText(d.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('cancel'))),
          SizedBox(
            width: 130,
            child: LuxButton(label: t('guess'), height: 46, onPressed: () => Navigator.pop(c, true)),
          ),
        ],
      ),
    );
    if (yes == true) {
      if (sheetCtx.mounted) Navigator.pop(sheetCtx);
      g.guess(d);
    }
  }

  // ---------------- result ----------------
  void _showResult() {
    if (!mounted) return;
    final r = g.over!;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      showDragHandle: false,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(r.win ? '🏆' : '🤖', style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 6),
              GradientText(
                widget.daily ? t('daily_solved') : (r.win ? t('you_won') : t('you_lost')),
                align: TextAlign.center,
                gradient: r.win ? C.goldGrad : C.roseGrad,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _reveal(t('your_card_was'), g.myCard, C.goldGrad)),
                  if (g.oppCard != null) ...[const SizedBox(width: 12), Expanded(child: _reveal(t('their_card_was'), g.oppCard!, C.roseGrad))],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pill('${t('moves')}: ${r.moves}'),
                  const SizedBox(width: 8),
                  _pill('+$_xpGain XP', color: C.gold),
                ],
              ),
              if (widget.daily) Padding(padding: const EdgeInsets.only(top: 10), child: Text(t('come_back'), style: const TextStyle(color: C.muted))),
              const SizedBox(height: 20),
              if (!widget.daily) ...[
                LuxButton(
                  label: t('play_again'),
                  onPressed: () {
                    Navigator.pop(c);
                    setState(() {
                      g.removeListener(_onChange);
                      g.dispose();
                      _rerolls = 0;
                      _newGame();
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],
              GlassButton(
                label: t('home'),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(c);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String s, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: C.glass, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.glassBorder)),
      child: Text(s, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _reveal(String label, CardItem d, Gradient grad) {
    return GradientFrame(
      gradient: grad,
      fill: const Color(0xFF1A1536),
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: C.muted, fontSize: 12)),
          const SizedBox(height: 4),
          CardPic(d, size: 64),
          const SizedBox(height: 2),
          Text(d.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}

/// A question as an elegant glass tile with a gold accent bar.
class QuestionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const QuestionTile({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x14FFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: C.gold.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: C.gold.withValues(alpha: 0.18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(gradient: C.goldGrad),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.3),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
