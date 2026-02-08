class ResidentVehicle {
final String aptCode;
  final String vehicleNo;
  final String bdId;
  final String bdUnit;
  final String phone;
  final bool used;
  final String? createdId;
  final DateTime? createdAt;
  final String? updatedId;
  final DateTime? updatedAt;

  ResidentVehicle({
    required this.aptCode,
    required this.vehicleNo,
    required this.bdId,
    required this.bdUnit,
    required this.phone,
    required this.used,
    this.createdId,
    this.createdAt,
    this.updatedId,
    this.updatedAt
  });

  factory ResidentVehicle.fromJson(Map<String, dynamic> json) {
    return ResidentVehicle(
      aptCode: json['apt_code'] ?? '',
      vehicleNo: json['vehicle_no'] ?? '',
      bdId: json['bd_id'] ?? '',
      bdUnit: json['bd_unit'] ?? '',
      phone: json['phone'] ?? '',
      used: json['used'] == 'Y',
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