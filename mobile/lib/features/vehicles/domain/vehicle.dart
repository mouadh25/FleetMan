/// Domain model for a Vehicle entity.
/// Mirrors the Supabase `vehicles` table schema.
/// Used as the single source of truth across all vehicle-related features.
class Vehicle {
  final String id;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final int odometerKm;
  final String status;
  final String fuelType;
  final String? vin;
  final String? assignedDriverId;
  final String? insuranceExpiry;
  final String? technicalInspectionExpiry;
  final String? circulationCardExpiry;
  final String? photoUrl;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.odometerKm,
    required this.status,
    required this.fuelType,
    this.vin,
    this.assignedDriverId,
    this.insuranceExpiry,
    this.technicalInspectionExpiry,
    this.circulationCardExpiry,
    this.photoUrl,
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
      fuelType: json['fuel_type'] as String? ?? 'diesel',
      vin: json['vin'] as String?,
      assignedDriverId: json['assigned_driver_id'] as String?,
      insuranceExpiry: json['insurance_expiry'] as String?,
      technicalInspectionExpiry: json['technical_inspection_expiry'] as String?,
      circulationCardExpiry: json['circulation_card_expiry'] as String?,
      photoUrl: json['photo_url'] as String?,
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
      'fuel_type': fuelType,
      'vin': vin,
      'assigned_driver_id': assignedDriverId,
      'insurance_expiry': insuranceExpiry,
      'technical_inspection_expiry': technicalInspectionExpiry,
      'circulation_card_expiry': circulationCardExpiry,
      'photo_url': photoUrl,
    };
  }
}
