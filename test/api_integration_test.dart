import 'package:flutter/material.dart';
import 'package:apt_parking_manager/screen/login/services/apartment_api.dart';
import 'package:apt_parking_manager/models/apartment.dart';

void main() async {
  // Flutter binding is required for ApiClient (which uses debugPrint)
  WidgetsFlutterBinding.ensureInitialized();
  
  final address = '대한민국 인천광역시 남동구 만수3동 844-7';
  print('Testing ApartmentApi.findByAddress with: $address');
  
  try {
    final apartment = await ApartmentApi.findByAddress(address);
    if (apartment != null) {
      print('SUCCESS: Found Apartment!');
      print('Name: ${apartment.name}');
      print('Code: ${apartment.code}');
      print('Address: ${apartment.address}');
      
      if (apartment.code == 'A0001') {
        print('VERIFIED: Code matches A0001');
      } else {
        print('WARNING: Code is ${apartment.code}, not A0001');
      }
    } else {
      print('FAILURE: Apartment not found');
    }
  } catch (e) {
    print('Error during ApartmentApi test: $e');
  }
}
