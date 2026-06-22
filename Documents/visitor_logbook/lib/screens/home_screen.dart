import 'package:flutter/material.dart';

import 'register_visitor_screen.dart';
import 'visitor_records_screen.dart';
import 'active_visitor_screen.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Visitor Logbook'),
      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 30),


            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                child:
                    const Text('Register Visitor'),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const RegisterVisitorScreen(),
                    ),
                  );

                },
              ),
            ),


            const SizedBox(height: 15),


            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                child:
                    const Text('Active Visitors'),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => 
                        const ActiveVisitorsScreen(),
                      ),
                    );
                },
              ),
            ),


            const SizedBox(height: 15),


            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                child:
                    const Text('Visitor History'),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const VisitorRecordsScreen(),
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