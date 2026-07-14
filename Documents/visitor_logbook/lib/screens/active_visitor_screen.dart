import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../data/api_service.dart';
import '../widgets/bsu_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/pin_dialog.dart';
import '../widgets/success_dialog.dart';
import '../widgets/visitor_card.dart';
import '../utils/colors.dart';

class ActiveVisitorsScreen extends StatefulWidget {
  const ActiveVisitorsScreen({super.key});

  @override
  State<ActiveVisitorsScreen> createState() => _ActiveVisitorsScreenState();
}

class _ActiveVisitorsScreenState extends State<ActiveVisitorsScreen> {
  List<Visitor> _visitors = [];

  @override
  void initState() {
    super.initState();
    loadVisitors();
  }

  Future<void> loadVisitors() async {
    final data = await ApiService.getVisitors();
    setState(() {
      _visitors = data;
    });
  }

  String getStatus(Visitor visitor) {
    if (visitor.timeOut != null) return "Completed";
    if (visitor.propertyUsed.toLowerCase() == "n/a") return "No Property";
    if (visitor.propertyReturned) return "Property Returned";
    return "Borrowing Property";
  }

  void _showTimeOutSuccess(BuildContext context) {
    final dialogKey = GlobalKey();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SuccessDialog(
        key: dialogKey,
        icon: Icons.logout_rounded,
        title: 'Timed Out!',
        subtitle: 'Visitor has been successfully\ntimed out of the system.',
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (dialogKey.currentContext != null) {
        Navigator.of(dialogKey.currentContext!).pop();
      }
    });
  }

  void showPinDialog(BuildContext context, Visitor visitor) {
    showDialog(
      context: context,
      builder: (_) => PinDialog(
        title: "Enter PIN to Time Out",
        subtitle: "Enter your assigned PIN or the admin PIN.",
        onConfirm: (entered) async {
          if (entered == visitor.pin || entered == "1234") {
            Navigator.pop(context);
            visitor.timeOut = DateTime.now();
            final isAdmin = entered == "1234";
            await ApiService.checkoutVisitor(
              visitor.id!,
              pin: isAdmin ? null : entered,
            );
            await loadVisitors();
            _showTimeOutSuccess(context);
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Incorrect PIN. Try again."),
                backgroundColor: bsuRed,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeVisitors = _visitors.where((v) => v.timeOut == null).toList();

    return Scaffold(
      backgroundColor: bsuWhite,

      appBar: AppBar(
        backgroundColor: bsuRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: bsuWhite),
        centerTitle: true,
        title: const Text(
          'Active Visitors',
          style: TextStyle(color: bsuWhite, fontWeight: FontWeight.bold),
        ),

        // ── Badge on top right ──
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.people, color: bsuWhite, size: 28),
                if (activeVisitors.isNotEmpty)
                  Positioned(
                    top: 6,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: bsuGold,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${activeVisitors.length}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          //Header
          BsuHeader(subtitle: 'Visitors currently inside the premises'),

          //Body
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: activeVisitors.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline,
                        title: 'No Active Visitors',
                        subtitle:
                            'All visitors have been timed out\nor no one has registered yet.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: activeVisitors.length,
                        itemBuilder: (context, index) {
                          final visitor = activeVisitors[index];
                          final status = getStatus(visitor);

                          // Status chip color
                          Color statusColor;
                          if (status == "Borrowing Property") {
                            statusColor = Colors.orange;
                          } else if (status == "Property Returned") {
                            statusColor = Colors.green;
                          } else {
                            statusColor = Colors.blueGrey;
                          }

                          return VisitorCard(
                              visitor: visitor,
                              status: status,
                              statusColor: statusColor,
                              showTimeOut: true,
                              onTimeOut: () => showPinDialog(context, visitor),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
