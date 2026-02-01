import 'parking_vehicle.dart';

extension VehicleScanVoice on ParkingVehicle {
  String get voiceMessage {
    switch (status) {
      case VehicleStatus.resident:
        return '등록된 입주 차량입니다.';
      case VehicleStatus.visit:
        return '방문 차량입니다';
      case VehicleStatus.illegal:
        return '미등록 차량입니다.';
    }
  }
}