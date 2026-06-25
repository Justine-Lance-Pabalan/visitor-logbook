import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../data/database_helper.dart';
import 'package:flutter/services.dart';
import 'dart:math';

const bsuRed = Color(0xFF7B1113);
const bsuGold = Color(0xFFF5A623);
const bsuWhite = Colors.white;

class RegisterVisitorScreen extends StatefulWidget {
  const RegisterVisitorScreen({super.key});

  @override
  State<RegisterVisitorScreen> createState() =>
      _RegisterVisitorScreenState();
}

class _RegisterVisitorScreenState extends State<RegisterVisitorScreen> {
  final _nameController = TextEditingController();
  final _srCodeController = TextEditingController();
  final _otherPurposeController = TextEditingController();
  final _propertyController = TextEditingController(text: "N/A");

  String _lastSrCode = '';
  String? selectedDepartment;
  String? selectedPurpose;

  final departments = [
    "Guest/Visitor",
    "CAFAD",
    "CET",
    "CICS",
    "COE",
  ];

  final purposes = [
    "Meeting",
    "Consultation",
    "Research",
    "Borrow Equipment",
    "Others",
  ];

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: bsuRed),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: bsuRed, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }

  void _showSuccessDialog(String pin) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _SuccessDialog(pin: pin),
    );

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pop(context); // closes dialog
      Navigator.pop(context); // goes back to home
    });
  }

  String _generatePin() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bsuWhite,

      appBar: AppBar(
        backgroundColor: bsuRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: bsuWhite),
        title: const Text(
          'Register Visitor',
          style: TextStyle(
            color: bsuWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [

          // ── Red top banner ──
          Container(
            width: double.infinity,
            color: bsuRed,
            padding: const EdgeInsets.only(bottom: 20),
            child: const Center(
              child: Text(
                'Fill in the visitor details below',
                style: TextStyle(
                  color: bsuWhite,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          // ── Curved transition ──
          Container(
            height: 24,
            decoration: const BoxDecoration(
              color: bsuWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),

          // ── Form ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 8),

                    const Text(
                      'Visitor Information',
                      style: TextStyle(
                        color: bsuRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const Divider(color: bsuGold, thickness: 2),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _nameController,
                      decoration: _inputDecoration("Name"),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: _srCodeController,
                      decoration: _inputDecoration("SR Code (e.g. 22-12345)"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        _SrCodeFormatter(), // restricts typing to the format
                      ],
                      onChanged: (value) {
                        final normalized = value.trim().toLowerCase();
                        final isGuestVariant = normalized == "guest" ||
                            normalized == "visitor" ||
                            normalized == "guest/visitor" ||
                            normalized == "guest visitor";
                        final isTyping = value.length > _lastSrCode.length;

                        if (isGuestVariant && isTyping &&
                            _srCodeController.text != "Guest/Visitor") {
                          setState(() {
                            _srCodeController.text = "Guest/Visitor";
                            _srCodeController.selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                  offset: _srCodeController.text.length),
                            );
                            selectedDepartment = "Guest/Visitor";
                          });
                        } else if (!isGuestVariant &&
                            selectedDepartment == "Guest/Visitor") {
                          setState(() {
                            selectedDepartment = null;
                          });
                        }
                        _lastSrCode = value;
                      },
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration("Department"),
                      value: selectedDepartment,
                      items: departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDepartment = value;
                          if (value == "Guest/Visitor") {
                            _srCodeController.text = "Guest/Visitor";
                          } else if (_srCodeController.text == "Guest/Visitor") {
                            _srCodeController.clear();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration("Purpose of Visit"),
                      value: selectedPurpose,
                      items: purposes.map((purpose) {
                        return DropdownMenuItem(
                          value: purpose,
                          child: Text(purpose),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPurpose = value;
                        });
                      },
                    ),

                    if (selectedPurpose == "Others")
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: TextField(
                          controller: _otherPurposeController,
                          decoration: _inputDecoration("Specify Purpose"),
                        ),
                      ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: _propertyController,
                      decoration: _inputDecoration("Property Used"),
                    ),

                    const SizedBox(height: 30),

                    // ── Register Button ──
                    // OutlinedButton wraps it so we get the red border
                    // when not pressed, full red when pressed
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: _RegisterButton(
                        onPressed: () async {
                          final srCode = _srCodeController.text;
                          final nameInput = _nameController.text;

                          if (nameInput.isEmpty ||
                              srCode.isEmpty ||
                              selectedDepartment == null ||
                              selectedPurpose == null ||
                              _propertyController.text.isEmpty ||
                              (selectedPurpose == "Others" &&
                                  _otherPurposeController.text.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please complete all fields"),
                                backgroundColor: bsuRed,
                              ),
                            );
                            return;
                          }

                          final srCodeRegex = RegExp(r'^\d{2}-\d{5}$');
                          if (srCode != "Guest/Visitor" &&
                              !srCodeRegex.hasMatch(srCode)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "SR Code must only contain numbers and dashes"),
                                backgroundColor: bsuRed,
                              ),
                            );
                            return;
                          }

                          final existing = await DatabaseHelper.getVisitors();
                          final today = DateTime.now();
                          final duplicate = existing.any((v) =>
                              v.srCode == srCode &&
                              v.name.toLowerCase() ==
                                  nameInput.toLowerCase() &&
                              v.date.year == today.year &&
                              v.date.month == today.month &&
                              v.date.day == today.day);

                          if (duplicate) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "This visitor is already registered today"),
                                backgroundColor: bsuRed,
                              ),
                            );
                            return;
                          }

                          final pin = _generatePin();

                          await DatabaseHelper.insertVisitor(
                            Visitor(
                              name: nameInput,
                              srCode: srCode,
                              department: selectedDepartment!,
                              purpose: selectedPurpose == "Others"
                                  ? _otherPurposeController.text
                                  : selectedPurpose!,
                              propertyUsed: _propertyController.text,
                              pin: pin,
                              date: DateTime.now(),
                              timeIn: DateTime.now(),
                            ),
                          );

                          _showSuccessDialog(pin);
                        },
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Register Button — outline when idle, solid red when pressed ──
class _RegisterButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _RegisterButton({required this.onPressed});

  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // When pressed: solid red background, white text
    // When idle:    white background, red border, red text
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

// ── Success Dialog with animated checkmark ──
class _SuccessDialog extends StatefulWidget {
  final String pin;
  const _SuccessDialog({required this.pin});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
                child: const Icon(
                  Icons.check_rounded,
                  color: bsuWhite,
                  size: 55,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Registered!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: bsuRed,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Visitor has been successfully\nlogged in the system.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // ── PIN display ──
            const Text(
              'Your Time-Out PIN',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF7B1113).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF7B1113),
                  width: 2,
                ),
              ),
              child: Text(
                widget.pin, // ← shows the PIN
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B1113),
                  letterSpacing: 12,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Remember this PIN to time out.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),

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

class _SrCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Always allow Guest/Visitor to pass through untouched
    if (newValue.text == "Guest/Visitor") return newValue;

    final digits = newValue.text.replaceAll('-', '');

    // Max 7 digits total (2 + 5)
    if (digits.length > 7) return oldValue;

    // Only allow numbers
    if (!RegExp(r'^[0-9]*$').hasMatch(digits)) return oldValue;

    // Auto insert dash after 2 digits
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

