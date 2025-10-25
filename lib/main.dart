// ignore_for_file: avoid_print

import 'package:budget_tracker/Screens/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- THIS IS THE NEW, MORE ROBUST FIX ---
  try {
    // Try to initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // If it fails because it's already initialized, just print a message
    if (e.code == 'duplicate-app') {
      print('Firebase app [DEFAULT] already initialized.');
    } else {
      // If it's a different Firebase error, re-throw it
      rethrow;
    }
  }
  // --- END OF FIX ---

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
