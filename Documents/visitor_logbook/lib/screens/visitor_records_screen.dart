import 'package:flutter/material.dart';
import '../data/visitor_data.dart';

class VisitorRecordsScreen extends StatefulWidget {
  const VisitorRecordsScreen({super.key});

  @override
  State<VisitorRecordsScreen> createState() =>
      _VisitorRecordsScreenState();
}

class _VisitorRecordsScreenState
    extends State<VisitorRecordsScreen> {

  DateTime selectedDate = DateTime.now();

  String formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  String formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredVisitors = visitors.where((visitor) {
      return visitor.date.year == selectedDate.year &&
          visitor.date.month == selectedDate.month &&
          visitor.date.day == selectedDate.day;
    }).toList();
    filteredVisitors.sort(
      (a, b) =>
        a.timeIn.compareTo(b.timeIn),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Visitor History"),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(10),

            child: SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: pickDate,

                child: Text(
                  formatDate(selectedDate),
                ),
              ),
            ),
          ),

          Expanded(
            child: filteredVisitors.isEmpty

                ? const Center(
                    child: Text(
                      "No visitors on this date",
                    ),
                  )

                : ListView.builder(
                    itemCount: filteredVisitors.length,

                    itemBuilder: (context, index) {
                      final visitor = filteredVisitors[index];

                      return Card(
                        margin: const EdgeInsets.all(8),

                        child: Padding(
                          padding: const EdgeInsets.all(12),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Text(
                                visitor.name,

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              Text(
                                "SR Code: ${visitor.srCode}",
                              ),

                              Text(
                                "Department: ${visitor.department}",
                              ),

                              Text(
                                "Purpose: ${visitor.purpose}",
                              ),

                              Text(
                                "Property: ${visitor.propertyUsed}",
                              ),

                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [

                                  Text(
                                    "Time In: ${formatTime(visitor.timeIn)}",
                                  ),

                                  Text(
                                    "Time Out: ${
                                      visitor.timeOut == null
                                          ? "-"
                                          : formatTime(visitor.timeOut!)
                                    }",
                                  ),

                                ],
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

        ],
      ),
    );
  }
}