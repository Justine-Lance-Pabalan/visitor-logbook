import 'package:flutter/material.dart';
import '../models/visitor.dart';
import 'detail_chip.dart';
import '../utils/colors.dart';

class VisitorCard extends StatelessWidget {
  final Visitor visitor;
  final String? status;
  final Color? statusColor;
  final bool showTimeOut;
  final bool showPin;
  final VoidCallback? onTimeOut;

  const VisitorCard({
    super.key,
    required this.visitor,
    this.status,
    this.statusColor,
    this.showTimeOut = false,
    this.showPin = false,
    this.onTimeOut,
  });

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = statusColor ?? Colors.blueGrey;
    final isTimedOut = visitor.timeOut != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Name + status chip ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    visitor.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: bsuRed,
                    ),
                  ),
                ),
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: chipColor, width: 1),
                    ),
                    child: Text(
                      status!,
                      style: TextStyle(
                        fontSize: 11,
                        color: chipColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            // ── SR Code ──
            Text(
              visitor.srCode,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const Divider(height: 16),

            // ── Details row 1 ──
            Row(
              children: [
                DetailChip(icon: Icons.school, label: visitor.department),
                const SizedBox(width: 8),
                DetailChip(icon: Icons.info_outline, label: visitor.purpose),
              ],
            ),

            const SizedBox(height: 8),

            // ── Details row 2 ──
            Row(
              children: [
                DetailChip(
                    icon: Icons.inventory_2_outlined,
                    label: visitor.propertyUsed),
                const SizedBox(width: 8),
                DetailChip(
                    icon: Icons.access_time,
                    label: "In: ${_formatTime(visitor.timeIn)}"),
              ],
            ),

            const SizedBox(height: 8),

            // ── Time out row ──
            Row(
              children: [
                DetailChip(
                  icon: Icons.logout,
                  label: isTimedOut
                      ? "Out: ${_formatTime(visitor.timeOut!)}"
                      : "Out: Still Active",
                ),
              ],
            ),

            // ── PIN row ──
            if (showPin) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  DetailChip(icon: Icons.pin, label: "PIN: ${visitor.pin}"),
                ],
              ),
            ],

            // ── Time Out Button ──
            if (showTimeOut) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: bsuWhite, size: 18),
                  label: const Text(
                    "Time Out",
                    style: TextStyle(
                        color: bsuWhite, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bsuRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1,
                  ),
                  onPressed: onTimeOut,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}