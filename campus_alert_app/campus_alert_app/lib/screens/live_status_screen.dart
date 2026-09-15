import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/status_models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

/// Shows the live progress of a sent alert: responder assignment,
/// a simple timeline, and quick actions to call or message the
/// responder. Polls the backend every few seconds rather than
/// requiring a manual refresh, since a student watching this screen
/// is very likely still mid-emergency.
class LiveStatusScreen extends StatefulWidget {
  final String alertId;
  final String routedTo; // e.g. "School Clinic"

  const LiveStatusScreen({super.key, required this.alertId, required this.routedTo});

  @override
  State<LiveStatusScreen> createState() => _LiveStatusScreenState();
}

class _LiveStatusScreenState extends State<LiveStatusScreen> {
  AlertStatus? _status;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetch();
    // Poll every 5 seconds until the alert reaches a terminal state.
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
  }

  Future<void> _fetch() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    try {
      final status = await ApiService.getAlertStatus(token: user.token, alertId: widget.alertId);
      if (!mounted) return;
      setState(() {
        _status = status;
        _error = null;
      });
      if (status.isResolved || status.isFalseAlarm) {
        _pollTimer?.cancel();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _callResponder() async {
    // Placeholder tel: URI — a production build would use the responder's
    // actual assigned number returned by the backend.
    final uri = Uri.parse('tel:0000000000');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Alert Status', style: TextStyle(color: AppColors.ink, fontSize: 16)),
      ),
      body: _status == null && _error == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A live map is out of scope for this prototype; a
                    // placeholder panel keeps the layout matching the
                    // Chapter One mockup without pulling in a maps SDK.
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F2EC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Center(
                        child: Text('Location shared with responder',
                            style: TextStyle(color: AppColors.inkSoft, fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: AppColors.alert, fontSize: 12.5))
                    else ...[
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: _status!.isResolved ? AppColors.safe : AppColors.alert,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _status!.isResolved ? 'Resolved' : (_status!.responderName != null ? 'Responder en route' : 'Awaiting responder'),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.ink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.routedTo + (_status!.etaMinutes != null ? ' · ETA ${_status!.etaMinutes} min' : ''),
                        style: const TextStyle(color: AppColors.inkSoft, fontSize: 11),
                      ),
                      const SizedBox(height: 20),
                      ..._status!.timeline.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    color: t.isDone ? AppColors.safe : AppColors.ink,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t.label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                                      Text(t.at?.toString() ?? 'pending',
                                          style: const TextStyle(fontSize: 9, color: AppColors.inkSoft)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _callResponder,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.ink),
                              child: const Text('Call Responder'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: null, // messaging out of scope for this prototype
                              child: const Text('Message'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
