import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Grade {
  int? id; // Will be used by the database, it's auto-generated
  String sid; // Student ID
  String grade; // Letter grade

  Grade({this.id, required this.sid, required this.grade});

  // Convert a Grade into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sid': sid,
      'grade': grade,
    };
  }

  // Extract a Grade object from a Map object
  static Grade fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      sid: map['sid'],
      grade: map['grade'],
    );
  }
}

class ListGrades extends StatefulWidget {
  final String title;

  const ListGrades({Key? key, required this.title}) : super(key: key);
  @override
  _ListGradesState createState() => _ListGradesState();
}

class _ListGradesState extends State<ListGrades> {
  List<Grade> testGrades = []; // Placeholder for grade list
  int? _selectedIndex;

  // Placeholder data for grades
  List<Grade> _gradesList = [
    // Adding some sample grades
    Grade(id: 1, sid: '100000001', grade: 'A'),
    Grade(id: 2, sid: '100000002', grade: 'B'),
    Grade(id: 3, sid: '100000003', grade: 'C'),
    // Add more samples as needed
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // remembering the selection
    });
  }
  // Fetch grades from the database
  void _getGrades() async {
    var fetchedGrades = await GradesModel.instance.getAllGrades();
    setState(() {
      testGrades = fetchedGrades;
    });
  }

  // Navigate to GradeForm and wait for a result to add a grade
  void _addGrade() {
    Navigator.push(
      context as BuildContext,
      MaterialPageRoute(builder: (context) => GradeForm()), // We will create GradeForm later
    ).then((newGrade) {
      if (newGrade != null) {
        setState(() {
          testGrades.add(newGrade as Grade); // Make sure to cast the newGrade to a Grade object
        });
        GradesModel.instance.insertGrade(newGrade); // Insert the new grade into the database
      }
    });
  }

  // Modify the selected grade
  void _editGrade() async {
    if (_selectedIndex != null) {
      // Get the selected grade
      var selectedGrade = testGrades[_selectedIndex!];
      // Navigate to the GradeForm page and wait for the edited grade
      var editedGrade = await Navigator.push(
        context as BuildContext,
        MaterialPageRoute(builder: (context) => GradeForm(grade: selectedGrade)), // Send the selected grade for editing
      );
      if (editedGrade != null) {
        setState(() {
          testGrades[_selectedIndex!] = editedGrade as Grade; // Cast the editedGrade to a Grade object
        });
        GradesModel.instance.updateGrade(editedGrade); // Update the grade in the database
      }
    }
  }

  // Delete the selected grade
  void _deleteGrade() {
    if (_selectedIndex != null) {
      setState(() {
        var idToRemove = testGrades[_selectedIndex!].id; // Get the id of the selected grade
        testGrades.removeAt(_selectedIndex!); // Remove the grade from the list
        GradesModel.instance.deleteGradeById(idToRemove!); // Remove the grade from the database
        _selectedIndex = null; // Reset the selected index
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getGrades(); // Populate the grades when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editGrade,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteGrade,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _gradesList.length,
        itemBuilder: (context, index) {
          var grade = _gradesList[index];
          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: Container(
              decoration: BoxDecoration(
                color: _selectedIndex == index ? Colors.blue[100] : null,
              ),
              child: ListTile(
                title: Text(grade.sid),
                subtitle: Text(grade.grade),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGrade,
        tooltip: 'Add Grade',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GradeForm extends StatefulWidget {
  final Grade? grade; // If you're editing a grade, this is the grade to edit. Otherwise, it's null.

  const GradeForm({super.key, this.grade});

  @override
  _GradeFormState createState() => _GradeFormState();
}

class _GradeFormState extends State<GradeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sidController;
  late TextEditingController _gradeController;

  @override
  void initState() {
    super.initState();
    _sidController = TextEditingController(text: widget.grade?.sid);
    _gradeController = TextEditingController(text: widget.grade?.grade);
  }

  void _saveGrade() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, we want to show a Snackbar
      final newGrade = Grade(sid: _sidController.text, grade: _gradeController.text);

      Navigator.pop(context as BuildContext, newGrade); // Pops the current route off the navigator and returns the new grade
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grade == null ? 'Add Grade' : 'Edit Grade'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // Add TextFormFields and ElevatedButton here.
            TextFormField(
              controller: _sidController,
              decoration: const InputDecoration(
                labelText: 'Student ID',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student ID';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _gradeController,
              decoration: const InputDecoration(
                labelText: 'Grade',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the grade';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _saveGrade,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _sidController.dispose();
    _gradeController.dispose();
    super.dispose();
  }
}

class GradesModel {
  // Database table and column names
  final String tableGrades = 'grades';
  final String columnId = 'id';
  final String columnSid = 'sid';
  final String columnGrade = 'grade';

  // Singleton instance
  static final GradesModel _instance = GradesModel._privateConstructor();
  static GradesModel get instance => _instance;

  GradesModel._privateConstructor();

  // SQLite database
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // Open the database
  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'grades.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableGrades (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnSid TEXT NOT NULL,
            $columnGrade TEXT NOT NULL
          )
          ''');
  }

  // Fetch all grades
  Future<List<Grade>> getAllGrades() async {
    final db = await database;
    var grades = await db!.query(tableGrades);
    List<Grade> gradeList = grades.isNotEmpty ? grades.map((c) => Grade.fromMap(c)).toList() : [];
    return gradeList;
  }

  // Insert a grade
  Future<int> insertGrade(Grade grade) async {
    final db = await database;
    return await db!.insert(tableGrades, grade.toMap());
  }

  // Update a grade
  Future<int> updateGrade(Grade grade) async {
    final db = await database;
    return await db!.update(tableGrades, grade.toMap(), where: '$columnId = ?', whereArgs: [grade.id]);
  }

  // Delete a grade
  Future<int> deleteGradeById(int id) async {
    final db = await database;
    return await db!.delete(tableGrades, where: '$columnId = ?', whereArgs: [id]);
  }
}

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
