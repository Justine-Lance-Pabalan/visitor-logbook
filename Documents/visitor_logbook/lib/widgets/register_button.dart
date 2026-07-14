import 'package:flutter/material.dart';
import '../utils/colors.dart';

class RegisterButton extends StatefulWidget {
  final VoidCallback onPressed;
  const RegisterButton({super.key, required this.onPressed});

  @override
  State<RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<RegisterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isPressed = _isPressed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isPressed ? bsuRed : bsuWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bsuRed, width: 2),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.how_to_reg,
              color: isPressed ? bsuWhite : bsuRed,
              size: 20,
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                color: isPressed ? bsuWhite : bsuRed,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              child: const Text('Register Visitor'),
            ),
          ],
        ),
      ),
    );
  }
}