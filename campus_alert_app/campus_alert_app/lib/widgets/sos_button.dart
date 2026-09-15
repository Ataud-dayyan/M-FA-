import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A press-and-hold control: the student must hold for [holdDuration]
/// before [onTriggered] fires. This is the first of two deliberate
/// friction points that cut down accidental/hoax alerts (the second is
/// the cancellable countdown on the confirm screen).
class SosButton extends StatefulWidget {
  final VoidCallback onTriggered;
  final Duration holdDuration;

  const SosButton({
    super.key,
    required this.onTriggered,
    this.holdDuration = const Duration(seconds: 3),
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _completionTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.holdDuration);
  }

  void _startHold() {
    _controller.forward(from: 0);
    _completionTimer = Timer(widget.holdDuration, () {
      widget.onTriggered();
      _controller.reset();
    });
  }

  void _cancelHold() {
    _completionTimer?.cancel();
    _controller.reverse();
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _cancelHold(),
      onLongPressCancel: _cancelHold,
      child: Container(
        width: 180,
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFDCD5C4), width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 4,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation(Colors.white70),
                  ),
                );
              },
            ),
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.alert,
                boxShadow: [
                  BoxShadow(color: Color(0x8CD8432B), blurRadius: 24, offset: Offset(0, 12)),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('HOLD',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1)),
                  SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text('PRESS 3 SEC TO SEND ALERT',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 8.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
