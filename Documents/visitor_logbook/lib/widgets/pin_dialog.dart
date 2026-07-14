import 'package:flutter/material.dart';
import '../utils/colors.dart';

class PinDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final Future<void> Function(String pin) onConfirm;

  const PinDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.lock, color: bsuRed, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: bsuRed,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              hintText: "4-digit PIN",
              prefixIcon: const Icon(Icons.pin, color: bsuRed),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: bsuRed, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bsuRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          onPressed: () async {
            await onConfirm(controller.text);
          },
        ),
      ],
    );
  }
}