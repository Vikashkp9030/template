import 'address_model.dart';

class CustomerModel {
  const CustomerModel({
    required this.name,
    this.phone,
    this.email,
    this.gstin,
    this.billingAddress,
    this.shippingAddress,
  });

  final String name;
  final String? phone;
  final String? email;
  final String? gstin;
  final AddressModel? billingAddress;
  final AddressModel? shippingAddress;
}
