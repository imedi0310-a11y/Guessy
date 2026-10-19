import 'package:flutter_test/flutter_test.dart';
import 'package:guessy/data.dart';
import 'package:guessy/free_ask.dart';

CardItem _c(String id, String ar, String en, [List<String> alias = const []]) =>
    CardItem(id, '⚽', en, {'ar': ar, 'en': en, 'fr': en, 'es': en, 'pt': en}, {})..alias = alias;

void main() {
  final vini = _c('v', 'فينيسيوس جونيور', 'Vinícius Júnior', ['Vini Jr.']);
  final cr7 = _c('c', 'كريستيانو رونالدو', 'Cristiano Ronaldo', ['CR7']);
  final r9 = _c('r', 'رونالدو', 'Ronaldo');
  final messi = _c('m', 'ليونيل ميسي', 'Lionel Messi');
  final mbappe = _c('k', 'كيليان مبابي', 'Kylian Mbappé');
  final cat = Cat('t', '⚽', {'ar': 'x'}, true, [
    Attr('bra', {'ar': 'هل هو برازيلي؟', 'en': 'Is he Brazilian?'}),
    Attr('real', {'ar': 'هل لعب في ريال مدريد؟', 'en': 'Did he play for Real Madrid?'}),
  ], [vini, cr7, r9, messi, mbappe]);

  List<String> m(String s) => matchCardNames(s, cat).map((c) => c.id).toList();

  test('typos and partial names find the player', () {
    expect(m('فنيسيوس'), ['v']);
    expect(m('فينيسيوس'), ['v']);
    expect(m('هل هو فنسيوس؟'), ['v']);
    expect(m('vinicius'), ['v']);
    expect(m('vinisius'), ['v']);
    expect(m('vini jr'), ['v']);
    expect(m('ميسي'), ['m']);
    expect(m('مسي'), isEmpty.or(equals(['m'])));
    expect(m('مبابي'), ['k']);
    expect(m('مبابى'), ['k']);
    expect(m('كريستيانو'), ['c']);
    expect(m('cr7'), ['c']);
    expect(m('كريستيانو رونالدو'), ['c']);
  });

  test('questions are not mistaken for names', () {
    expect(m('هل هو برازيلي؟'), isEmpty);
    expect(m('هل لعب في ريال مدريد'), isEmpty);
    expect(m('Is he Brazilian?'), isEmpty);
  });

  test('free questions: long sentences, dialect, synonyms, opposites', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await GameData.load();
    final celebs = GameData.cat('celebs').attrs;
    final world = GameData.cats.any((c) => c.id == 'world') ? GameData.cat('world').attrs : GameData.cat('players').attrs;
    final animals = GameData.cat('animals').attrs;
    String? q(String s, List<Attr> a) {
      final m = matchQuestion(s, a);
      return m == null ? null : '${m.attr.key}${m.not ? '!' : ''}';
    }

    expect(q('هل هاد الشخصية المشهورة حية', celebs), 'dead!');
    expect(q('هال هاد الشخصية المشهورة حية', celebs), 'dead!');
    expect(q('واش راهو عايش', celebs), 'dead!');
    expect(q('هل هذه الشخصية توفيت', celebs), 'dead');
    expect(q('هل مات', celebs), 'dead');
    expect(q('Is he still alive?', celebs), 'dead!');
    expect(q('هل هي امرأة', celebs), 'woman');
    expect(q('هل هو رجل', celebs), 'woman!');
    expect(q('هل هذا الشخص المشهور يغني', celebs), 'sing');
    expect(q('واش هو مغني راي', celebs), 'rai');
    expect(q('هل هو ممثل مشهور', celebs), 'act');
    expect(q('هل هذا الشخص جزائري', celebs), 'alg');
    expect(q('هل هذا اللاعب لعب في برشلونة', world), 'barca');
    expect(q('هل لعب لبرشلونة', world), 'barca');
    expect(q('واش لعب في البارصا', world), 'barca');
    expect(q('هل لعب في الدوري الإسباني', world), 'liga');
    expect(q('هل هو إسباني', world), 'esp');
    expect(q('هل هو حارس', world), 'gk');
    expect(q('هل هذا اللاعب فاز بالكرة الذهبية من قبل', world), 'bdo');
    expect(q('هل يعيش هذا الحيوان في البحر', animals), 's');
    expect(q('هل هذا الحيوان يطير', animals), 'fl');
    expect(q('هل لعب في الدوري', world), isNull); // too vague: which league?
  });

  test('guess list search is forgiving', () {
    expect(nameMatchesQuery(vini, 'فنيسيوس'), isTrue);
    expect(nameMatchesQuery(messi, 'فنيسيوس'), isFalse);
  });
}

extension on Matcher {
  Matcher or(Matcher other) => anyOf(this, other);
}
