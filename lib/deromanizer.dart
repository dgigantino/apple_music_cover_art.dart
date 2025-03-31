class DeRomanizer {
  final Map<String, int> romans = {
    'I': 1,
    'V': 5,
    'X': 10,
    'L': 50,
    'C': 100,
    'D': 500,
    'M': 1000,
    'IV': 4,
    'IX': 9,
    'XL': 40,
    'XC': 90,
    'CD': 400,
    'CM': 900
  };

  String convertWord(String word) {
    if (!RegExp(r"^[I|V|X|L|C|D|M]+$", caseSensitive: false).hasMatch(word)) {
      return word;
    }

    int i = 0;
    int num = 0;
    word = word.toUpperCase();
    while (i < word.length) {
      if (i + 1 < word.length && romans.containsKey(word.substring(i, i + 2))) {
        num += romans[word.substring(i, i + 2)]!;
        i += 2;
      } else {
        num += romans[word[i]]!;
        i += 1;
      }
    }
    return num.toString();
  }

  String convertAll(String field) {
    return field.split(' ').map((word) => convertWord(word)).join(' ');
  }
}