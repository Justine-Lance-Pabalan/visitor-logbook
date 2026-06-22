import 'package:flutter/material.dart';

import 'screens/home_screen.dart';


void main() {

  runApp(
    const VisitorLogbookApp(),
  );

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