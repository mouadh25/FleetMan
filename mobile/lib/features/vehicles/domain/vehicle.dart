class Vehicle {
  final String id;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final int odometerKm;
  final String status;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.odometerKm,
    required this.status,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      plateNumber: json['plate_number'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      odometerKm: json['odometer_km'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'make': make,
      'model': model,
      'year': year,
      'odometer_km': odometerKm,
      'status': status,
    };
  }
}
