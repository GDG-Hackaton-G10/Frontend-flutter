class Medication {
  Medication({
    required this.name,
    this.dose,
    this.frequency,
    this.quantity,
    this.instructions,
  });

  final String name;
  final String? dose;
  final String? frequency;
  final int? quantity;
  final String? instructions;

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    name: json['name'] as String? ?? '',
    dose: json['dose'] as String?,
    frequency: json['frequency'] as String?,
    quantity: json['quantity'] is int
        ? json['quantity'] as int
        : (json['quantity'] != null
              ? int.tryParse(json['quantity'].toString())
              : null),
    instructions: json['instructions'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'dose': dose,
    'frequency': frequency,
    'quantity': quantity,
    'instructions': instructions,
  };
}

class Prescription {
  Prescription({
    required this.id,
    required this.userId,
    required this.medications,
    required this.createdAt,
    this.expiresAt,
    this.notes,
    this.status,
  });

  final String id;
  final String userId;
  final List<Medication> medications;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? notes;
  final String? status;

  factory Prescription.fromJson(Map<String, dynamic> json) {
    final meds = <Medication>[];
    final medsJson = json['medications'] as List<dynamic>?;
    if (medsJson != null) {
      meds.addAll(
        medsJson.map((e) => Medication.fromJson(e as Map<String, dynamic>)),
      );
    } else {
      // try alternative keys
      final alt = json['items'] as List<dynamic>?;
      if (alt != null) {
        meds.addAll(
          alt.map((e) => Medication.fromJson(e as Map<String, dynamic>)),
        );
      }
    }

    DateTime parseDate(Object? v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }

    return Prescription(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user']?.toString() ?? '',
      medications: meds,
      createdAt: parseDate(json['createdAt'] ?? json['date']),
      expiresAt: (json['expiresAt'] != null)
          ? parseDate(json['expiresAt'])
          : null,
      notes: json['notes'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'medications': medications.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'notes': notes,
    'status': status,
  };

  @override
  String toString() => 'Prescription($id, meds=${medications.length})';
}
