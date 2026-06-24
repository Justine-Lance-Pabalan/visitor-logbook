import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../data/database_helper.dart';

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

  final _propertyController = TextEditingController(
    text: "N/A",
  );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Visitor"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _srCodeController,
                decoration: const InputDecoration(
                  labelText: "SR Code",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final normalized = value.trim().toLowerCase();
                  final isGuestVariant = normalized == "guest" ||
                      normalized == "visitor" ||
                      normalized == "guest/visitor" ||
                      normalized == "guest visitor";
                  final isTyping = value.length > _lastSrCode.length;

                  if (isGuestVariant && isTyping && _srCodeController.text != "Guest/Visitor") {
                    setState(() {
                      _srCodeController.text = "Guest/Visitor";
                      _srCodeController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _srCodeController.text.length),
                    );
                    selectedDepartment = "Guest/Visitor";
                  });
                } else if (!isGuestVariant && selectedDepartment == "Guest/Visitor") {
                  setState(() {
                    selectedDepartment = null;
                  });
                }

                _lastSrCode = value;
              },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: "Purpose of Visit",
                  border: OutlineInputBorder(),
                ),

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

              if(selectedPurpose == "Others")
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: TextField(
                    controller:
                      _otherPurposeController,
                    decoration:
                      const InputDecoration(
                    labelText:
                      "Specify Purpose",
                    border:
                      OutlineInputBorder(),

                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _propertyController,
                decoration: const InputDecoration(
                  labelText: "Property Used",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  child: const Text("Register Visitor"),

                  onPressed: () async {
                    final srCode = _srCodeController.text;
                    final nameInput = _nameController.text;

                    // Basic field validation
                    if (
                      nameInput.isEmpty ||
                      srCode.isEmpty ||
                      selectedDepartment == null ||
                      selectedPurpose == null ||
                      _propertyController.text.isEmpty ||
                      (selectedPurpose == "Others" &&
                      _otherPurposeController.text.isEmpty)
                    ) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please complete all fields")),
                      );
                      return;
                    }

                    // SR Code format validation (numbers and dash only)
                    final srCodeRegex = RegExp(r'^[0-9\-]+$');
                    if (srCode != "Guest/Visitor" && !srCodeRegex.hasMatch(srCode)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("SR Code must only contain numbers and dashes")),
                      );
                      return;
                    }

                    // Same-day duplicate check
                    final existing = await DatabaseHelper.getVisitors();
                    final today = DateTime.now();
                    final duplicate = existing.any((v) =>
                      v.srCode == srCode &&
                      v.name.toLowerCase() == nameInput.toLowerCase() &&
                      v.date.year == today.year &&
                      v.date.month == today.month &&
                      v.date.day == today.day,
                    );

                    if (duplicate) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("This visitor is already registered today")),
                      );
                      return;
                    }

                    await DatabaseHelper.insertVisitor(
                      Visitor(
                        name: nameInput,
                        srCode: srCode,
                        department: selectedDepartment!,
                        purpose: selectedPurpose == "Others"
                            ? _otherPurposeController.text
                            : selectedPurpose!,
                        propertyUsed: _propertyController.text,
                        date: DateTime.now(),
                        timeIn: DateTime.now(),
                      ),
                    );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Visitor Registered")),
                  );

                  Navigator.pop(context);
                },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}