import 'package:flutter/material.dart';

enum VehicleStatus {
  resident,
  visit,
  illegal;

  static VehicleStatus fromJson(String value) {
    switch (value) {
      case 'RESIDENT':
        return VehicleStatus.resident;
      case 'VISIT':
        return VehicleStatus.visit;
      case 'ILLEGAL':
        return VehicleStatus.illegal;
      default:
        throw ArgumentError('Unknown VehicleStatus: $value');
    }
  }
}

class ParkingVehicle {
  final String vehicleNo;
  final VehicleStatus status;
  final String info;

  ParkingVehicle({
    required this.vehicleNo,
    required this.status,
    required this.info,
  });

  factory ParkingVehicle.fromJson(Map<String, dynamic> json) {
    return ParkingVehicle(
      vehicleNo: json['vehicle_no'] as String,
      info: json['info'] as String,
      status: VehicleStatus.fromJson(json['status'] as String),
    );
  }

  String get statusText {
    switch (status) {
      case VehicleStatus.resident:
        return '입주 차량';
      case VehicleStatus.visit:
        return '방문 차량';
      case VehicleStatus.illegal:
        return '미등록 차량';
    }
  }

  IconData get icon {
    switch (status) {
      case VehicleStatus.resident:
        return Icons.check_circle;
      case VehicleStatus.visit:
        return Icons.directions_car;
      case VehicleStatus.illegal:
        return Icons.warning;
    }
  }

  Color get color {
    switch (status) {
      case VehicleStatus.resident:
        return Colors.green;
      case VehicleStatus.visit:
        return Colors.blue;
      case VehicleStatus.illegal:
        return Colors.red;
    }
  }
}
