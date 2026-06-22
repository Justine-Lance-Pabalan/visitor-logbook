import 'package:flutter/material.dart';

void main() {
  runApp(const VisitorLogbookApp());
}

class VisitorLogbookApp extends StatelessWidget {
  const VisitorLogbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Visitor Logbook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Logbook'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('Register Visitor'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterVisitorScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('View Records'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VisitorRecordsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterVisitorScreen extends StatelessWidget {
  const RegisterVisitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Visitor'),
      ),
      body: const Center(
        child: Text(
          'Visitor Registration Form Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class VisitorRecordsScreen extends StatelessWidget {
  const VisitorRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Records'),
      ),
      body: const Center(
        child: Text(
          'Visitor Records List Here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}