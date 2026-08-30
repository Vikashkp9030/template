class MapReader {
  const MapReader(this.data);

  final Map<dynamic, dynamic> data;

  Map<dynamic, dynamic>? optionalMap(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is Map) return value;
    throw FormatException('Expected map for "$key"');
  }

  Map<dynamic, dynamic> requireMap(String key) {
    final value = optionalMap(key);
    if (value == null) throw FormatException('Missing "$key"');
    return value;
  }

  String? optionalString(String key) {
    final value = data[key];
    if (value == null) return null;
    return value.toString();
  }

  String requireString(String key) {
    final value = optionalString(key);
    if (value == null || value.trim().isEmpty) {
      throw FormatException('Missing "$key"');
    }
    return value.trim();
  }

  num? optionalNum(String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  num requireNum(String key) {
    final value = optionalNum(key);
    if (value == null) throw FormatException('Missing number "$key"');
    return value;
  }

  bool optionalBool(String key, {bool fallback = false}) {
    final value = data[key];
    if (value == null) return fallback;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  List<dynamic> optionalList(String key) {
    final value = data[key];
    if (value == null) return const [];
    if (value is List) return value;
    throw FormatException('Expected list for "$key"');
  }
}
