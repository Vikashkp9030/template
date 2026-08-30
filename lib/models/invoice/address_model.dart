class AddressModel {
  const AddressModel({
    required this.line1,
    this.line2,
    this.city = '',
    this.state = '',
    this.country = 'India',
    this.pincode = '',
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
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (country.isNotEmpty) country,
      if (pincode.isNotEmpty) pincode,
    ];
    return parts.join(', ');
  }

  List<String> get lines {
    return [
      line1,
      if (line2 != null && line2!.isNotEmpty) line2!,
      [
        if (city.isNotEmpty) city,
        if (state.isNotEmpty) state,
        if (pincode.isNotEmpty) pincode,
      ].join(', '),
      if (country.isNotEmpty) country,
    ].where((e) => e.trim().isNotEmpty).toList();
  }
}
