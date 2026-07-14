import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SuccessDialog extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? extra;

  const SuccessDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.extra,
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: bsuRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: bsuWhite, size: 50),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: bsuRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            if (widget.extra != null) ...[
              const SizedBox(height: 20),
              widget.extra!,
            ],
            const SizedBox(height: 16),
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: bsuGold,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}