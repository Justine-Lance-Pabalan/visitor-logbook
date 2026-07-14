import 'package:flutter/material.dart';
import '../utils/colors.dart';

class DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const DetailChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: bsuRed),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}