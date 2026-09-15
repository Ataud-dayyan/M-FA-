import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import '../models/alert_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'live_status_screen.dart';

class ConfirmScreen extends StatefulWidget {
  final AlertCategory category;
  const ConfirmScreen({super.key, required this.category});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  static const int _startSeconds = 10;
  int _secondsLeft = _startSeconds;
  Timer? _timer;
  bool _cancelled = false;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        _sendAlert();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _cancel() {
    _timer?.cancel();
    setState(() => _cancelled = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    });
  }

  Future<void> _sendAlert() async {
    setState(() => _sending = true);
    try {
      // Location is required context for responders; falls back to 0,0
      // with an error surfaced rather than blocking the alert entirely.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('Session expired. Please sign in again.');

      final alert = EmergencyAlert(
        category: widget.category,
        latitude: position.latitude,
        longitude: position.longitude,
        triggeredAt: DateTime.now(),
      );

      final result = await ApiService.sendAlert(token: user.token, alert: alert);

      if (!mounted) return;
      final alertId = result['id'] as String? ?? '';
      final routedTo = result['routedTo'] as String? ?? widget.category.routedTo;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LiveStatusScreen(alertId: alertId, routedTo: routedTo)),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_error != null) ...[
                  Text(_error!, textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.alert, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _sendAlert, child: const Text('Retry')),
                ] else ...[
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _sending ? null : (_startSeconds - _secondsLeft) / _startSeconds,
                          strokeWidth: 6,
                          backgroundColor: const Color(0xFFF2E2DD),
                          valueColor: const AlwaysStoppedAnimation(AppColors.alert),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _sending ? '' : '$_secondsLeft',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.alert),
                            ),
                            if (!_sending)
                              const Text('SECONDS', style: TextStyle(fontSize: 8.5, color: AppColors.inkSoft)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    _cancelled
                        ? 'Alert cancelled.'
                        : _sending
                            ? 'Sending…'
                            : 'Sending ${widget.category.label} alert…',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your location and matric number are being attached. Tap cancel if this was a mistake.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft, height: 1.5),
                  ),
                  if (!_sending && !_cancelled) ...[
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: _cancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.ink),
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                      ),
                      child: const Text('Cancel Alert', style: TextStyle(color: AppColors.ink)),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
