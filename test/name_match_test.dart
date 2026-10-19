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

  test('guess list search is forgiving', () {
    expect(nameMatchesQuery(vini, 'فنيسيوس'), isTrue);
    expect(nameMatchesQuery(messi, 'فنيسيوس'), isFalse);
  });
}

extension on Matcher {
  Matcher or(Matcher other) => anyOf(this, other);
}
