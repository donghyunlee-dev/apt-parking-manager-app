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
      aptCode: json['aptCode'],
      vehicleNo: json['vehicleNo'],
      bdId: json['bdId'],
      bdUnit: json['bdUnit'],
      phone: json['phone'],
      visitDate: json['visitDate'],
      visitTime: json['visitTime'],
      visitCloseDate: json['visitCloseDate'],
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