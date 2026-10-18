import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'data.dart';
import 'strings.dart';

const _dbUrl = 'https://guessy-39af7-default-rtdb.europe-west1.firebasedatabase.app';

/// Firebase connection (anonymous auth + Realtime Database).
class Online {
  static bool available = false;
  static String? error;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAgYiS2SaWcqe_E9NkQuyZmFCuBSSxg3ac',
          appId: '1:926804085134:android:04b081dcb2bccc33c3fcdf',
          messagingSenderId: '926804085134',
          projectId: 'guessy-39af7',
          storageBucket: 'guessy-39af7.firebasestorage.app',
          databaseURL: _dbUrl,
        ),
      ).timeout(const Duration(seconds: 8));
      available = true;
    } catch (e) {
      error = '$e';
      available = false;
      debugPrint('Firebase init failed: $e');
    }
  }

  static FirebaseDatabase get db => FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: _dbUrl);

  static Future<String> uid() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) await auth.signInAnonymously();
    return auth.currentUser!.uid;
  }

  static String newCode() {
    const ch = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(4, (_) => ch[r.nextInt(ch.length)]).join();
  }

  /// Creates a room and returns its code.
  static Future<String> createRoom(String catId, String name) async {
    final id = await uid();
    for (var i = 0; i < 6; i++) {
      final code = newCode();
      final ref = db.ref('rooms/$code');
      final snap = await ref.get();
      if (snap.exists) continue;
      await ref.set({
        'v': 1,
        'cat': catId,
        'created': ServerValue.timestamp,
        'round': 0,
        'score': {'h': 0, 'g': 0},
        'players': {
          'h': {'uid': id, 'name': name, 'on': true},
        },
      });
      return code;
    }
    throw Exception('no code');
  }

  /// Joins a room. Returns 'h' or 'g' (seat), or throws 'not_found' / 'full'.
  static Future<String> joinRoom(String code, String name) async {
    final id = await uid();
    final ref = db.ref('rooms/$code');
    final snap = await ref.get();
    if (!snap.exists) throw 'not_found';
    final m = Map<String, dynamic>.from(snap.value as Map);
    final players = Map<String, dynamic>.from((m['players'] ?? {}) as Map);
    final h = players['h'] == null ? null : Map<String, dynamic>.from(players['h'] as Map);
    final g = players['g'] == null ? null : Map<String, dynamic>.from(players['g'] as Map);
    if (h != null && h['uid'] == id) return 'h';
    if (g != null && g['uid'] != id) throw 'full';
    await ref.child('players/g').set({'uid': id, 'name': name, 'on': true});
    return 'g';
  }
}

class OnlineEntry {
  final String who; // 'h' | 'g'
  final String kind; // 'q' | 'g'
  final String? key;
  final String? cardId;
  final bool? yes; // answer for q, ok for g
  OnlineEntry(this.who, this.kind, {this.key, this.cardId, this.yes});
}

class ChatMsg {
  final String id;
  final String who;
  final String text;
  ChatMsg(this.id, this.who, this.text);
}

/// Live state of one online room, seen from seat [me].
class OnlineGame extends ChangeNotifier {
  final String code;
  final String me;
  String get opp => me == 'h' ? 'g' : 'h';
  late final DatabaseReference ref = Online.db.ref('rooms/$code');
  StreamSubscription<DatabaseEvent>? _sub, _chatSub, _offSub;
  Timer? _clock;
  int _offset = 0;
  Map<String, dynamic> room = {};
  final List<ChatMsg> chat = [];
  ChatMsg? lastIncoming;
  bool closed = false;
  bool _starting = false;
  static const turnSecs = 45;

  OnlineGame(this.code, this.me);

