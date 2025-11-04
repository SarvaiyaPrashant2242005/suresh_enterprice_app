class GstMaster {
  final int? id;
  final double gstRate;
  final double sgstRate;
  final double cgstRate;
  final double igstRate;
  final bool isActive;

  GstMaster({
    this.id,
    required this.gstRate,
    required this.sgstRate,
    required this.cgstRate,
    required this.igstRate,
    this.isActive = true,
  });

  factory GstMaster.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) {
        if (v.isEmpty) return 0.0;
        return double.tryParse(v) ?? 0.0;
      }
      return double.tryParse(v.toString()) ?? 0.0;
    }

    bool _toBool(dynamic v) {
      if (v == null) return true;
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) {
        if (v.isEmpty) return true;
        return v.toLowerCase() == 'true' || v == '1';
      }
      return true;
    }

    // Handle both camelCase and snake_case from API
    return GstMaster(
      id: json['id'],
      gstRate: _toDouble(json['gstRate'] ?? json['gst_rate']),
      sgstRate: _toDouble(json['sgstRate'] ?? json['sgst_rate']),
      cgstRate: _toDouble(json['cgstRate'] ?? json['cgst_rate']),
      igstRate: _toDouble(json['igstRate'] ?? json['igst_rate']),
      isActive: _toBool(json['isActive'] ?? json['is_active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'gstRate': gstRate,
      'sgstRate': sgstRate,
      'cgstRate': cgstRate,
      'igstRate': igstRate,
      'isActive': isActive,
    };
  }
}