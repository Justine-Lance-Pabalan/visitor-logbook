import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../data/visitor_data.dart';

String formatTime(DateTime dateTime) {
  return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2,'0')}";
}

String formatDate(DateTime dateTime) {
  return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
}

class ActiveVisitorsScreen extends StatefulWidget {
  const ActiveVisitorsScreen({super.key});
  @override
  State<ActiveVisitorsScreen> createState() =>
      _ActiveVisitorsScreenState();
}

class _ActiveVisitorsScreenState
    extends State<ActiveVisitorsScreen> {
  String getStatus(Visitor visitor) {
    if (visitor.timeOut != null) {
      return "Completed";
    }
    if (visitor.propertyUsed.toLowerCase() == "n/a") {
      return "No Property";
    }
    if (visitor.propertyReturned) {
      return "Property Returned";
    }
    return "Borrowing Property";
  }

  void showAdminPin(
      BuildContext context,
      Visitor visitor
      ) {
    final controller =
        TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            const Text("Admin PIN"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration:
              const InputDecoration(
                hintText: "PIN",
              ),
        ),

        actions: [
          TextButton(
            child:
                const Text("Confirm"),
            onPressed: () {
              if (controller.text == "1234") {
                Navigator.pop(context);
                setState(() {
                  visitor.timeOut =
                      DateTime.now();
                });
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content:
                      Text("Wrong PIN"),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeVisitors =
        visitors.where(
          (v) => v.timeOut == null
        ).toList();
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
              "Active Visitors",
            ),
      ),
      body:
      activeVisitors.isEmpty
      ? const Center(
          child:
            Text(
              "No active visitors",
            ),
        )
      : ListView.builder(
          itemCount:
              activeVisitors.length,
          itemBuilder:
          (context,index){
            final visitor =
                activeVisitors[index];
            return Card(
              margin:
                  const EdgeInsets.all(10),
              child: Padding(
                padding:
                    const EdgeInsets.all(15),
                child:
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      visitor.name,
                      style:
                      const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
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
                    const SizedBox(height:10),
                    Text(
                      "Date: ${formatDate(visitor.timeIn)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height:5),
                    Text(
                      "Time In: ${formatTime(visitor.timeIn)}",
                    ),
                    Text(
                      "Status: ${getStatus(visitor)}",
                    ),
                    const SizedBox(height:10),
                    Row(
                      children: [
                        if(visitor.propertyUsed
                            .toLowerCase() != "n/a"
                            &&
                            !visitor.propertyReturned)
                        const SizedBox(width:10),
                        ElevatedButton(
                          child:
                            const Text(
                              "Time Out",
                            ),
                          onPressed: () {
                            if(
                            visitor.propertyUsed.toLowerCase() == "n/a") {
                              setState(() {
                                visitor.timeOut = DateTime.now();
                              });
                            }
                            else {
                              showAdminPin(
                                context,
                                visitor,
                              );
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
    );
  }
}