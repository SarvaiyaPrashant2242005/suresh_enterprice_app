
class Customer {
  final int? id;
  final String customerName;
  final String? emailAddress;
  final String? contactNumber;
  final String? address;
  final String? gstNumber;
  final String? stateCode;
  final String? billingAddress;
  final String? shippingAddress;
  final double? openingBalance;
  final DateTime? openingDate;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? company_id;

  Customer({
    this.id,
    required this.customerName,
    this.emailAddress,
    this.contactNumber,
    this.address,
    this.gstNumber,
    this.stateCode,
    this.billingAddress,
    this.shippingAddress,
    this.openingBalance,
    this.openingDate,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.company_id,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerName: json['customerName'] ?? json['name'],
      emailAddress: json['emailAddress'] ?? json['email'],
      contactNumber: json['contactNumber'] ?? json['phone'],
      address: json['address'],
      gstNumber: json['gstNumber'],
      stateCode: json['stateCode'],
      billingAddress: json['billingAddress'],
      shippingAddress: json['shippingAddress'],
      openingBalance: json['openingBalance'] != null ? (json['openingBalance'] is double ? json['openingBalance'] : double.tryParse(json['openingBalance'].toString())) : null,
      openingDate: json['openingDate'] != null ? DateTime.tryParse(json['openingDate']) : null,
      isActive: json['isActive'] is bool ? json['isActive'] : (json['isActive'] == null ? null : json['isActive'].toString() == '1' || json['isActive'].toString().toLowerCase() == 'true'),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      company_id: json['company_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customerName': customerName,
      if (emailAddress != null) 'emailAddress': emailAddress,
      if (contactNumber != null) 'contactNumber': contactNumber,
      if (address != null) 'address': address,
      if (gstNumber != null) 'gstNumber': gstNumber,
      if (stateCode != null) 'stateCode': stateCode,
      if (billingAddress != null) 'billingAddress': billingAddress,
      if (shippingAddress != null) 'shippingAddress': shippingAddress,
      if (openingBalance != null) 'openingBalance': openingBalance,
      if (openingDate != null) 'openingDate': openingDate!.toIso8601String(),
      if (isActive != null) 'isActive': isActive,
      if (company_id != null) 'company_id': company_id,
    };
  }
}