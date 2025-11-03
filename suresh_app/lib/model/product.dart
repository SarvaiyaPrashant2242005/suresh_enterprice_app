class Product {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final int? categoryId;
  final String? categoryName;
  final String? hsnCode;
  final String? uom;
  final bool? isActive;
  final int? companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.categoryId,
    this.categoryName,
    this.hsnCode,
    this.uom = 'PCS',
    this.isActive,
    this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: (json['productName'] ?? json['name']) as String? ?? '', // Accept both keys
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: (json['category_id'] ?? json['categoryId']) as int?,
      categoryName: json['categoryName'] as String? ?? (json['Category']?['name'] as String?),
      hsnCode: json['hsnCode'] as String? ?? json['hsn_code'] as String?,
      uom: (json['uom'] ?? json['uom_code']) as String? ?? '',
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool?,
      companyId: (json['company_id'] ?? json['companyId']) as int?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      // Provide both client and server expected keys
      'name': name,
      'productName': name,
      if (description != null) 'description': description,
      'price': price,
      if (categoryId != null) 'categoryId': categoryId,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'categoryName': categoryName,
      if (hsnCode != null) 'hsnCode': hsnCode,
      if (hsnCode != null) 'hsn_code': hsnCode,
      'uom': uom,
      if (isActive != null) 'isActive': isActive,
      if (companyId != null) 'companyId': companyId,
      if (companyId != null) 'company_id': companyId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}