
class SearchedVehicle {
  final String type; // 'resident', 'visitor', or 'unregistered'
  final String vehicleNo;
  final String? bdId;
  final String? bdUnit;
  final String? phone;
  final String? memo;
  final DateTime? enterTime;
  final DateTime? exitTime;

  SearchedVehicle({
    required this.type,
    required this.vehicleNo,
    this.bdId,
    this.bdUnit,
    this.phone,
    this.memo,
    this.enterTime,
    this.exitTime,
  });

  factory SearchedVehicle.fromJson(Map<String, dynamic> json) {
    return SearchedVehicle(
      type: json['type'],
      vehicleNo: json['vehicle_no'],
      bdId: json['bd_id'],
      bdUnit: json['bd_unit'],
      phone: json['phone'],
      memo: json['memo'],
      enterTime: json['enter_time'] != null ? DateTime.parse(json['enter_time']) : null,
      exitTime: json['exit_time'] != null ? DateTime.parse(json['exit_time']) : null,
    );
  }
}
