
class SearchedVehicle {
  final String type; // 'RESIDENT', 'VISITOR', or 'UNREGISTERED'
  final String vehicleNo;
  final String? aptCode;
  final String? bdId;
  final String? bdUnit;
  final String? phone;
  final String? memo;

  SearchedVehicle({
    required this.type,
    required this.vehicleNo,
    this.aptCode,
    this.bdId,
    this.bdUnit,
    this.phone,
    this.memo,
  });

  factory SearchedVehicle.fromJson(Map<String, dynamic> json) {
    return SearchedVehicle(
      type: json['status'], // Map 'status' from API to 'type' in model
      vehicleNo: json['vehicle_no'],
      aptCode: json['apt_code'],
      bdId: json['bd_id'],
      bdUnit: json['bd_unit'],
      phone: json['phone'],
      memo: json['memo'],
    );
  }
}
