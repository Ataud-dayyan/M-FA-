import 'alert_model.dart';

/// A single step in an alert's response timeline, shown on the
/// Live Status screen (e.g. "Alert received", "Responder assigned").
class TimelineEvent {
  final String label;
  final DateTime? at; // null means "pending" / not yet reached

  TimelineEvent({required this.label, this.at});

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      label: json['label'] as String,
      at: json['at'] != null ? DateTime.tryParse(json['at'] as String) : null,
    );
  }

  bool get isDone => at != null;
}

/// Full status of a single alert, returned by GET /api/alerts/:id and
/// rendered on the Live Status screen.
class AlertStatus {
  final String id;
  final String status; // received | responder_assigned | resolved | false_alarm
  final String? responderName;
  final int? etaMinutes;
  final List<TimelineEvent> timeline;

  AlertStatus({
    required this.id,
    required this.status,
    this.responderName,
    this.etaMinutes,
    this.timeline = const [],
  });

  factory AlertStatus.fromJson(Map<String, dynamic> json) {
    return AlertStatus(
      id: json['id'] as String,
      status: json['status'] as String,
      responderName: json['responderName'] as String?,
      etaMinutes: json['etaMinutes'] as int?,
      timeline: (json['timeline'] as List<dynamic>? ?? [])
          .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isResolved => status == 'resolved';
  bool get isFalseAlarm => status == 'false_alarm';
}

/// One row in the student's alert history list.
class AlertHistoryItem {
  final String id;
  final AlertCategory category;
  final String location;
  final String status; // resolved | false_alarm | pending
  final DateTime createdAt;
  final int? strikeNumber; // e.g. 2 (of 3), only set when status == false_alarm

  AlertHistoryItem({
    required this.id,
    required this.category,
    required this.location,
    required this.status,
    required this.createdAt,
    this.strikeNumber,
  });

  factory AlertHistoryItem.fromJson(Map<String, dynamic> json) {
    return AlertHistoryItem(
      id: json['id'] as String,
      category: AlertCategory.values.firstWhere(
        (c) => c.apiValue == json['category'],
        orElse: () => AlertCategory.other,
      ),
      location: json['location'] as String? ?? '',
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      strikeNumber: json['strikeNumber'] as int?,
    );
  }

  bool get isFalseAlarm => status == 'false_alarm';
  bool get isResolved => status == 'resolved';
}

/// Details behind a single confirmed false-alarm strike, shown on the
/// Strike Notice screen.
class StrikeNotice {
  final String caseId;
  final AlertCategory category;
  final String location;
  final DateTime alertDate;
  final int strikeNumber; // 1, 2, or 3
  final int totalStrikes; // always 3 in this system

  StrikeNotice({
    required this.caseId,
    required this.category,
    required this.location,
    required this.alertDate,
    required this.strikeNumber,
    this.totalStrikes = 3,
  });

  factory StrikeNotice.fromJson(Map<String, dynamic> json) {
    return StrikeNotice(
      caseId: json['caseId'] as String,
      category: AlertCategory.values.firstWhere(
        (c) => c.apiValue == json['category'],
        orElse: () => AlertCategory.other,
      ),
      location: json['location'] as String? ?? '',
      alertDate: DateTime.parse(json['alertDate'] as String),
      strikeNumber: json['strikeNumber'] as int,
      totalStrikes: json['totalStrikes'] as int? ?? 3,
    );
  }
}
