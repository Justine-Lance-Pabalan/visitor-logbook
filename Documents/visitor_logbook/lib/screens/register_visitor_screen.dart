import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../data/api_service.dart';
import '../widgets/bsu_header.dart';
import '../widgets/success_dialog.dart';
import '../utils/colors.dart';
import '../utils/sr_code_formatter.dart';
import '../widgets/register_button.dart';

class RegisterVisitorScreen extends StatefulWidget {
  const RegisterVisitorScreen({super.key});

  @override
  State<RegisterVisitorScreen> createState() => _RegisterVisitorScreenState();
}

class _RegisterVisitorScreenState extends State<RegisterVisitorScreen> {
  final _nameController = TextEditingController();
  final _srCodeController = TextEditingController();
  final _otherPurposeController = TextEditingController();
  final _propertyController = TextEditingController(text: "N/A");

  String _lastSrCode = '';
  String? selectedDepartment;
  String? selectedPurpose;

  final departments = ["Guest/Visitor", "CAFAD", "CET", "CICS", "COE"];

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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
    final navigatorState = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SuccessDialog(
        icon: Icons.check_rounded,
        title: 'Registered!',
        subtitle: 'Visitor has been successfully\nlogged in the system.',
        extra: Column(
          children: [
            const Text(
              'Your Time-Out PIN',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: bsuRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: bsuRed, width: 2),
              ),
              child: Text(
                pin,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: bsuRed,
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
          ],
        ),
      ),
    ).then((_) {
      if (mounted) navigatorState.pop();
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) navigatorState.pop();
    });
  }

  void _showBorrowedDialog() {
    final navigatorState = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SuccessDialog(
        icon: Icons.inventory_2_rounded,
        title: 'Registered!',
        subtitle: 'Visitor has been successfully\nlogged in the system.',
        extra: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange, width: 1.5),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You have borrowed equipment. Please return it and ask the admin to time you out.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (mounted) navigatorState.pop();
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) navigatorState.pop();
    });
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
          style: TextStyle(color: bsuWhite, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          //Header
          BsuHeader(subtitle: 'Fill in the visitor details below'),

          //Forms
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        inputFormatters: [SrCodeFormatter()],
                        onChanged: (value) {
                          final normalized = value.trim().toLowerCase();
                          final isGuestVariant =
                              normalized == "guest" ||
                              normalized == "visitor" ||
                              normalized == "guest/visitor" ||
                              normalized == "guest visitor";
                          final isTyping = value.length > _lastSrCode.length;
                          if (isGuestVariant &&
                              isTyping &&
                              _srCodeController.text != "Guest/Visitor") {
                            setState(() {
                              _srCodeController.text = "Guest/Visitor";
                              _srCodeController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _srCodeController.text.length,
                                    ),
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
                            } else if (_srCodeController.text ==
                                "Guest/Visitor") {
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
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: RegisterButton(
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
                                    "SR Code must only contain numbers and dashes",
                                  ),
                                  backgroundColor: bsuRed,
                                ),
                              );
                              return;
                            }

                            final existing = await ApiService.getVisitors();
                            final today = DateTime.now();
                            final duplicate = existing.any(
                              (v) =>
                                  v.srCode == srCode &&
                                  v.name.toLowerCase() ==
                                      nameInput.toLowerCase() &&
                                  v.date.year == today.year &&
                                  v.date.month == today.month &&
                                  v.date.day == today.day,
                            );

                            if (duplicate) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "This visitor is already registered today",
                                  ),
                                  backgroundColor: bsuRed,
                                ),
                              );
                              return;
                            }

                            final newVisitor = await ApiService.insertVisitor(
                              Visitor(
                                name: nameInput,
                                srCode: srCode,
                                department: selectedDepartment!,
                                purpose: selectedPurpose == "Others"
                                    ? _otherPurposeController.text
                                    : selectedPurpose!,
                                propertyUsed: _propertyController.text,
                                pin: '0000',
                                date: DateTime.now().toUtc(),
                                timeIn: DateTime.now().toUtc(),
                              ),
                            );

                            final hasBorrowedProperty =
                                _propertyController.text.trim().toLowerCase() !=
                                "n/a";

                            if (hasBorrowedProperty) {
                              _showBorrowedDialog();
                            } else {
                              _showSuccessDialog(newVisitor.pin);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}