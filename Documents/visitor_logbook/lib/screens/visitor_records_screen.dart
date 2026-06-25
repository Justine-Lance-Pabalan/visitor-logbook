import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/visitor.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const bsuRed = Color(0xFF7B1113);
const bsuGold = Color(0xFFF5A623);
const bsuWhite = Colors.white;

class VisitorRecordsScreen extends StatefulWidget {
  const VisitorRecordsScreen({super.key});

  @override
  State<VisitorRecordsScreen> createState() =>
      _VisitorRecordsScreenState();
}

class _VisitorRecordsScreenState extends State<VisitorRecordsScreen> {
  List<Visitor> _visitors = [];
  DateTime selectedDate = DateTime.now();

  String formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  String formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

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

  Future pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // BSU themed date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: bsuRed,
              onPrimary: bsuWhite,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showExportSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ExportSuccessDialog(),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  Future<void> exportCSV(List<Visitor> visitors) async {
    List<List<dynamic>> rows = [
      [
        'Name',
        'SR Code',
        'Department',
        'Purpose',
        'Property Used',
        'Time In',
        'Time Out'
      ],
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
    final file = File(
        '${dir.path}/visitors_${selectedDate.year}-${selectedDate.month}-${selectedDate.day}.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Visitor Records');

    _showExportSuccessDialog();
  }

  @override
  Widget build(BuildContext context) {
    final filteredVisitors = _visitors.where((visitor) {
      return visitor.date.year == selectedDate.year &&
          visitor.date.month == selectedDate.month &&
          visitor.date.day == selectedDate.day;
    }).toList();

    filteredVisitors.sort((a, b) => a.timeIn.compareTo(b.timeIn));

    return Scaffold(
      backgroundColor: bsuWhite,

      appBar: AppBar(
        backgroundColor: bsuRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: bsuWhite),
        centerTitle: true,
        title: const Text(
          'Visitor History',
          style: TextStyle(
            color: bsuWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                'Browse past visitor records by date',
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

          // ── Date picker + total + export row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [

                // Date button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today,
                        color: bsuRed, size: 18),
                    label: Text(
                      formatDate(selectedDate),
                      style: const TextStyle(
                        color: bsuRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: bsuRed, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: pickDate,
                  ),
                ),

                const SizedBox(height: 10),

                // Total count + export button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Total badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: bsuRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: bsuRed.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: bsuRed, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Total: ${filteredVisitors.length}',
                            style: const TextStyle(
                              color: bsuRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Export button
                    ElevatedButton.icon(
                      onPressed: filteredVisitors.isEmpty
                          ? null
                          : () => exportCSV(filteredVisitors),
                      icon: const Icon(Icons.download,
                          color: bsuWhite, size: 16),
                      label: const Text(
                        'Export CSV',
                        style: TextStyle(
                          color: bsuWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bsuRed,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(color: bsuGold, thickness: 2),
              ],
            ),
          ),

          // ── List or empty state ──
          Expanded(
            child: filteredVisitors.isEmpty
                ? _EmptyState(date: formatDate(selectedDate))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: filteredVisitors.length,
                    itemBuilder: (context, index) {
                      final visitor = filteredVisitors[index];
                      final isTimedOut = visitor.timeOut != null;

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

                              // ── Name + completion badge ──
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
                                      color: isTimedOut
                                          ? Colors.green.withOpacity(0.12)
                                          : Colors.orange.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isTimedOut
                                            ? Colors.green
                                            : Colors.orange,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      isTimedOut ? 'Completed' : 'Active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isTimedOut
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // SR Code
                              Text(
                                visitor.srCode,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const Divider(height: 16),

                              // Detail chips row 1
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

                              // Detail chips row 2
                              Row(
                                children: [
                                  _DetailChip(
                                      icon: Icons.inventory_2_outlined,
                                      label: visitor.propertyUsed),
                                  const SizedBox(width: 8),
                                  _DetailChip(
                                      icon: Icons.login,
                                      label:
                                          "In: ${formatTime(visitor.timeIn)}"),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Time out chip — full width
                              Row(
                                children: [
                                  _DetailChip(
                                    icon: Icons.logout,
                                    label: isTimedOut
                                        ? "Out: ${formatTime(visitor.timeOut!)}"
                                        : "Out: Still Active",
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

// ── Empty state ──
class _EmptyState extends StatelessWidget {
  final String date;
  const _EmptyState({required this.date});

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
              Icons.history,
              size: 60,
              color: bsuRed,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Records Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: bsuRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No visitors were recorded\non this date.',
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

// ── Detail chip — reused from active visitors ──
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

// ── Export Success Dialog ──
class _ExportSuccessDialog extends StatefulWidget {
  const _ExportSuccessDialog();

  @override
  State<_ExportSuccessDialog> createState() => _ExportSuccessDialogState();
}

class _ExportSuccessDialogState extends State<_ExportSuccessDialog>
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
                  Icons.download_done_rounded,
                  color: bsuWhite,
                  size: 50,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Exported!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: bsuRed,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Visitor records have been\nsuccessfully exported to CSV.',
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