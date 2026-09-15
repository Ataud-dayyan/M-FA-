import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_user.dart';
import '../models/alert_model.dart';
import '../models/status_models.dart';

/// Thin wrapper around the Node/Express REST API.
/// See API_CONTRACT.md for the full endpoint spec this expects the
/// backend to implement.
class ApiService {
  // Point this at your Express server. Use 10.0.2.2 instead of localhost
  // when testing on the Android emulator.
  static const String baseUrl = 'https://redesigned-lamp-979wwv794g7j2p499-4000.app.github.dev/';

  /// POST /api/auth/login
  /// Body: { matricNumber, password }
  /// Returns the signed-in AppUser (with auth token) on success.
  static Future<AppUser> login({
    required String matricNumber,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'matricNumber': matricNumber, 'password': password}),
    );

    if (res.statusCode == 200) {
      return AppUser.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      throw Exception('Incorrect matric number or password.');
    } else {
      throw Exception('Sign-in failed. Please try again.');
    }
  }

  /// POST /api/alerts
  /// Header: Authorization: Bearer <token>
  /// Body: EmergencyAlert.toJson()
  /// Returns the created alert's id + routing info.
  static Future<Map<String, dynamic>> sendAlert({
    required String token,
    required EmergencyAlert alert,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/alerts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(alert.toJson()),
    );

    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Could not send alert. Check your connection and try again.');
    }
  }

  /// GET /api/alerts/:id
  /// Used by the live-status screen to poll (or seed a socket connection).
  static Future<AlertStatus> getAlertStatus({
    required String token,
    required String alertId,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/alerts/$alertId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return AlertStatus.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } else {
      throw Exception('Could not load alert status.');
    }
  }

  /// GET /api/alerts?mine=true
  /// Returns the signed-in student's own alert history, most recent first.
  static Future<List<AlertHistoryItem>> getAlertHistory({
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/alerts?mine=true'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) => AlertHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Could not load alert history.');
    }
  }

  /// GET /api/strikes/:caseId
  /// Returns the details behind a single confirmed false-alarm strike,
  /// shown on the Strike Notice screen.
  static Future<StrikeNotice> getStrikeNotice({
    required String token,
    required String caseId,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/strikes/$caseId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return StrikeNotice.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } else {
      throw Exception('Could not load strike details.');
    }
  }

  /// POST /api/strikes/:caseId/acknowledge
  /// Records that the student has seen and acknowledged this strike.
  static Future<void> acknowledgeStrike({
    required String token,
    required String caseId,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/strikes/$caseId/acknowledge'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Could not acknowledge strike. Please try again.');
    }
  }
}
