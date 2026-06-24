import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/visitor.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class VisitorRecordsScreen extends StatefulWidget {
  const VisitorRecordsScreen({super.key});

  @override
  State<VisitorRecordsScreen> createState() =>
      _VisitorRecordsScreenState();
}

class _VisitorRecordsScreenState
    extends State<VisitorRecordsScreen> {
  List<Visitor> _visitors = [];
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
  
  Future<void> loadVisitors() async {
    final data = await DatabaseHelper.getVisitors();
    setState(() {
      _visitors = data;
    });
  }

  Future<void> exportCSV(List<Visitor> visitors) async {
    List<List<dynamic>> rows = [
      ['Name', 'SR Code', 'Department', 'Purpose', 'Property Used', 'Time In', 'Time Out'],
      ...visitors.map((v) => [
        v.name,
        v.srCode,
        v.department,
        v.purpose,
        v.propertyUsed,
        formatTime(v.timeIn),
        v.timeOut == null ? '-' : formatTime(v.timeOut!),
      ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/visitors_${selectedDate.year}-${selectedDate.month}-${selectedDate.day}.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Visitor Records');
  }

  @override
  void initState() {
    super.initState();
    loadVisitors();
  }

  @override
  Widget build(BuildContext context) {
    final filteredVisitors = _visitors.where((visitor) {
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Visitors: ${filteredVisitors.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => exportCSV(filteredVisitors),
                  icon: const Icon(Icons.download),
                  label: const Text("Export"),
                ),
              ],
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