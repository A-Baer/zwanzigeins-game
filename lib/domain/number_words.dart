enum SpeechMode { placeValue, traditional }

abstract final class NumberWords {
  static const Map<int, String> _ones = <int, String>{
    0: 'null',
    1: 'eins',
    2: 'zwei',
    3: 'drei',
    4: 'vier',
    5: 'fünf',
    6: 'sechs',
    7: 'sieben',
    8: 'acht',
    9: 'neun',
  };

  static const Map<int, String> _traditionalTeens = <int, String>{
    10: 'zehn',
    11: 'elf',
    12: 'zwölf',
    13: 'dreizehn',
    14: 'vierzehn',
    15: 'fünfzehn',
    16: 'sechzehn',
    17: 'siebzehn',
    18: 'achtzehn',
    19: 'neunzehn',
  };

  static const Map<int, String> _tens = <int, String>{
    2: 'zwanzig',
    3: 'dreißig',
    4: 'vierzig',
    5: 'fünfzig',
    6: 'sechzig',
    7: 'siebzig',
    8: 'achtzig',
    9: 'neunzig',
  };

  static String placeValue(int number) {
    _validate(number);
    if (number < 10) return _ones[number]!;
    if (number == 10) return 'zehn';
    if (number < 20) return 'zehn${_ones[number % 10]}';

    final int tens = number ~/ 10;
    final int ones = number % 10;
    return '${_tens[tens]}${ones == 0 ? '' : _ones[ones]}';
  }

  static String traditional(int number) {
    _validate(number);
    if (number < 10) return _ones[number]!;
    if (number < 20) return _traditionalTeens[number]!;

    final int tens = number ~/ 10;
    final int ones = number % 10;
    if (ones == 0) return _tens[tens]!;

    final String oneWord = ones == 1 ? 'ein' : _ones[ones]!;
    return '${oneWord}und${_tens[tens]}';
  }

  static String speakable(int number, SpeechMode mode) {
    return mode == SpeechMode.placeValue
        ? _spacedPlaceValue(number)
        : traditional(number);
  }

  static String _spacedPlaceValue(int number) {
    if (number <= 10 || number % 10 == 0) return placeValue(number);
    if (number < 20) return 'zehn ${_ones[number % 10]}';
    return '${_tens[number ~/ 10]} ${_ones[number % 10]}';
  }

  static List<String> placeValueParts(int number) {
    _validate(number);
    if (number < 10) return <String>[_ones[number]!];
    if (number == 10) return const <String>['zehn'];
    if (number < 20) return <String>['zehn', _ones[number % 10]!];

    final List<String> parts = <String>[_tens[number ~/ 10]!];
    if (number % 10 != 0) parts.add(_ones[number % 10]!);
    return parts;
  }

  static void _validate(int number) {
    if (number < 0 || number > 99) {
      throw RangeError.range(number, 0, 99, 'number');
    }
  }
}
