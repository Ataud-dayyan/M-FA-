/// The four alert categories, and which authority each one is routed to.
/// This mirrors the routing shown on the "Choose Category" screen.
enum AlertCategory { medical, security, fire, other }

extension AlertCategoryX on AlertCategory {
  String get label {
    switch (this) {
      case AlertCategory.medical:
        return 'Medical';
      case AlertCategory.security:
        return 'Security / Safety threat';
      case AlertCategory.fire:
        return 'Fire / Hazard';
      case AlertCategory.other:
        return 'Other';
    }
  }

  String get routedTo {
    switch (this) {
      case AlertCategory.medical:
        return 'School Clinic';
      case AlertCategory.security:
        return 'Disciplinary Body';
      case AlertCategory.fire:
        return 'Security + Clinic';
      case AlertCategory.other:
        return 'Disciplinary Body';
    }
  }

  String get apiValue => name; // 'medical' | 'security' | 'fire' | 'other'
}

class EmergencyAlert {
  final AlertCategory category;
  final double latitude;
  final double longitude;
  final DateTime triggeredAt;

  EmergencyAlert({
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.triggeredAt,
  });

  Map<String, dynamic> toJson() => {
        'category': category.apiValue,
        'latitude': latitude,
        'longitude': longitude,
        'triggeredAt': triggeredAt.toIso8601String(),
      };
}
