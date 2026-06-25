import 'package:flutter/material.dart';
import '../models/visitor.dart';
import '../data/database_helper.dart';

const bsuRed = Color(0xFF7B1113);
const bsuGold = Color(0xFFF5A623);
const bsuWhite = Colors.white;

String formatTime(DateTime dateTime) {
  return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
}

String formatDate(DateTime dateTime) {
  return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
}

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
    final data = await DatabaseHelper.getVisitors();
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
    final navigatorState = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _TimeOutSuccessDialog(),
    );
  
    Future.delayed(const Duration(seconds: 2), () {
      navigatorState.pop();
    });
  }

  void showPinDialog(BuildContext context, Visitor visitor) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock, color: Color(0xFF7B1113), size: 20),
            SizedBox(width: 8),
            Text(
              "Enter PIN to Time Out",
              style: TextStyle(
                color: Color(0xFF7B1113),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your assigned PIN or the admin PIN.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                hintText: "4-digit PIN",
                prefixIcon: const Icon(Icons.pin,
                    color: Color(0xFF7B1113)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF7B1113), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Colors.grey.shade400),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel",
                style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B1113),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Confirm",
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final entered = controller.text;

              // Accept visitor's own PIN or admin PIN
              if (entered == visitor.pin || entered == "1234") {
                Navigator.pop(context);
                visitor.timeOut = DateTime.now();
                await DatabaseHelper.updateVisitor(visitor);
                await loadVisitors();
                _showTimeOutSuccess(context);
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Incorrect PIN. Try again."),
                    backgroundColor: Color(0xFF7B1113),
                  ),
                );
              }
            },
          ),
        ],
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
          style: TextStyle(
            color: bsuWhite,
            fontWeight: FontWeight.bold,
          ),
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

          // ── Red banner ──
          Container(
            width: double.infinity,
            color: bsuRed,
            padding: const EdgeInsets.only(bottom: 20),
            child: const Center(
              child: Text(
                'Visitors currently inside the premises',
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

          // ── Body ──
          Expanded(
            child: activeVisitors.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
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

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(
                              color: Color(0xFFEEEEEE), width: 1),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ── Name + status chip ──
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      visitor.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: bsuRed,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: statusColor, width: 1),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // ── SR Code ──
                              Text(
                                visitor.srCode,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const Divider(height: 16),

                              // ── Details grid ──
                              Row(
                                children: [
                                  _DetailChip(
                                      icon: Icons.school,
                                      label: visitor.department),
                                  const SizedBox(width: 8),
                                  _DetailChip(
                                      icon: Icons.info_outline,
                                      label: visitor.purpose),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  _DetailChip(
                                      icon: Icons.inventory_2_outlined,
                                      label: visitor.propertyUsed),
                                  const SizedBox(width: 8),
                                  _DetailChip(
                                      icon: Icons.access_time,
                                      label:
                                          "In: ${formatTime(visitor.timeIn)}"),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ── Time Out Button ──
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.logout,
                                      color: bsuWhite, size: 18),
                                  label: const Text(
                                    "Time Out",
                                    style: TextStyle(
                                      color: bsuWhite,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: bsuRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 1,
                                  ),
                                  onPressed: () async {
                                    showPinDialog(context, visitor);
                                  },
                                ),
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

// ── Empty state ──
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: bsuRed.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              size: 60,
              color: bsuRed,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Active Visitors',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: bsuRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All visitors have been timed out\nor no one has registered yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 3,
            width: 50,
            decoration: BoxDecoration(
              color: bsuGold,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small detail chip ──
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: bsuRed),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Time Out Success Dialog ──
class _TimeOutSuccessDialog extends StatefulWidget {
  const _TimeOutSuccessDialog();

  @override
  State<_TimeOutSuccessDialog> createState() => _TimeOutSuccessDialogState();
}

class _TimeOutSuccessDialogState extends State<_TimeOutSuccessDialog>
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  Icons.logout_rounded,
                  color: bsuWhite,
                  size: 50,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Timed Out!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: bsuRed,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Visitor has been successfully\ntimed out of the system.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
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