import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/status_models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:campus_alert_app/models/alert_model.dart';

/// Shown when the Disciplinary Body has confirmed one of the student's
/// alerts as a false alarm. States the fact, the consequence, and the
/// policy plainly — see Chapter One (Section 1.2) and Chapter Three
/// (Section 3.6) for the "state consequences at the point of decision"
/// rationale behind this screen's tone.
class StrikeNoticeScreen extends StatefulWidget {
  final String caseId;
  const StrikeNoticeScreen({super.key, required this.caseId});

  @override
  State<StrikeNoticeScreen> createState() => _StrikeNoticeScreenState();
}

class _StrikeNoticeScreenState extends State<StrikeNoticeScreen> {
  StrikeNotice? _notice;
  String? _error;
  bool _acknowledging = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    try {
      final notice = await ApiService.getStrikeNotice(token: user.token, caseId: widget.caseId);
      if (!mounted) return;
      setState(() => _notice = notice);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _acknowledge() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    setState(() => _acknowledging = true);
    try {
      await ApiService.acknowledgeStrike(token: user.token, caseId: widget.caseId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _acknowledging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _notice == null && _error == null
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.alert)))
                  : _buildContent(_notice!),
        ),
      ),
    );
  }

  Widget _buildContent(StrikeNotice n) {
    final filledSegments = n.strikeNumber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFFBEAE6), borderRadius: BorderRadius.circular(20)),
            child: Text('Case #${n.caseId}', style: const TextStyle(color: AppColors.alertDark, fontSize: 10.5)),
          ),
        ),
        const SizedBox(height: 18),
        const Text('This alert was marked as a false alarm.',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: AppColors.ink, height: 1.25)),
        const SizedBox(height: 10),
        Text(
          'The Disciplinary Body reviewed your ${_formatDate(n.alertDate)} alert '
          '(${n.category.label} — ${n.location}) and closed it as unconfirmed / hoax. '
          'This is recorded on your account.',
          style: const TextStyle(color: AppColors.inkSoft, fontSize: 11.5, height: 1.55),
        ),
        const SizedBox(height: 22),
        Row(
          children: List.generate(n.totalStrikes, (i) {
            final filled = i < filledSegments;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < n.totalStrikes - 1 ? 6 : 0),
                height: 8,
                decoration: BoxDecoration(
                  color: filled ? AppColors.gold : const Color(0xFFEDE8DC),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text('STRIKE ${n.strikeNumber} OF ${n.totalStrikes}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: AppColors.inkSoft)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.inkSoft, fontSize: 10.5, height: 1.55),
              children: [
                const TextSpan(text: 'What happens at 3 strikes: ', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold)),
                const TextSpan(text: 'your case is forwarded to the Student Disciplinary Committee for formal reprimand, per campus safety policy.'),
              ],
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _acknowledging ? null : _acknowledge,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.ink),
            child: _acknowledging
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Acknowledge'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
