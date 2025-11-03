class Invoice {
  final int? id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final int customerId;
  final String? customerName;
  final double totalAmount;
  final double? taxAmount;
  final double? discountAmount;
  final double netAmount;
  final String? status;
  final List<InvoiceItem>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerId,
    this.customerName,
    required this.totalAmount,
    this.taxAmount,
    this.discountAmount,
    required this.netAmount,
    this.status,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      customerId: json['customerId'],
      customerName: json['customerName'],
      totalAmount: json['totalAmount'] is int ? (json['totalAmount'] as int).toDouble() : json['totalAmount'],
      taxAmount: json['taxAmount'] != null ? (json['taxAmount'] is int ? (json['taxAmount'] as int).toDouble() : json['taxAmount']) : null,
      discountAmount: json['discountAmount'] != null ? (json['discountAmount'] is int ? (json['discountAmount'] as int).toDouble() : json['discountAmount']) : null,
      netAmount: json['netAmount'] is int ? (json['netAmount'] as int).toDouble() : json['netAmount'],
      status: json['status'],
      items: json['items'] != null ? (json['items'] as List).map((item) => InvoiceItem.fromJson(item)).toList() : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'customerId': customerId,
      'totalAmount': totalAmount,
      if (taxAmount != null) 'taxAmount': taxAmount,
      if (discountAmount != null) 'discountAmount': discountAmount,
      'netAmount': netAmount,
      if (status != null) 'status': status,
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
    };
  }
}

class InvoiceItem {
  final int? id;
  final int? invoiceId;
  final int productId;
  final String? productName;
  final int quantity;
  final double unitPrice;
  final double? taxRate;
  final double amount;

  InvoiceItem({
    this.id,
    this.invoiceId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    this.taxRate,
    required this.amount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      invoiceId: json['invoiceId'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'] is int ? (json['unitPrice'] as int).toDouble() : json['unitPrice'],
      taxRate: json['taxRate'] != null ? (json['taxRate'] is int ? (json['taxRate'] as int).toDouble() : json['taxRate']) : null,
      amount: json['amount'] is int ? (json['amount'] as int).toDouble() : json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoiceId': invoiceId,
      'productId': productId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      if (taxRate != null) 'taxRate': taxRate,
      'amount': amount,
    };
  }
}