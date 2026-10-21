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
    expect(q('هل هو اروبي', celebs), 'eur');
    expect(q('هل هو أوروبي', celebs), 'eur');
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
    expect(q('هل لعب في الدوري الاروبي', world), anyOf('eurl', isNull)); // never "is he European?"
    expect(q('هل هو لاعب كرة قدم من البرازيل', world), 'bra');
    // questions typed in a 1000-player category must stay questions
    if (GameData.cats.any((c) => c.id == 'world')) {
      final w = GameData.cat('world');
      for (final s in ['هل هو مهاجم أو جناح', 'هل هو حارس مرمى', 'هل لعب في الدوري الإنجليزي', 'هل هو إيطالي', 'هل فاز بالكرة الذهبية']) {
        matchCardNames(s, w);
        expect(lastNameScore, lessThan(10), reason: s);
        expect(matchQuestion(s, w.attrs), isNotNull, reason: s);
      }
    }

    final anime = GameData.cat('anime');
    expect(anime.id, 'anime');
    expect(q('هل هو من ناروتو', anime.attrs), 'naruto');
    expect(q('هل هذه الشخصية من ون بيس', anime.attrs), 'op');
    expect(q('واش يقاتل بالسيف', anime.attrs), 'sword');
    expect(q('هل هو شرير', anime.attrs), 'villain');
    List<String> n(String s) => matchCardNames(s, anime).map((c) => c.id).toList();
    expect(n('هل هو من ناروتو'), isEmpty); // series question, not a guess
    expect(n('هل هو من المحقق كونان'), isEmpty);
    expect(n('هل هو ناروتو'), ['anime.naruto']);
    expect(n('قوكو'), ['anime.goku']);
    expect(n('لوفي'), ['anime.luffy']);

    // anime modes
    final nar = GameData.cat('naruto').attrs;
    expect(q('هل هو من عشيرة الأوتشيها', nar), 'uchiha');
    expect(q('واش هو من الأكاتسوكي', nar), 'akatsuki');
    expect(q('هل عنده شارينغان', nar), 'sharingan');
    expect(q('هل هو أشقر', nar), 'blond');
    final pk = GameData.cat('pokemon').attrs;
    expect(q('هل هو ناري', pk), 'fire');
    expect(q('هل هو من نوع الماء', pk), 'water');
    expect(q('هل هو أسطوري', pk), 'legendary');
    final op = GameData.cat('onepiece').attrs;
    expect(q('هل أكل فاكهة الشيطان', op), 'fruit');
    expect(q('هل هو من طاقم قبعة القش', op), 'strawhat');
    expect(q('هل هو قائد فرقة', GameData.cat('bleach').attrs), 'captain');
    expect(q('هل هو من عصابة العناكب', GameData.cat('hxh').attrs), 'troupe');
    expect(q('هل هو من رابطة الأشرار', GameData.cat('mha').attrs), 'lov');
    expect(q('هل هو من المنظمة السوداء', GameData.cat('conan').attrs), 'bo');
    expect(q('هل هو قاتل تنانين', GameData.cat('fairytail').attrs), 'slayer');
    expect(q('هل هو من الثيران السوداء', GameData.cat('blackclover').attrs), 'bulls');
    expect(q('هل هو غول', GameData.cat('tokyoghoul').attrs), 'ghoul');
    expect(GameData.cats.where((c) => c.group == 'anime').length, greaterThanOrEqualTo(18));
    final ufc = GameData.cat('ufc').attrs;
    expect(q('هل كان بطلا', ufc), 'champ');
    expect(q('هل هو من الوزن الثقيل', ufc), 'hw');
    expect(GameData.cats.where((c) => c.group == 'sports').length, greaterThanOrEqualTo(2));
    expect(GameData.cats.where((c) => c.group == 'fight').length, 3);
    expect(q('هل دخل قاعة المشاهير', GameData.cat('wwe').attrs), 'hof');
    expect(q('هل يلبس قناع', GameData.cat('wwe').attrs), 'mask');
  });

  test('guess list search is forgiving', () {
    expect(nameMatchesQuery(vini, 'فنيسيوس'), isTrue);
    expect(nameMatchesQuery(messi, 'فنيسيوس'), isFalse);
  });
}

extension on Matcher {
  Matcher or(Matcher other) => anyOf(this, other);
}
