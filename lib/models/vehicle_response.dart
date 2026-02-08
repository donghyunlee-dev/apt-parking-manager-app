class VehicleResponse<T> {
  final String message;
  final T? data;

  VehicleResponse({
    required this.message,
    this.data,
  });

  factory VehicleResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return VehicleResponse(
      message: json['message'] ?? '',
      data: json.containsKey('payload') && json['payload'] != null
          ? fromJsonT(json['payload'])
          : null,
    );
  }
}