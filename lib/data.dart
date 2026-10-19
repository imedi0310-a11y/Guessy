import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'strings.dart';

class Attr {
  final String key;
  final Map<String, dynamic> q;
  Attr(this.key, this.q);
  String get text => loc(q);
}

class CardItem {
  final String id;
  final String emoji;
  final String en;
  final Map<String, dynamic> names;
  final Set<String> flags;
  String? img; // free photo URL (Wikimedia), may be null
  CardItem(this.id, this.emoji, this.en, this.names, this.flags);
  String get name => loc(names);
}

class Cat {
  final String id;
  final String icon;
  final Map<String, dynamic> labels;
  final bool people;
  final List<Attr> attrs;
  final List<CardItem> cards;
  Cat(this.id, this.icon, this.labels, this.people, this.attrs, this.cards);
  String get label => loc(labels);
  Attr? attr(String key) {
    for (final a in attrs) {
      if (a.key == key) return a;
    }
    return null;
  }
}

class GameData {
  static List<Cat> cats = [];

  static Future<void> load() async {
    if (cats.isNotEmpty) return;
    final raw = await rootBundle.loadString('assets/data/cards.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    cats = (j['cats'] as List).map((c) {
      final m = c as Map<String, dynamic>;
      final attrs = (m['attrs'] as List)
          .map((a) => Attr(a['key'] as String, Map<String, dynamic>.from(a['q'] as Map)))
          .toList();
      final cards = (m['cards'] as List).map((d) {
        final dm = d as Map<String, dynamic>;
        return CardItem(
          '${m['id']}.${dm['id']}',
          dm['emoji'] as String,
          dm['en'] as String,
          Map<String, dynamic>.from(dm['name'] as Map),
          (dm['flags'] as List).map((e) => e.toString()).toSet(),
        );
      }).toList();
      return Cat(m['id'] as String, m['icon'] as String, Map<String, dynamic>.from(m['label'] as Map),
          m['people'] == true, attrs, cards);
    }).toList();
    await _loadImages();
  }

  static Future<void> _loadImages() async {
    try {
      final raw = await rootBundle.loadString('assets/data/images.json');
      final m = jsonDecode(raw) as Map<String, dynamic>;
      for (final c in cats) {
        for (final d in c.cards) {
          final u = m[d.id];
          if (u is String && u.startsWith('assets/')) d.img = u;
        }
      }
    } catch (_) {}
  }

  static Cat cat(String id) => cats.firstWhere((c) => c.id == id, orElse: () => cats.first);
}
