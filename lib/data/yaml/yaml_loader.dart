import 'package:flutter/services.dart';

class YamlLoader {
  const YamlLoader();

  Future<String> fromAsset(String assetPath) {
    return rootBundle.loadString(assetPath);
  }

  String fromRaw(String raw) => raw;
}
