import 'package:suresh_app/model/company_profile.dart';
import 'package:suresh_app/model/customer.dart';
import 'package:suresh_app/model/product.dart';

class Invoice {
  final int? id;
  final String invoiceNumber;
  final String billNumber;
  final int customerId;
  final int companyProfileId;
  final int? userId;
  final String billDate;
  final String billYear;
  final String? deliveryAt;
  final String? transport;
  final String? lrNumber;
  final double totalAssesValue;
  final double sgstAmount;
  final double cgstAmount;
  final double igstAmount;
  final int gst;
  final double billValue;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Relations
  final Customer? customer;
  final CompanyProfile? companyProfile;
  final List<InvoiceItem>? invoiceItems;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.billNumber,
    required this.customerId,
    required this.companyProfileId,
    this.userId,
    required this.billDate,
    required this.billYear,
    this.deliveryAt,
    this.transport,
    this.lrNumber,
    required this.totalAssesValue,
    required this.sgstAmount,
    required this.cgstAmount,
    required this.igstAmount,
    required this.gst,
    required this.billValue,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.customer,
    this.companyProfile,
    this.invoiceItems,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      billNumber: json['billNumber']?.toString() ?? '',
      customerId: json['customerId'] is String 
          ? int.parse(json['customerId']) 
          : json['customerId'],
      companyProfileId: json['companyProfileId'] is String
          ? int.parse(json['companyProfileId'])
          : json['companyProfileId'],
      userId: json['user_id'],
      billDate: json['billDate']?.toString() ?? '',
      billYear: json['billYear']?.toString() ?? '',
      deliveryAt: json['deliveryAt']?.toString(),
      transport: json['transport']?.toString(),
      lrNumber: json['lrNumber']?.toString(),
      totalAssesValue: (json['totalAssesValue'] ?? 0).toDouble(),
      sgstAmount: (json['sgstAmount'] ?? 0).toDouble(),
      cgstAmount: (json['cgstAmount'] ?? 0).toDouble(),
      igstAmount: (json['igstAmount'] ?? 0).toDouble(),
      gst: json['gst'] ?? 0,
      billValue: (json['billValue'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      customer: json['Customer'] != null 
          ? Customer.fromJson(json['Customer']) 
          : null,
      companyProfile: json['CompanyProfile'] != null
          ? CompanyProfile.fromJson(json['CompanyProfile'])
          : null,
      invoiceItems: json['invoiceItems'] != null
          ? (json['invoiceItems'] as List)
              .map((item) => InvoiceItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'invoiceNumber': invoiceNumber,
      'billNumber': billNumber,
      'customerId': customerId,
      'companyProfileId': companyProfileId,
      if (userId != null) 'user_id': userId,
      'billDate': billDate,
      'billYear': billYear,
      if (deliveryAt != null) 'deliveryAt': deliveryAt,
      if (transport != null) 'transport': transport,
      if (lrNumber != null) 'lrNumber': lrNumber,
      'totalAssesValue': totalAssesValue,
      'sgstAmount': sgstAmount,
      'cgstAmount': cgstAmount,
      'igstAmount': igstAmount,
      'gst': gst,
      'billValue': billValue,
      'isActive': isActive,
    };
  }

  Invoice copyWith({
    int? id,
    String? invoiceNumber,
    String? billNumber,
    int? customerId,
    int? companyProfileId,
    int? userId,
    String? billDate,
    String? billYear,
    String? deliveryAt,
    String? transport,
    String? lrNumber,
    double? totalAssesValue,
    double? sgstAmount,
    double? cgstAmount,
    double? igstAmount,
    int? gst,
    double? billValue,
    bool? isActive,
    Customer? customer,
    CompanyProfile? companyProfile,
    List<InvoiceItem>? invoiceItems,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      billNumber: billNumber ?? this.billNumber,
      customerId: customerId ?? this.customerId,
      companyProfileId: companyProfileId ?? this.companyProfileId,
      userId: userId ?? this.userId,
      billDate: billDate ?? this.billDate,
      billYear: billYear ?? this.billYear,
      deliveryAt: deliveryAt ?? this.deliveryAt,
      transport: transport ?? this.transport,
      lrNumber: lrNumber ?? this.lrNumber,
      totalAssesValue: totalAssesValue ?? this.totalAssesValue,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      gst: gst ?? this.gst,
      billValue: billValue ?? this.billValue,
      isActive: isActive ?? this.isActive,
      customer: customer ?? this.customer,
      companyProfile: companyProfile ?? this.companyProfile,
      invoiceItems: invoiceItems ?? this.invoiceItems,
    );
  }
}

class InvoiceItem {
  final int? id;
  final int invoiceId;
  final int productId;
  final String? hsnCode;
  final String uom;
  final int quantity;
  final double rate;
  final double amount;
  final Product? product;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.productId,
    this.hsnCode,
    required this.uom,
    required this.quantity,
    required this.rate,
    required this.amount,
    this.product,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      invoiceId: json['invoiceId'],
      productId: json['productId'],
      hsnCode: json['hsnCode']?.toString(),
      uom: json['uom']?.toString() ?? '',
      quantity: json['quantity'] ?? 1,
      rate: (json['rate'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      product: json['product'] != null 
          ? Product.fromJson(json['product']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'invoiceId': invoiceId,
      'productId': productId,
      if (hsnCode != null) 'hsnCode': hsnCode,
      'uom': uom,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
    };
  }
}