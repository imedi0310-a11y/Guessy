import 'package:flutter/material.dart';
import '../data.dart';
import '../game.dart';
import '../prefs.dart';
import '../strings.dart';
import '../theme.dart';

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
    _resultShown = false;
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {});
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
              duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
        }
      });
    }
    if (g.over != null && !_resultShown) {
      _resultShown = true;
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
        title: Text(t('leave_q')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('stay'))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(t('leave'))),
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
        appBar: AppBar(
          backgroundColor: C.bg,
          title: Text('${widget.cat.icon} ${widget.daily ? t('daily') : widget.cat.label}'),
          actions: [
            if (!widget.daily) _timerChip(),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _cardsRow(),
              _statusLine(),
              Expanded(child: _logView()),
              _bottomPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timerChip() {
    final active = g.turn == Who.me && g.pending == null && g.over == null;
    final low = g.secsLeft <= 10;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: active ? 1 : 0.35,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: low && active ? C.pink : C.surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('⏱ ${g.secsLeft}', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _cardsRow() {
    final opp = g.oppCard;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _cardBox(
              title: '${t('you')} · ${t('your_card')}',
              sub: t('on_head'),
              emoji: '❓',
              name: '???',
              color: C.yellow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: widget.daily
                ? _cardBox(
                    title: t('cards_left'),
                    sub: widget.cat.label,
                    emoji: '📅',
                    name: '${g.possible.length}',
                    color: C.pink,
                  )
                : _cardBox(
                    title: '${t('ai_name')} · ${t('their_card')}',
                    sub: t('you_see'),
                    emoji: opp!.emoji,
                    name: opp.name,
                    color: C.pink,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cardBox({required String title, required String sub, required String emoji, required String name, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: C.muted)),
          const SizedBox(height: 4),
          Text(emoji, style: const TextStyle(fontSize: 38)),
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          Text(sub, style: const TextStyle(fontSize: 11, color: C.muted)),
        ],
      ),
    );
  }

  Widget _statusLine() {
    String s;
    if (g.over != null) {
      s = g.over!.win ? t('you_won') : t('you_lost');
    } else if (g.pending != null) {
      s = t('answer_opp');
    } else if (g.turn == Who.opp) {
      s = t('ai_thinking');
    } else {
      s = widget.daily ? '${t('moves')}: ${g.myMoves}' : t('your_turn');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Text(s, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text('${g.possible.length} ${t('cards_left')}', style: const TextStyle(color: C.muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _logView() {
    if (g.log.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(widget.daily ? t('daily_intro') : t('start_hint'),
              textAlign: TextAlign.center, style: const TextStyle(color: C.muted, fontSize: 15)),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      itemCount: g.log.length,
      itemBuilder: (_, i) => _bubble(g.log[i]),
    );
  }

  Widget _bubble(LogEntry e) {
    final mine = e.who == Who.me;
    String badge = '';
    Color badgeColor = C.muted;
    if (e.kind == Kind.q && e.ans != null) {
      badge = e.ans == 'yes' ? t('yes') : t('no');
      badgeColor = e.ans == 'yes' ? C.green : C.pink;
    } else if (e.kind == Kind.g && e.ok != null) {
      badge = e.ok! ? '✓' : '✗';
      badgeColor = e.ok! ? C.green : C.pink;
    }
    return Align(
      alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: mine ? C.surface2 : C.pink.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mine ? (e.note == 'hint' ? '💡' : '🙋') : '🤖'),
            const SizedBox(width: 6),
            Flexible(child: Text(e.text)),
            if (badge.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: const TextStyle(color: C.bg, fontWeight: FontWeight.w800)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bottomPanel() {
    Widget child;
    if (g.over != null) {
      child = const SizedBox.shrink();
    } else if (g.pending != null) {
      child = _pendingPanel(g.pending!);
    } else if (g.turn == Who.opp) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Text(t('ai_thinking')),
        ],
      );
    } else {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.daily)
            Row(
              children: [
                _life('💡', t('hint'), g.lifeHint, g.useHint),
                const SizedBox(width: 8),
                _life('✂️', t('half'), g.lifeHalf, g.useHalf),
                const SizedBox(width: 8),
                _life('⏭️', t('skip'), g.lifeSkip && !g.skipNext, g.useSkip),
              ],
            ),
          if (!widget.daily) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: g.unasked.isEmpty ? null : _openQuestions,
                  child: Text('❓ ${t('ask')}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: C.pink, foregroundColor: Colors.white),
                  onPressed: _openDeck,
                  child: Text('🎯 ${t('guess')}'),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: child,
    );
  }

  Widget _life(String icon, String label, bool enabled, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40), padding: EdgeInsets.zero),
        onPressed: enabled ? onTap : null,
        child: Text('$icon $label', style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _pendingPanel(Pending p) {
    final isGuess = p.kind == Kind.g;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(isGuess ? t('opp_guess') : t('opp_asks'), style: const TextStyle(color: C.muted, fontSize: 13)),
        const SizedBox(height: 6),
        Text(p.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('${t('card_says')}${p.suggestYes ? t('yes') : t('no')}',
            style: const TextStyle(color: C.yellow, fontSize: 13)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: C.green, foregroundColor: C.bg),
                onPressed: () => g.answer(true),
                child: Text('✓ ${t('yes')}'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: C.pink, foregroundColor: Colors.white),
                onPressed: () => g.answer(false),
                child: Text('✗ ${t('no')}'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openQuestions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: C.surface,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) {
        final qs = g.unasked;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(c).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t('pick_q'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Flexible(
                  child: qs.isEmpty
                      ? Padding(padding: const EdgeInsets.all(24), child: Text(t('no_q_left')))
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: qs.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) => ListTile(
                            title: Text(qs[i].text),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.pop(c);
                              g.ask(qs[i]);
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDeck() {
    showModalBottomSheet(
      context: context,
      backgroundColor: C.surface,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) {
        final cards = widget.cat.cards;
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(c).size.height * 0.75,
            child: Column(
              children: [
                Text(t('tap_to_guess'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text('${g.possible.length} ${t('cards_left')}', style: const TextStyle(color: C.muted, fontSize: 12)),
                const SizedBox(height: 8),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (_, i) {
                      final d = cards[i];
                      final ok = g.consistent(d);
                      final gone = g.myWrong.contains(d.id) || g.removed.contains(d.id);
                      return Opacity(
                        opacity: ok ? 1 : 0.28,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: gone ? null : () => _confirmGuess(c, d),
                          child: Container(
                            decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(d.emoji, style: const TextStyle(fontSize: 26)),
                                const SizedBox(height: 2),
                                Text(d.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11)),
                              ],
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
      },
    );
  }

  Future<void> _confirmGuess(BuildContext sheetCtx, CardItem d) async {
    final yes = await showDialog<bool>(
      context: sheetCtx,
      builder: (c) => AlertDialog(
        title: Text(t('confirm_guess')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(d.emoji, style: const TextStyle(fontSize: 48)),
            Text(d.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(c, true),
            child: Text(t('guess')),
          ),
        ],
      ),
    );
    if (yes == true) {
      if (sheetCtx.mounted) Navigator.pop(sheetCtx);
      g.guess(d);
    }
  }

  void _showResult() {
    if (!mounted) return;
    final r = g.over!;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: C.surface,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.daily ? t('daily_solved') : (r.win ? t('you_won') : t('you_lost')),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: r.win ? C.yellow : C.pink)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _reveal(t('your_card_was'), g.myCard),
                  if (g.oppCard != null) ...[const SizedBox(width: 16), _reveal(t('their_card_was'), g.oppCard!)],
                ],
              ),
              const SizedBox(height: 12),
              Text('${t('moves')}: ${r.moves}   ·   +$_xpGain XP', style: const TextStyle(color: C.muted)),
              if (widget.daily) Padding(padding: const EdgeInsets.only(top: 6), child: Text(t('come_back'))),
              const SizedBox(height: 18),
              if (!widget.daily)
                FilledButton(
                  onPressed: () {
                    Navigator.pop(c);
                    setState(() {
                      g.removeListener(_onChange);
                      g.dispose();
                      _newGame();
                    });
                  },
                  child: Text(t('play_again')),
                ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(c);
                  Navigator.pop(context);
                },
                child: Text(t('home')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reveal(String label, CardItem d) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: C.muted, fontSize: 12)),
        Text(d.emoji, style: const TextStyle(fontSize: 44)),
        Text(d.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ],
    );
  }
}
