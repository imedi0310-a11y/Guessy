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
  String? img; // bundled photo asset path, may be null
  List<String> alias = const []; // other names people use (nicknames, spellings)
  int? tint; // category theme colour, used to draw a nicer card when there is no photo
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
  String? group; // e.g. 'anime': shown together under one tile on the home screen
  int? color; // optional theme colour (ARGB) for the tile
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
  static Map<String, ({String icon, Map<String, dynamic> labels})> groups = {};

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
        )..alias = ((dm['aliases'] as List?) ?? const []).map((e) => '$e').toList();
      }).toList();
      return Cat(m['id'] as String, m['icon'] as String, Map<String, dynamic>.from(m['label'] as Map),
          m['people'] == true, attrs, cards)
        ..group = m['group'] as String?
        ..color = int.tryParse('${m['color'] ?? ''}'.replaceFirst('#', 'FF'), radix: 16);
    }).toList();
    for (final c in cats) {
      if (c.color != null) {
        for (final d in c.cards) {
          d.tint = c.color;
        }
      }
    }
    groups = {};
    ((j['groups'] as Map?) ?? const {}).forEach((k, v) {
      final g = v as Map;
      groups['$k'] = (icon: '${g['icon']}', labels: Map<String, dynamic>.from(g['label'] as Map));
    });
    await _loadImages();
    await _loadExtra('world');
    await _loadExtra('nba');
  }

  /// Optional big categories built from Wikidata in CI (assets/data/<id>.json + <id>_meta.json).
  static Future<void> _loadExtra(String id) async {
    try {
      final meta = jsonDecode(await rootBundle.loadString('assets/data/${id}_meta.json')) as Map<String, dynamic>;
      final data = jsonDecode(await rootBundle.loadString('assets/data/$id.json')) as Map<String, dynamic>;
      final list = (data['cards'] as List?) ?? [];
      if (list.length < 30) return;
      final attrs = (meta['attrs'] as List)
          .map((a) => Attr(a['key'] as String, Map<String, dynamic>.from(a['q'] as Map)))
          .toList();
      final cards = list.map((d) {
        final dm = d as Map<String, dynamic>;
        final c = CardItem('$id.${dm['id']}', '${dm['emoji']}', '${dm['en']}',
            Map<String, dynamic>.from(dm['name'] as Map), (dm['flags'] as List).map((e) => '$e').toSet());
        final img = dm['img'];
        if (img is String && img.startsWith('assets/')) c.img = img;
        c.alias = ((dm['aliases'] as List?) ?? const []).map((e) => '$e').toList();
        return c;
      }).toList();
      final cat = Cat(id, '${meta['icon']}', Map<String, dynamic>.from(meta['label'] as Map), true, attrs, cards)
        ..group = meta['group'] as String?;
      final at = cats.lastIndexWhere((c) => c.group != null && c.group == cat.group);
      final p = at >= 0 ? at : cats.indexWhere((c) => c.id == 'players');
      cats.insert(p < 0 ? cats.length : p + 1, cat);
    } catch (_) {}
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
