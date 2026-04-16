/// Domain model for an Audit (eDVIR) entity.
/// Represents a pre-trip or post-trip vehicle inspection.
class Audit {
  final String id;
  final String vehicleId;
  final String inspectorId;
  final int odometerKm;
  final String? damageNotes;
  final bool passFail;
  final List<String> photoUrls;
  final Map<String, ChecklistItem> checklist;
  final DateTime createdAt;

  const Audit({
    required this.id,
    required this.vehicleId,
    required this.inspectorId,
    required this.odometerKm,
    this.damageNotes,
    required this.passFail,
    required this.photoUrls,
    required this.checklist,
    required this.createdAt,
  });

  factory Audit.fromJson(Map<String, dynamic> json) {
    final checklistJson = json['checklist'] as Map<String, dynamic>? ?? {};
    final checklist = checklistJson.map(
      (key, value) =>
          MapEntry(key, ChecklistItem.fromJson(value as Map<String, dynamic>)),
    );

    return Audit(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      inspectorId: json['inspector_id'] as String,
      odometerKm: json['odometer_km'] as int,
      damageNotes: json['damage_notes'] as String?,
      passFail: json['pass_fail'] as bool,
      photoUrls: (json['photo_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      checklist: checklist,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'inspector_id': inspectorId,
      'odometer_km': odometerKm,
      'damage_notes': damageNotes,
      'pass_fail': passFail,
      'photo_urls': photoUrls,
      'checklist': checklist.map((key, value) => MapEntry(key, value.toJson())),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a new audit with a generated UUID and current timestamp.
  factory Audit.create({
    required String vehicleId,
    required String inspectorId,
    required int odometerKm,
    String? damageNotes,
    required bool passFail,
    required List<String> photoUrls,
    required Map<String, ChecklistItem> checklist,
  }) {
    return Audit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleId: vehicleId,
      inspectorId: inspectorId,
      odometerKm: odometerKm,
      damageNotes: damageNotes,
      passFail: passFail,
      photoUrls: photoUrls,
      checklist: checklist,
      createdAt: DateTime.now(),
    );
  }
}

/// Represents a single checklist item in the eDVIR form.
class ChecklistItem {
  final String name;
  final bool passed;
  final String? notes;

  const ChecklistItem({
    required this.name,
    required this.passed,
    this.notes,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      name: json['name'] as String,
      passed: json['passed'] as bool,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'passed': passed,
      'notes': notes,
    };
  }

  ChecklistItem copyWith({
    String? name,
    bool? passed,
    String? notes,
  }) {
    return ChecklistItem(
      name: name ?? this.name,
      passed: passed ?? this.passed,
      notes: notes ?? this.notes,
    );
  }
}

/// Standard eDVIR checklist item keys.
class AuditChecklist {
  static const String tires = 'tires';
  static const String lights = 'lights';
  static const String fluids = 'fluids';
  static const String mirrors = 'mirrors';
  static const String odometer = 'odometer';

  static const List<String> all = [tires, lights, fluids, mirrors, odometer];
}
