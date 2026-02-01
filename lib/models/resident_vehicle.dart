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
      aptCode: json['aptCode'],
      vehicleNo: json['vehicleNo'],
      bdId: json['bdId'],
      bdUnit: json['bdUnit'],
      phone: json['phone'],
      used: json['used'],
      createdId: json['createdId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedId: json['updatedId'] != null
          ? json['updatedId']
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}   