import 'package:flutter/material.dart';
import 'list_grades.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  const MyApp({Key? key}) : super(key: key); // corrected here

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Entry System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ListGrades(title: 'List of Grades'), // Updated home route
    );
  }
}

// In a global accessible space, like your main.dart or another singleton class
class UniqueIdGenerator {
  static int _currentId = 0;

  static int get nextId {
    _currentId++;
    return _currentId;
  }
}
