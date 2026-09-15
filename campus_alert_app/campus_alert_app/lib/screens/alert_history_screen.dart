import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/status_models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'strike_notice_screen.dart';
import 'package:campus_alert_app/models/alert_model.dart';

/// Every alert the student has ever raised, genuine or false — nothing
/// about the strike system is hidden after the fact (see Chapter One's
/// UI/UX rationale for this screen).
class AlertHistoryScreen extends StatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  List<AlertHistoryItem>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    try {
      final items = await ApiService.getAlertHistory(token: user.token);
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        title: const Text('Your Alerts', style: TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _error != null
              ? ListView(children: [
                  const SizedBox(height: 60),
                  Center(child: Text(_error!, style: const TextStyle(color: AppColors.alert))),
                ])
              : _items == null
                  ? const Center(child: CircularProgressIndicator())
                  : _items!.isEmpty
                      ? ListView(children: const [
                          SizedBox(height: 80),
                          Center(child: Text('No alerts yet.', style: TextStyle(color: AppColors.inkSoft))),
                        ])
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _items!.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) => _HistoryTile(item: _items![i]),
                        ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final AlertHistoryItem item;
  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final tagColor = item.isFalseAlarm ? AppColors.alertDark : AppColors.safe;
    final tagBg = item.isFalseAlarm ? const Color(0xFFFBEAE6) : const Color(0xFFE9F3EE);
    final tagText = item.isFalseAlarm ? 'FALSE ALARM' : (item.isResolved ? 'RESOLVED' : 'PENDING');

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: item.isFalseAlarm
          ? () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => StrikeNoticeScreen(caseId: item.id)),
              )
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(12)),
              child: Text(tagText, style: TextStyle(color: tagColor, fontSize: 9, fontFamily: 'monospace')),
            ),
            const SizedBox(height: 8),
            Text('${item.category.label} — ${item.location}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              _formatMeta(item),
              style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMeta(AlertHistoryItem item) {
    final d = item.createdAt;
    final date = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} · '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (item.isFalseAlarm && item.strikeNumber != null) {
      return '$date · STRIKE ${item.strikeNumber}/3';
    }
    return date;
  }
}
