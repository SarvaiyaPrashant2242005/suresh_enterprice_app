class CompanyProfile {
  final int? id;
  final String companyName;
  final String? address;
  final String? phone;
  final String? email;
  final String? gstNumber;
  final String? companyLogo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CompanyProfile({
    this.id,
    required this.companyName,
    this.address,
    this.phone,
    this.email,
    this.gstNumber,
    this.companyLogo,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      id: json['id'],
      companyName: json['companyName'] ?? json['name'] ?? '',
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      gstNumber: json['gstNumber'],
      companyLogo: json['companyLogo'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'companyName': companyName,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (gstNumber != null) 'gstNumber': gstNumber,
    };
  }
}