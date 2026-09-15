import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/alert_model.dart';
import 'confirm_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        title: const Text('Cancel', style: TextStyle(fontSize: 13, color: AppColors.inkSoft)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What's the emergency?",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: AppColors.ink)),
            const SizedBox(height: 6),
            const Text(
              'This routes your alert to the right responder and is recorded against your name.',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 11.5, height: 1.5),
            ),
            const SizedBox(height: 20),
            ...AlertCategory.values.map((c) => _CategoryTile(category: c)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF0DC),
                border: const Border(left: BorderSide(color: AppColors.gold, width: 3)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'False or hoax reports are logged to your student record. Three confirmed false alarms lead to disciplinary action.',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF6B5620), height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final AlertCategory category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ConfirmScreen(category: category)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: _dotColor(), borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('→ Routed to ${category.routedTo}',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.inkSoft)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _dotColor() {
    switch (category) {
      case AlertCategory.medical:
        return const Color(0xFFE9F3EE);
      case AlertCategory.security:
        return const Color(0xFFFBEAE6);
      case AlertCategory.fire:
        return const Color(0xFFFBF0DC);
      case AlertCategory.other:
        return const Color(0xFFEDEDED);
    }
  }
}
