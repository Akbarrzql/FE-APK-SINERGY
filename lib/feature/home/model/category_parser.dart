List<String> parseCategoryList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }
  final text = value.toString().trim();
  if (text.isEmpty) return [];
  if (text.startsWith('[') && text.endsWith(']')) {
    final cleaned = text.substring(1, text.length - 1);
    return cleaned
        .split(',')
        .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return [text];
}

