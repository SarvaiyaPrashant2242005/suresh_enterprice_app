class GstMaster {
  final int? id;
  final String hsnCode;
  final double cgst;
  final double sgst;
  final double igst;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GstMaster({
    this.id,
    required this.hsnCode,
    required this.cgst,
    required this.sgst,
    required this.igst,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory GstMaster.fromJson(Map<String, dynamic> json) {
    return GstMaster(
      id: json['id'],
      hsnCode: json['hsn_code'],
      cgst: json['cgst'] is int ? (json['cgst'] as int).toDouble() : json['cgst'],
      sgst: json['sgst'] is int ? (json['sgst'] as int).toDouble() : json['sgst'],
      igst: json['igst'] is int ? (json['igst'] as int).toDouble() : json['igst'],
      description: json['description'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'hsn_code': hsnCode,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }
}