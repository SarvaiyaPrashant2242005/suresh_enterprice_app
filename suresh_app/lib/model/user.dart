class User {
  final int? id;
  final String name;
  final String email;
  final String? password;
  final String? phone;
  final String? userType;
  final int? companyId;
  final String? status;
  final bool withGst;
  final bool withoutGst;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.phone,
    this.userType = 'Customer User',
    this.companyId,
    this.status,
    this.withGst = true,
    this.withoutGst = false,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      userType: json['userType'],
      companyId: json['companyId'],
      status: json['status'],
      withGst: json['withGst'] ?? true,
      withoutGst: json['withoutGst'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      if (password != null) 'password': password,
      if (phone != null) 'phone': phone,
      if (userType != null) 'userType': userType,
      if (companyId != null) 'companyId': companyId,
      if (status != null) 'status': status,
      'withGst': withGst,
      'withoutGst': withoutGst,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? userType,
    int? companyId,
    String? status,
    bool? withGst,
    bool? withoutGst,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      companyId: companyId ?? this.companyId,
      status: status ?? this.status,
      withGst: withGst ?? this.withGst,
      withoutGst: withoutGst ?? this.withoutGst,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}