  Future<void> start() async {
    final myRef = ref.child('players/$me/on');
    await myRef.onDisconnect().set(false);
    await myRef.set(true);
    _offSub = Online.db.ref('.info/serverTimeOffset').onValue.listen((e) {
      final v = e.snapshot.value;
      if (v is num) _offset = v.toInt();
    });
    _sub = ref.onValue.listen((e) {
      final v = e.snapshot.value;
      if (v == null) {
        closed = true;
        _notify();
        return;
      }
      room = _deepMap(v);
      _maybeStartRound();
      _notify();
    });
    _chatSub = ref.child('chat').onChildAdded.listen((e) {
      final m = _deepMap(e.snapshot.value);
      final msg = ChatMsg(e.snapshot.key ?? '', '${m['who']}', '${m['t'] ?? ''}');
      chat.add(msg);
      if (msg.who != me) lastIncoming = msg;
      _notify();
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  static Map<String, dynamic> _deepMap(Object? v) {
    if (v is Map) return v.map((k, val) => MapEntry('$k', val is Map ? _deepMap(val) : val));
    return {};
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  int get now => DateTime.now().millisecondsSinceEpoch + _offset;

  // ---------- derived state ----------
  Map<String, dynamic> _player(String seat) =>
      (room['players'] is Map && room['players'][seat] is Map) ? room['players'][seat] as Map<String, dynamic> : {};
  String nameOf(String seat) => '${_player(seat)['name'] ?? ''}';
  bool hasPlayer(String seat) => _player(seat).isNotEmpty;
  bool isOnline(String seat) => _player(seat)['on'] == true;
  Cat get cat => GameData.cat('${room['cat'] ?? 'animals'}');
  CardItem? _card(String seat) {
    final cards = room['cards'];
    if (cards is! Map) return null;
    final id = cards[seat];
    for (final c in cat.cards) {
      if (c.id == id) return c;
    }
    return null;
  }

  CardItem? get myCard => _card(me);
  CardItem? get oppCard => _card(opp);
  bool get ready => myCard != null && oppCard != null;
  String get turn => '${room['turn'] ?? 'h'}';
  bool get myTurn => turn == me && over == null;
  int get turnAt => (room['turnAt'] is num) ? (room['turnAt'] as num).toInt() : now;
  int get secsLeft => max(0, turnSecs - ((now - turnAt) ~/ 1000));
  String? get over => room['over'] is Map ? '${room['over']['win']}' : null;
  int score(String seat) => (room['score'] is Map && room['score'][seat] is num) ? (room['score'][seat] as num).toInt() : 0;
  int get round => (room['round'] is num) ? (room['round'] as num).toInt() : 0;

  List<OnlineEntry> get log {
    final l = room['log'];
    if (l is! Map) return [];
    final keys = l.keys.toList()..sort();
    return [
      for (final k in keys)
        if (l[k] is Map)
          OnlineEntry('${l[k]['w']}', '${l[k]['k']}',
              key: l[k]['a'] as String?, cardId: l[k]['c'] as String?, yes: l[k]['y'] == 1 || l[k]['y'] == true),
    ];
  }

  Map<String, bool> get myKnown => {
        for (final e in log)
          if (e.who == me && e.kind == 'q' && e.key != null) e.key!: e.yes == true,
      };
  Set<String> get myWrong => {for (final e in log) if (e.who == me && e.kind == 'g' && e.yes != true && e.cardId != null) e.cardId!};

  bool consistent(CardItem c) {
    if (myWrong.contains(c.id)) return false;
    for (final e in myKnown.entries) {
      if (c.flags.contains(e.key) != e.value) return false;
    }
    return true;
  }

  List<Attr> get unasked => cat.attrs.where((a) => !myKnown.containsKey(a.key)).toList();

  CardItem? cardById(String? id) {
    for (final c in cat.cards) {
      if (c.id == id) return c;
    }
    return null;
  }

  String entryText(OnlineEntry e) {
    if (e.kind == 'q') return cat.attr(e.key ?? '')?.text ?? '';
    final c = cardById(e.cardId);
    return '${t('is_it_pre')}${c?.name ?? '?'}${t('is_it_post')}';
  }

  // ---------- actions ----------
  void _maybeStartRound() {
    if (me != 'h' || _starting) return;
    if (hasPlayer('g') && room['cards'] == null) {
      _starting = true;
      newRound().whenComplete(() => _starting = false);
    }
  }

  Future<void> newRound() async {
    final cards = cat.cards;
    final r = Random();
    final a = cards[r.nextInt(cards.length)];
    CardItem b;
    do {
      b = cards[r.nextInt(cards.length)];
    } while (b.id == a.id);
    await ref.update({
      'cards': {'h': a.id, 'g': b.id},
      'turn': r.nextBool() ? 'h' : 'g',
      'turnAt': ServerValue.timestamp,
      'log': null,
      'over': null,
      'round': round + 1,
    });
  }

  Future<void> ask(Attr a) async {
    final mine = myCard;
    if (!myTurn || mine == null || myKnown.containsKey(a.key)) return;
    final yes = mine.flags.contains(a.key);
    await ref.child('log').push().set({'w': me, 'k': 'q', 'a': a.key, 'y': yes ? 1 : 0});
    await ref.update({'turn': opp, 'turnAt': ServerValue.timestamp});
  }

  Future<void> guess(CardItem c) async {
    final mine = myCard;
    if (!myTurn || mine == null) return;
    final ok = c.id == mine.id;
    await ref.child('log').push().set({'w': me, 'k': 'g', 'c': c.id, 'y': ok ? 1 : 0});
    if (ok) {
      await ref.update({
        'over': {'win': me},
        'score/$me': ServerValue.increment(1),
      });
    } else {
      await ref.update({'turn': opp, 'turnAt': ServerValue.timestamp});
    }
  }

  Future<void> sendChat(String text) async {
    await ref.child('chat').push().set({'who': me, 't': text, 'ts': ServerValue.timestamp});
  }

  void _tick() {
    if (!ready || over != null) return;
    // If the opponent's clock ran out (e.g. they left the app), pass the turn back.
    if (turn == opp && now - turnAt > (turnSecs + 3) * 1000) {
      ref.update({'turn': me, 'turnAt': ServerValue.timestamp});
    } else if (turn == me && secsLeft <= 0) {
      ref.update({'turn': opp, 'turnAt': ServerValue.timestamp});
    }
    _notify();
  }

  Future<void> leave() async {
    try {
      await ref.child('players/$me/on').set(false);
    } catch (_) {}
  }

  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _chatSub?.cancel();
    _offSub?.cancel();
    _clock?.cancel();
    super.dispose();
  }
}
