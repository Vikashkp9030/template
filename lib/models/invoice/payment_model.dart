class BankDetails {
  const BankDetails({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.ifsc,
    this.upi,
  });

  final String bankName;
  final String accountName;
  final String accountNumber;
  final String ifsc;
  final String? upi;
}

class PaymentInfo {
  const PaymentInfo({
    required this.method,
    this.status = 'unpaid',
    this.paidAmount = 0,
    this.changeAmount = 0,
  });

  final String method;
  final String status;
  final double paidAmount;
  final double changeAmount;
}
