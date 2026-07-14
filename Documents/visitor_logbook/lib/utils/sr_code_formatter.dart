import 'package:flutter/services.dart';

class SrCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == "Guest/Visitor") return newValue;

    final digits = newValue.text.replaceAll('-', '');

    if (digits.length > 7) return oldValue;

    if (!RegExp(r'^[0-9]*$').hasMatch(digits)) return oldValue;

    String formatted = digits;
    if (digits.length > 2) {
      formatted = '${digits.substring(0, 2)}-${digits.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}