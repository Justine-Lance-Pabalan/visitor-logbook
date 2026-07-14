import 'package:flutter/material.dart';
import '../data/api_service.dart';
import '../models/visitor.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/bsu_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/success_dialog.dart';
import '../widgets/visitor_card.dart';
import '../utils/colors.dart';
import '../widgets/filter_button.dart';

class VisitorRecordsScreen extends StatefulWidget {
  const VisitorRecordsScreen({super.key});

  @override
  State<VisitorRecordsScreen> createState() => _VisitorRecordsScreenState();
}

class _VisitorRecordsScreenState extends State<VisitorRecordsScreen> {
  List<Visitor> _visitors = [];
  DateTime selectedDate = DateTime.now();

  String _searchQuery = '';
  String? _filterDepartment;
  String? _filterPurpose;

  final departments = ["CAFAD", "CET", "CICS", "COE", "Guest/Visitor"];
  final purposes = [
    "Meeting",
    "Consultation",
    "Research",
    "Borrow Equipment",
    "Others",
  ];

  String formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  String formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = dateTime.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

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
      builder: (_) => const SuccessDialog(
        icon: Icons.download_done_rounded,
        title: 'Exported!',
        subtitle: 'Visitor records have been\nsuccessfully exported to CSV.',
      ),
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
        'Time Out',
      ],
      ...visitors.map(
        (v) => [
          v.name,
          v.srCode,
          v.department,
          v.purpose,
          v.propertyUsed,
          formatTime(v.timeIn),
          v.timeOut == null ? '-' : formatTime(v.timeOut!),
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/visitors_${selectedDate.year}-${selectedDate.month}-${selectedDate.day}.csv',
    );
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Visitor Records');

    _showExportSuccessDialog();
  }

  @override
  Widget build(BuildContext context) {
    final filteredVisitors = _visitors.where((visitor) {
      final matchesDate =
          visitor.date.year == selectedDate.year &&
          visitor.date.month == selectedDate.month &&
          visitor.date.day == selectedDate.day;
      final matchesSearch =
          _searchQuery.isEmpty ||
          visitor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          visitor.srCode.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDepartment =
          _filterDepartment == null || visitor.department == _filterDepartment;
      final matchesPurpose =
          _filterPurpose == null ||
          (_filterPurpose == "Others"
              ? ![
                  "Meeting",
                  "Consultation",
                  "Research",
                  "Borrow Equipment",
                ].contains(visitor.purpose)
              : visitor.purpose == _filterPurpose);
      return matchesDate &&
          matchesSearch &&
          matchesDepartment &&
          matchesPurpose;
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
          style: TextStyle(color: bsuWhite, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          //header
          BsuHeader(subtitle: 'Browse past visitor records by date'),

          // ── Constrained content ──
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.calendar_today,
                                color: bsuRed,
                                size: 18,
                              ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: pickDate,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: bsuRed.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: bsuRed.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.people,
                                      color: bsuRed,
                                      size: 16,
                                    ),
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
                              ElevatedButton.icon(
                                onPressed: filteredVisitors.isEmpty
                                    ? null
                                    : () => exportCSV(filteredVisitors),
                                icon: const Icon(
                                  Icons.download,
                                  color: bsuWhite,
                                  size: 16,
                                ),
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
                          const SizedBox(height: 10),

                          // ── Search bar ──
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by name or SR code...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: bsuRed,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: bsuRed,
                                      ),
                                      onPressed: () =>
                                          setState(() => _searchQuery = ''),
                                    )
                                  : null,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: bsuRed,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                          ),

                          const SizedBox(height: 10),

                          // ── Filter buttons ──
                          Row(
                            children: [
                              FilterButton(
                                label: 'Department',
                                selected: _filterDepartment,
                                icon: Icons.school,
                                options: departments,
                                dialogTitle: 'Select Department',
                                onChanged: (value) =>
                                    setState(() => _filterDepartment = value),
                              ),
                              const SizedBox(width: 8),
                              FilterButton(
                                label: 'Purpose',
                                selected: _filterPurpose,
                                icon: Icons.info_outline,
                                options: purposes,
                                dialogTitle: 'Select Purpose',
                                onChanged: (value) =>
                                    setState(() => _filterPurpose = value),
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
                          ? SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: EmptyState(
                                icon: Icons.history,
                                title: 'No Records Found',
                                subtitle:
                                    'No visitors were recorded\non this date.',
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: filteredVisitors.length,
                              itemBuilder: (context, index) {
                                final visitor = filteredVisitors[index];
                                final isTimedOut = visitor.timeOut != null;
                                return VisitorCard(
                                  visitor: visitor,
                                  status: isTimedOut ? 'Completed' : 'Active',
                                  statusColor: isTimedOut
                                      ? Colors.green
                                      : Colors.orange,
                                  showPin: true,
                                );
                              },
                            ),
                    ),
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
