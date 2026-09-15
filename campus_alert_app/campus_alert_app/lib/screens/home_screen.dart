import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/sos_button.dart';
import 'category_screen.dart';
import 'alert_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.ink),
            tooltip: 'Your Alerts',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AlertHistoryScreen()),
            ),
          ),
        ],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.fullName ?? 'Student',
                    style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 16)),
                Text(user?.matricNumber ?? '',
                    style: const TextStyle(color: AppColors.inkSoft, fontSize: 11)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(4)),
              child: const Text('Verified', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFE9F3EE), borderRadius: BorderRadius.circular(20)),
                  child: const Text('● No active alert', style: TextStyle(color: AppColors.safe, fontSize: 10)),
                ),
              ),
              const Spacer(),
              SosButton(
                onTriggered: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoryScreen()),
                  );
                },
              ),
              const SizedBox(height: 18),
              const Text(
                "A 3-second hold prevents accidental taps.\nYou'll get a 10s window to cancel next.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkSoft, fontSize: 11, height: 1.4),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(child: _quickCard('CLINIC', 'Call')),
                  const SizedBox(width: 10),
                  Expanded(child: _quickCard('SECURITY', 'Call')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickCard(String label, String action) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkSoft, fontSize: 9)),
          const SizedBox(height: 4),
          Text(action, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
