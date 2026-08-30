import 'address_model.dart';

class CompanyModel {
  const CompanyModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.gstin,
    this.vatNumber,
    this.website,
    this.logoLabel,
  });

  final String name;
  final String phone;
  final String email;
  final AddressModel address;
  final String? gstin;
  final String? vatNumber;
  final String? website;
  final String? logoLabel;

  String get initials {
    final parts = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }
}
