class Normalizer {
  final Map<String, String> substitutions = {
    '-': ' ',
    '–': ' ',
    '&': ' and ',
    '^the ': '',
    '^a ': '',
  };

  String normalize(String field) {
    String normalizedField = field;

    substitutions.forEach((pattern, replacement) {
      normalizedField = normalizedField.replaceAll(RegExp(pattern, caseSensitive: false), replacement);
    });

    normalizedField = normalizedField.replaceAll(RegExp(r'[^\w\s]'), '');

    return normalizedField.split(' ').where((s) => s.isNotEmpty).join(' ').toLowerCase();
  }
}

class ArtistNormalizer extends Normalizer {
  @override
  String normalize(String field) {
    final parts = field.split(',');
    if (parts.length > 1) {
      field = '${parts[1].trim()} ${parts[0].trim()}';
    }
    return super.normalize(field);
  }
}

class AlbumNormalizer extends Normalizer {
  @override
  String normalize(String field) {
    field = field.replaceAll(RegExp(r' \([\(\[{]disc [\d|I|V|X]+[}\)\]]', caseSensitive: false), '');
    return super.normalize(field);
  }
}