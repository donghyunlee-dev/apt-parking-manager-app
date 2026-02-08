class VisitorVehicle {
final String aptCode;
  final String vehicleNo;
  final String bdId;
  final String bdUnit;
  final String phone;
  final DateTime visitDate;
  final String visitTime;
  final DateTime visitCloseDate;
  final String? createdId;
  final DateTime? createdAt;
  final String? updatedId;
  final DateTime? updatedAt;

  VisitorVehicle({
    required this.aptCode,
    required this.vehicleNo,
    required this.bdId,
    required this.bdUnit,
    required this.phone,
    required this.visitDate,
    required this.visitTime,
    required this.visitCloseDate,
    this.createdId,
    this.createdAt,
    this.updatedId,
    this.updatedAt
  });

  factory VisitorVehicle.fromJson(Map<String, dynamic> json) {
    return VisitorVehicle(
      aptCode: json['apt_code'] ?? '',
      vehicleNo: json['vehicle_no'] ?? '',
      bdId: json['bd_id'] ?? '',
      bdUnit: json['bd_unit'] ?? '',
      phone: json['phone'] ?? '',
      visitDate: json['visit_date'] != null ? DateTime.parse(json['visit_date']) : DateTime.now(),
      visitTime: json['visit_time'] ?? '',
      visitCloseDate: json['visit_close_date'] != null ? DateTime.parse(json['visit_close_date']) : DateTime.now(),
      createdId: json['created_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedId: json['updated_id'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}   