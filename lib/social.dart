import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'online.dart';
import 'prefs.dart';

class Invite {
  final String fromId;
  final String fromName;
  final String code;
  Invite(this.fromId, this.fromName, this.code);
}

class FriendInfo {
  final String id;
  final String name;
  final bool online;
  FriendInfo(this.id, this.name, this.online);
}

/// Player IDs, friends list and in-game invites.
class Social {
  static final ValueNotifier<String?> myId = ValueNotifier<String?>(null);
  static final ValueNotifier<Invite?> incoming = ValueNotifier<Invite?>(null);
  static StreamSubscription<DatabaseEvent>? _inv;
  static bool _starting = false;

  /// 8-digit numeric ID, never starting with 0.
  static String _gen() {
    final r = Random.secure();
    return '${r.nextInt(9) + 1}${List.generate(7, (_) => r.nextInt(10)).join()}';
  }

  static bool _valid(String id) => RegExp(r'^[1-9][0-9]{7}$').hasMatch(id);

  static String get _name => Prefs.name.trim().isEmpty ? 'Guessy' : Prefs.name.trim();

  /// Creates (once) the player's public ID, marks them online and listens for invites.
  static Future<void> start() async {
    if (_starting || myId.value != null) return;
    _starting = true;
    try {
      await Online.ready;
      if (!Online.available) return;
      final uid = await Online.uid();
      var id = Prefs.myId;
      if (!_valid(id)) id = ''; // old letter IDs get a new numeric one
      if (id.isEmpty) {
        for (var i = 0; i < 8; i++) {
          final cand = _gen();
          final res = await Online.db.ref('users/$cand').runTransaction((cur) {
            if (cur != null) return Transaction.abort();
            return Transaction.success({'uid': uid, 'name': _name, 'on': true});
          });
          if (res.committed) {
            id = cand;
            Prefs.myId = cand;
            break;
          }
        }
      }
      if (id.isEmpty) return;
      final me = Online.db.ref('users/$id');
      await me.child('on').onDisconnect().set(false);
      await me.update({'on': true, 'name': _name, 'uid': uid, 'seen': ServerValue.timestamp});
      myId.value = id;
      final since = DateTime.now().millisecondsSinceEpoch - 120000;
      _inv = me.child('invites').onChildAdded.listen((e) {
        final v = e.snapshot.value;
        e.snapshot.ref.remove();
        if (v is! Map) return;
        final ts = v['ts'] is num ? (v['ts'] as num).toInt() : 0;
        if (ts < since) return;
        incoming.value = Invite('${v['fromId']}', '${v['fromName']}', '${v['code']}');
      });
    } catch (e) {
      debugPrint('Social.start failed: $e');
    } finally {
      _starting = false;
    }
  }

  static Future<void> updateName() async {
    final id = myId.value;
    if (id == null) return;
    try {
      await Online.db.ref('users/$id/name').set(_name);
    } catch (_) {}
  }

  /// Looks up a player by ID. Returns null if no such player.
  static Future<FriendInfo?> lookup(String id) async {
    final snap = await Online.db.ref('users/$id').get();
    final v = snap.value;
    if (v is! Map) return null;
    return FriendInfo(id, '${v['name'] ?? id}', v['on'] == true);
  }

  static Stream<FriendInfo> watch(String id) {
    return Online.db.ref('users/$id').onValue.map((e) {
      final v = e.snapshot.value;
      if (v is! Map) return FriendInfo(id, id, false);
      return FriendInfo(id, '${v['name'] ?? id}', v['on'] == true);
    });
  }

  static Future<void> sendInvite(String friendId, String code) async {
    await Online.db.ref('users/$friendId/invites').push().set({
      'fromId': myId.value ?? '',
      'fromName': _name,
      'code': code,
      'ts': ServerValue.timestamp,
    });
  }

  // ---- friends list, stored on the device as "ID|name;ID|name" ----
  static List<(String, String)> get friends {
    final raw = Prefs.friendsRaw;
    if (raw.isEmpty) return [];
    return [
      for (final part in raw.split(';'))
        if (part.contains('|')) (part.split('|')[0], part.split('|').sublist(1).join('|')),
    ];
  }

  static void saveFriends(List<(String, String)> list) {
    Prefs.friendsRaw = list.map((f) => '${f.$1}|${f.$2.replaceAll(';', ' ').replaceAll('|', ' ')}').join(';');
  }

  static void addFriend(String id, String name) {
    final list = friends.where((f) => f.$1 != id).toList()..insert(0, (id, name));
    saveFriends(list);
  }

  static void removeFriend(String id) => saveFriends(friends.where((f) => f.$1 != id).toList());
}
