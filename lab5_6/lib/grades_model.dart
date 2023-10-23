import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'grade.dart';

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
    // Ensure that the grade has a non-null ID, which is necessary for updating the record.
    if (grade.id == null) {
      if (kDebugMode) {
        print('Attempted to update a grade without an ID');
      }
      return Future.value(0); // returning 0 indicates that no records were changed
    }

    // Make sure other critical fields are valid as well...
    if (grade.grade == null) {
      if (kDebugMode) {
        print('Critical information missing in grade object');
      }
      return Future.value(0);
    }

    try {
      final db = await database;

      // Debug: Print the grade information being updated
      if (kDebugMode) {
        print('Updating grade: ${grade.toMap()}');
      }

      // Proceed with the update operation
      int result = await db!.update(
        tableGrades,
        grade.toMap(),
        where: '$columnId = ?',
        whereArgs: [grade.id],
      );

      // Check the update result.
      if (result == 0) {
        if (kDebugMode) {
          print('No records were updated. Check if the ID exists in the DB.');
        }
      } else {
        if (kDebugMode) {
          print('$result record(s) updated in the database.');
        }
      }

      return result;
    } catch (e) {
      // If an error occurs, print the error to the console
      if (kDebugMode) {
        print('Error updating grade: $e');
      }
      return Future.value(0); // An error occurred. Returning 0 indicates no records were updated.
    }
  }


  // Delete a grade
  Future<int> deleteGradeById(int id) async {
    final db = await database;
    return await db!.delete(tableGrades, where: '$columnId = ?', whereArgs: [id]);
  }
}
