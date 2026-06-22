import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../data/visitor_data.dart';

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

  String? selectedDepartment;
  String? selectedPurpose;

  final departments = [
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

                  onPressed: () {
                    if (
                      _nameController.text.isEmpty ||
                      _srCodeController.text.isEmpty ||
                      selectedDepartment == null ||
                      selectedPurpose == null ||
                      _propertyController.text.isEmpty ||
                      (selectedPurpose == "Others" &&
                      _otherPurposeController.text.isEmpty)
                    ) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please complete all fields",
                          ),
                        ),
                      );

                      return;
                    }

                    visitors.add(
                      Visitor(
                        name: _nameController.text,
                        srCode: _srCodeController.text,
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
                      const SnackBar(
                        content: Text(
                          "Visitor Registered",
                        ),
                      ),
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