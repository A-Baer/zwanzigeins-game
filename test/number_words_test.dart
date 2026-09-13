import 'package:flutter_test/flutter_test.dart';
import 'package:zwanzigeins_game/domain/number_words.dart';

void main() {
  group('NumberWords.placeValue', () {
    test('builds representative numbers in place-value order', () {
      expect(NumberWords.placeValue(11), 'zehneins');
      expect(NumberWords.placeValue(12), 'zehnzwei');
      expect(NumberWords.placeValue(20), 'zwanzig');
      expect(NumberWords.placeValue(21), 'zwanzigeins');
      expect(NumberWords.placeValue(30), 'dreißig');
      expect(NumberWords.placeValue(46), 'vierzigsechs');
      expect(NumberWords.placeValue(67), 'sechzigsieben');
      expect(NumberWords.placeValue(98), 'neunzigacht');
    });

    test('creates every number from 0 through 99', () {
      for (int number = 0; number <= 99; number++) {
        expect(NumberWords.placeValue(number), isNotEmpty);
        expect(NumberWords.traditional(number), isNotEmpty);
      }
    });

    test('rejects numbers outside the implemented range', () {
      expect(() => NumberWords.placeValue(-1), throwsRangeError);
      expect(() => NumberWords.traditional(100), throwsRangeError);
    });
  });

  test('traditional words remain available for neutral comparisons', () {
    expect(NumberWords.traditional(11), 'elf');
    expect(NumberWords.traditional(21), 'einundzwanzig');
    expect(NumberWords.traditional(46), 'sechsundvierzig');
  });

  test('speakable direct words separate the place-value blocks', () {
    expect(NumberWords.speakable(46, SpeechMode.placeValue), 'vierzig sechs');
  });
}
