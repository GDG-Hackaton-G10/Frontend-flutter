import 'package:flutter/material.dart';
import 'app/main_entry_screen.dart'; // Import the shell

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the red "Debug" banner
      title: 'Pharmacy App',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home:
          const MainEntryScreen(), // This starts the app at the Navigation Bar
    );
  }
}
