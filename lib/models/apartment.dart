class Apartment {
    final String code;
    final String name;
    final String address;
    final int buildingCount;
    final int residentCount;
     

    Apartment({
        required this.code,
        required this.name,
        required this.address,
        required this.buildingCount,
        required this.residentCount,
    });

    factory Apartment.fromJson(Map<String, dynamic> json) {
        return Apartment(
            code: json['code'],
            name: json['name'],
            address: json['address'],
            buildingCount: json['building_count'],
            residentCount: json['resident_count'],
             
        );
    }
}