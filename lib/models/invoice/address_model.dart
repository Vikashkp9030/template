class AddressModel {
  const AddressModel({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String country;
  final String pincode;

  String get singleLine {
    final parts = [
      line1,
      if (line2 != null && line2!.isNotEmpty) line2,
      city,
      state,
      country,
      pincode,
    ];
    return parts.join(', ');
  }

  List<String> get lines => [
    line1,
    if (line2 != null && line2!.isNotEmpty) line2!,
    '$city, $state $pincode',
    country,
  ];
}
