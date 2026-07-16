import 'package:flutter/material.dart';
import 'register_visitor_screen.dart';
import 'visitor_records_screen.dart';
import 'active_visitor_screen.dart';
import '../widgets/pin_dialog.dart';
import '../utils/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bsuWhite,

      appBar: AppBar(
        backgroundColor: bsuRed,
        elevation: 0,
        title: const Text(
          'DTC Visitor Logbook',
          style: TextStyle(
            color: bsuWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── BSU Header — full width ──
            Container(
              width: double.infinity,
              color: bsuRed,
              padding: const EdgeInsets.only(top: 10, bottom: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/BatStateU-NEU-Logo.png', height: 100),
                      const SizedBox(width: 16),
                      Image.asset('assets/DTC.png', height: 100),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'DIGITAL TRANSFORMATION CENTER',
                    style: TextStyle(
                      color: bsuWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Advancing AI, data science, and immersive technology through research, consultation, and collaborative learning experiences.',
                    style: TextStyle(
                      color: bsuGold,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Constrained content ──
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
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
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Visitor Logbook System',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: bsuRed,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text(
                        'Select an option to continue',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _HomeButton(
                            label: 'Register Visitor',
                            icon: Icons.person_add,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterVisitorScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _HomeButton(
                            label: 'Active Visitors',
                            icon: Icons.people,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ActiveVisitorsScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _HomeButton(
                            label: 'Visitor History',
                            icon: Icons.history,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => PinDialog(
                                  title: "Admin Access",
                                  subtitle:
                                      "Enter admin PIN to view visitor history.",
                                  onConfirm: (entered) async {
                                    if (entered == "1234") {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const VisitorRecordsScreen(),
                                        ),
                                      );
                                    } else {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Incorrect PIN."),
                                          backgroundColor: bsuRed,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'Service • Excellence • Virtue',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              letterSpacing: 1.2,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable button widget ──
class _HomeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: bsuWhite),
        label: Text(
          label,
          style: const TextStyle(
            color: bsuWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bsuRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        onPressed: onTap,
      ),
    );
  }
}
